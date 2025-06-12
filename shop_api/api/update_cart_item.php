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
$so_luong = isset($_POST['so_luong']) ? (int)$_POST['so_luong'] : null;

if (!$ma_chi_tiet_gio_hang || $so_luong <= 0) {
    echo json_encode(['success' => false, 'error' => 'Dữ liệu không hợp lệ']);
    exit;
}

try {
    $stmt = $conn->prepare("
        UPDATE CHI_TIET_GIO_HANG 
        SET SO_LUONG = ? 
        WHERE MA_CHI_TIET_GIO_HANG = ?
    ");
    $stmt->execute([$so_luong, $ma_chi_tiet_gio_hang]);
    
    echo json_encode(['success' => true, 'message' => 'Cập nhật số lượng thành công']);
} catch (PDOException $e) {
    echo json_encode([
        'success' => false,
        'error' => 'Lỗi cơ sở dữ liệu: ' . $e->getMessage()
    ]);
}
?>