<?php
require '../config/database.php';
session_start();

header('Content-Type: application/json');

if (!isset($_SESSION['user_id'])) {
    echo json_encode(['success' => false, 'error' => 'Chưa đăng nhập']);
    exit;
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode(['success' => false, 'error' => 'Phương thức không được phép']);
    exit;
}

$ma_san_pham = $_POST['ma_san_pham'] ?? null;
$so_luong = isset($_POST['so_luong']) ? (int)$_POST['so_luong'] : 1;

if (!$ma_san_pham || $so_luong <= 0) {
    echo json_encode(['success' => false, 'error' => 'Dữ liệu không hợp lệ']);
    exit;
}

try {
    $user_id = $_SESSION['user_id'];
    
    // Kiểm tra giỏ hàng
    $stmt = $conn->prepare("SELECT MA_GIO_HANG FROM GIO_HANG WHERE MA_NGUOI_DUNG = ?");
    $stmt->execute([$user_id]);
    $cart = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$cart) {
        $stmt = $conn->prepare("INSERT INTO GIO_HANG (MA_NGUOI_DUNG) VALUES (?)");
        $stmt->execute([$user_id]);
        $cart_id = $conn->lastInsertId();
    } else {
        $cart_id = $cart['MA_GIO_HANG'];
    }
    
    // Kiểm tra sản phẩm đã có trong giỏ hàng
    $stmt = $conn->prepare("
        SELECT MA_CHI_TIET_GIO_HANG, SO_LUONG 
        FROM CHI_TIET_GIO_HANG 
        WHERE MA_GIO_HANG = ? AND MA_SAN_PHAM = ?
    ");
    $stmt->execute([$cart_id, $ma_san_pham]);
    $existing_item = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if ($existing_item) {
        // Cập nhật số lượng
        $new_quantity = $existing_item['SO_LUONG'] + $so_luong;
        $stmt = $conn->prepare("
            UPDATE CHI_TIET_GIO_HANG 
            SET SO_LUONG = ? 
            WHERE MA_CHI_TIET_GIO_HANG = ?
        ");
        $stmt->execute([$new_quantity, $existing_item['MA_CHI_TIET_GIO_HANG']]);
    } else {
        // Thêm sản phẩm mới
        $stmt = $conn->prepare("
            INSERT INTO CHI_TIET_GIO_HANG (MA_GIO_HANG, MA_SAN_PHAM, SO_LUONG) 
            VALUES (?, ?, ?)
        ");
        $stmt->execute([$cart_id, $ma_san_pham, $so_luong]);
    }
    
    echo json_encode(['success' => true, 'message' => 'Thêm vào giỏ hàng thành công']);
} catch (PDOException $e) {
    echo json_encode([
        'success' => false,
        'error' => 'Lỗi cơ sở dữ liệu: ' . $e->getMessage()
    ]);
}
?>