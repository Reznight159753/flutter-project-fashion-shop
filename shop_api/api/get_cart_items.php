<?php
require '../config/database.php';

// Set headers
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    // Get user ID from query parameter
    $userId = isset($_GET['user_id']) ? intval($_GET['user_id']) : 0;
    
    if ($userId <= 0) {
        echo json_encode(['success' => false, 'error' => 'User ID is required or invalid']);
        exit;
    }
    
    try {
        // Check if cart exists, create if not
        $cartStmt = $conn->prepare("SELECT MA_GIO_HANG FROM GIO_HANG WHERE MA_NGUOI_DUNG = ?");
        $cartStmt->execute([$userId]);
        $cart = $cartStmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$cart) {
            $cartStmt = $conn->prepare("INSERT INTO GIO_HANG (MA_NGUOI_DUNG) VALUES (?)");
            $cartStmt->execute([$userId]);
            $cartId = $conn->lastInsertId();
        } else {
            $cartId = $cart['MA_GIO_HANG'];
        }
        
        // Get cart items with product details
        $stmt = $conn->prepare("
            SELECT 
                ctgh.MA_CHI_TIET_GIO_HANG,
                ctgh.MA_SAN_PHAM,
                ctgh.SO_LUONG,
                sp.TEN_SAN_PHAM,
                sp.GIA_BAN,
                sp.HINH_ANH,
                sp.MA_DANH_MUC,
                dm.TEN_DANH_MUC
            FROM 
                CHI_TIET_GIO_HANG ctgh
            JOIN 
                SAN_PHAM sp ON ctgh.MA_SAN_PHAM = sp.MA_SAN_PHAM
            LEFT JOIN 
                DANH_MUC dm ON sp.MA_DANH_MUC = dm.MA_DANH_MUC
            WHERE 
                ctgh.MA_GIO_HANG = ?
        ");
        
        $stmt->execute([$cartId]);
        $cartItems = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        // Calculate total price
        $totalPrice = 0;
        foreach ($cartItems as $item) {
            $totalPrice += $item['GIA_BAN'] * $item['SO_LUONG'];
        }
        
        echo json_encode([
            'success' => true, 
            'cart_items' => $cartItems,
            'total_price' => $totalPrice
        ]);
        
    } catch (PDOException $e) {
        echo json_encode(['success' => false, 'error' => 'Database error: ' . $e->getMessage()]);
    }
} else {
    echo json_encode(['success' => false, 'error' => 'Method not allowed']);
}
?>