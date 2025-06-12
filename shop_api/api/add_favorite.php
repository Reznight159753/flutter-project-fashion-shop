<?php
require '../config/database.php';
session_start();

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

if (!isset($_SESSION['user_id'])) {
    echo json_encode(['success' => false, 'error' => 'Chưa đăng nhập']);
    exit;
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode(['success' => false, 'error' => 'Phương thức không được hỗ trợ']);
    exit;
}

$data = json_decode(file_get_contents('php://input'), true);
error_log('Add favorite input: ' . json_encode($data));

if (!isset($data['product_id']) || !is_numeric($data['product_id'])) {
    echo json_encode(['success' => false, 'error' => 'ID sản phẩm không hợp lệ']);
    exit;
}

$productId = (int)$data['product_id'];
$userId = $_SESSION['user_id'];

try {
    // Kiểm tra sản phẩm có tồn tại
    $stmt = $conn->prepare("SELECT MA_SAN_PHAM FROM SAN_PHAM WHERE MA_SAN_PHAM = ?");
    $stmt->execute([$productId]);
    if (!$stmt->fetch()) {
        echo json_encode(['success' => false, 'error' => 'Sản phẩm không tồn tại']);
        exit;
    }

    // Kiểm tra đã yêu thích chưa
    $stmt = $conn->prepare("SELECT MA_NGUOI_DUNG FROM YEU_THICH WHERE MA_NGUOI_DUNG = ? AND MA_SAN_PHAM = ?");
    $stmt->execute([$userId, $productId]);
    if ($stmt->fetch()) {
        echo json_encode(['success' => false, 'error' => 'Sản phẩm đã trong danh sách yêu thích']);
        exit;
    }

    // Thêm vào danh sách yêu thích
    $stmt = $conn->prepare("INSERT INTO YEU_THICH (MA_NGUOI_DUNG, MA_SAN_PHAM, NGAY_THEM) VALUES (?, ?, NOW())");
    $stmt->execute([$userId, $productId]);

    echo json_encode(['success' => true, 'message' => 'Đã thêm vào danh sách yêu thích']);
} catch (PDOException $e) {
    error_log('Add favorite error: ' . $e->getMessage());
    echo json_encode(['success' => false, 'error' => 'Lỗi: ' . $e->getMessage()]);
}
?>