<?php
require '../config/database.php';

// Set headers
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Get input data
    $data = json_decode(file_get_contents('php://input'), true);
    
    // Log input data
    error_log('Save order input: ' . json_encode($data));

    // Validate required fields
    $requiredFields = ['user_id', 'total_amount', 'delivery_address', 'payment_method', 'cart_items'];
    foreach ($requiredFields as $field) {
        if (!isset($data[$field]) || empty($data[$field])) {
            error_log("Missing or empty field: $field");
            echo json_encode(['success' => false, 'error' => "Trường $field là bắt buộc"]);
            exit;
        }
    }
    
    // Extract data
    $userId = filter_var($data['user_id'], FILTER_VALIDATE_INT);
    $totalAmount = filter_var($data['total_amount'], FILTER_VALIDATE_FLOAT);
    $deliveryAddress = trim($data['delivery_address']);
    $paymentMethod = trim($data['payment_method']);
    $cartItems = $data['cart_items'];
    $discountCode = isset($data['discount_code']) ? trim($data['discount_code']) : null;
    $promotionDiscount = isset($data['promotion_discount']) ? filter_var($data['promotion_discount'], FILTER_VALIDATE_FLOAT) : 0;

    // Validate extracted data
    if ($userId === false || $userId <= 0) {
        error_log('Invalid user_id: ' . $data['user_id']);
        echo json_encode(['success' => false, 'error' => 'ID người dùng không hợp lệ']);
        exit;
    }
    if ($totalAmount === false || $totalAmount < 0) {
        error_log('Invalid total_amount: ' . $data['total_amount']);
        echo json_encode(['success' => false, 'error' => 'Tổng tiền không hợp lệ']);
        exit;
    }
    if ($promotionDiscount === false || $promotionDiscount < 0) {
        error_log('Invalid promotion_discount: ' . $data['promotion_discount']);
        echo json_encode(['success' => false, 'error' => 'Số tiền giảm giá không hợp lệ']);
        exit;
    }

    // Validate payment method
    $validPaymentMethods = ['COD', 'VI_DIEN_TU', 'THE_NGAN_HANG'];
    if (!in_array($paymentMethod, $validPaymentMethods)) {
        error_log('Invalid payment_method: ' . $paymentMethod);
        echo json_encode(['success' => false, 'error' => 'Phương thức thanh toán không hợp lệ: ' . $paymentMethod]);
        exit;
    }
    
    // Validate cart items
    foreach ($cartItems as $index => $item) {
        if (!isset($item['MA_SAN_PHAM']) || !isset($item['SO_LUONG']) || !isset($item['GIA_BAN'])) {
            error_log("Missing cart item field at index $index: " . json_encode($item));
            echo json_encode(['success' => false, 'error' => 'Dữ liệu mục giỏ hàng không hợp lệ']);
            exit;
        }
        $productId = filter_var($item['MA_SAN_PHAM'], FILTER_VALIDATE_INT);
        $quantity = filter_var($item['SO_LUONG'], FILTER_VALIDATE_INT);
        $price = filter_var($item['GIA_BAN'], FILTER_VALIDATE_FLOAT);
        if ($productId === false || $productId <= 0 || $quantity === false || $quantity <= 0 || $price === false || $price < 0) {
            error_log("Invalid cart item at index $index: " . json_encode($item));
            echo json_encode(['success' => false, 'error' => 'Dữ liệu mục giỏ hàng không hợp lệ']);
            exit;
        }
    }
    
    try {
        // Start transaction
        $conn->beginTransaction();
        
        // Insert into DON_HANG
        $orderStmt = $conn->prepare("
            INSERT INTO DON_HANG (
                MA_NGUOI_DUNG, TONG_TIEN, DIA_CHI_GIAO_HANG, PHUONG_THUC_THANH_TOAN, 
                TRANG_THAI_DON_HANG, MA_GIAM_GIA, SO_TIEN_GIAM
            ) VALUES (?, ?, ?, ?, 'CHO_XU_LY', ?, ?)
        ");
        $orderStmt->execute([
            $userId,
            $totalAmount,
            $deliveryAddress,
            $paymentMethod,
            $discountCode,
            $promotionDiscount
        ]);
        $orderId = $conn->lastInsertId();
        
        // Insert into CHI_TIET_DON_HANG
        $detailStmt = $conn->prepare("
            INSERT INTO CHI_TIET_DON_HANG (
                MA_DON_HANG, MA_SAN_PHAM, SO_LUONG, DON_GIA
            ) VALUES (?, ?, ?, ?)
        ");
        foreach ($cartItems as $item) {
            $detailStmt->execute([
                $orderId,
                intval($item['MA_SAN_PHAM']),
                intval($item['SO_LUONG']),
                floatval($item['GIA_BAN'])
            ]);
            
            // Update inventory
            $updateInventoryStmt = $conn->prepare("
                UPDATE SAN_PHAM 
                SET SO_LUONG_TON = SO_LUONG_TON - ? 
                WHERE MA_SAN_PHAM = ?
            ");
            $updateInventoryStmt->execute([
                intval($item['SO_LUONG']),
                intval($item['MA_SAN_PHAM'])
            ]);
        }
        
        // Update discount code usage
        if ($discountCode) {
            $checkCodeStmt = $conn->prepare("
                SELECT SO_LAN_DA_SU_DUNG, SO_LAN_SU_DUNG_TOI_DA 
                FROM MA_GIAM_GIA 
                WHERE MA = ?
            ");
            $checkCodeStmt->execute([$discountCode]);
            $code = $checkCodeStmt->fetch(PDO::FETCH_ASSOC);
            
            if ($code && $code['SO_LAN_DA_SU_DUNG'] < $code['SO_LAN_SU_DUNG_TOI_DA']) {
                $updateCodeStmt = $conn->prepare("
                    UPDATE MA_GIAM_GIA 
                    SET SO_LAN_DA_SU_DUNG = SO_LAN_DA_SU_DUNG + 1
                    WHERE MA = ?
                ");
                $updateCodeStmt->execute([$discountCode]);
            } else {
                $conn->rollBack();
                error_log('Invalid discount code or no uses left: ' . $discountCode);
                echo json_encode(['success' => false, 'error' => 'Mã giảm giá không hợp lệ hoặc đã hết lượt sử dụng']);
                exit;
            }
        }
        
        // Clear cart
        $cartStmt = $conn->prepare("SELECT MA_GIO_HANG FROM GIO_HANG WHERE MA_NGUOI_DUNG = ?");
        $cartStmt->execute([$userId]);
        $cart = $cartStmt->fetch(PDO::FETCH_ASSOC);
        $cartId = $cart ? $cart['MA_GIO_HANG'] : null;

        if ($cartId) {
            // Delete cart details
            $deleteDetailsStmt = $conn->prepare("DELETE FROM CHI_TIET_GIO_HANG WHERE MA_GIO_HANG = ?");
            $deleteDetailsStmt->execute([$cartId]);

            // Delete cart
            $deleteCartStmt = $conn->prepare("DELETE FROM GIO_HANG WHERE MA_GIO_HANG = ?");
            $deleteCartStmt->execute([$cartId]);
        }
        
        // Commit transaction
        $conn->commit();
        
        echo json_encode([
            'success' => true,
            'message' => 'Đặt hàng thành công',
            'order_id' => $orderId
        ]);
    } catch (PDOException $e) {
        $conn->rollBack();
        error_log('Database error: ' . $e->getMessage());
        echo json_encode(['success' => false, 'error' => 'Lỗi cơ sở dữ liệu: ' . $e->getMessage()]);
    }
} else {
    error_log('Invalid request method: ' . $_SERVER['REQUEST_METHOD']);
    echo json_encode(['success' => false, 'error' => 'Phương thức không được phép']);
}
?>