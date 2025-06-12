<?php
require '../config/database.php';
session_start();

header('Content-Type: application/json');

if (!isset($_SESSION['user_id'])) {
    echo json_encode(['success' => false, 'error' => 'Chưa đăng nhập']);
    exit;
}

try {
    $user_id = $_SESSION['user_id'];
    
    // Kiểm tra hoặc tạo giỏ hàng cho người dùng
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
    
    // Lấy chi tiết giỏ hàng
    $stmt = $conn->prepare("
        SELECT ct.MA_CHI_TIET_GIO_HANG, ct.MA_SAN_PHAM, ct.SO_LUONG, 
               sp.TEN_SAN_PHAM, sp.GIA_BAN, sp.HINH_ANH
        FROM CHI_TIET_GIO_HANG ct
        JOIN SAN_PHAM sp ON ct.MA_SAN_PHAM = sp.MA_SAN_PHAM
        WHERE ct.MA_GIO_HANG = ?
    ");
    $stmt->execute([$cart_id]);
    $cart_items = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo json_encode([
        'success' => true,
        'cart_items' => $cart_items
    ]);
} catch (PDOException $e) {
    echo json_encode([
        'success' => false,
        'error' => 'Lỗi cơ sở dữ liệu: ' . $e->getMessage()
    ]);
}
?>