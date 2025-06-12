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

$ma_chi_tiet_gio_hang = $_POST['ma_chi_tiet_gio_hang'] ?? null;

if (!$ma_chi_tiet_gio_hang) {
    echo json_encode(['success' => false, 'error' => 'Dữ liệu không hợp lệ']);
    exit;
}

try {
    $stmt = $conn->prepare("
        DELETE FROM CHI_TIET_GIO_HANG 
        WHERE MA_CHI_TIET_GIO_HANG = ?
    ");
    $stmt->execute([$ma_chi_tiet_gio_hang]);
    
    echo json_encode(['success' => true, 'message' => 'Xóa sản phẩm thành công']);
} catch (PDOException $e) {
    echo json_encode([
        'success' => false,
        'error' => 'Lỗi cơ sở dữ liệu: ' . $e->getMessage()
    ]);
}
?>