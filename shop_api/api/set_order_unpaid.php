<?php
require '../config/database.php';

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode(['success' => false, 'error' => 'Phương thức không được hỗ trợ']);
    exit;
}

$input = json_decode(file_get_contents('php://input'), true);
$orderId = isset($input['order_id']) ? filter_var($input['order_id'], FILTER_VALIDATE_INT) : null;

if (!$orderId || $orderId <= 0) {
    echo json_encode(['success' => false, 'error' => 'Mã đơn hàng không hợp lệ']);
    exit;
}

try {
    $stmt = $conn->prepare("UPDATE DON_HANG SET TRANG_THAI_DON_HANG = 'CHUA_THANH_TOAN' WHERE MA_DON_HANG = ?");
    $stmt->execute([$orderId]);
    echo json_encode(['success' => true, 'message' => 'Đã cập nhật trạng thái đơn hàng']);
} catch (PDOException $e) {
    error_log('Set order unpaid error: ' . $e->getMessage());
    echo json_encode(['success' => false, 'error' => 'Lỗi hệ thống: ' . $e->getMessage()]);
}
?>