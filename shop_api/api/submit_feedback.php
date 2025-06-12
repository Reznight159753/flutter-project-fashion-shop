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
error_log('Submit feedback input: ' . json_encode($data));

if (!isset($data['feedback']) || empty(trim($data['feedback']))) {
    error_log('Missing or empty feedback');
    echo json_encode(['success' => false, 'error' => 'Feedback không được để trống']);
    exit;
}

$feedback = trim($data['feedback']);
$userId = $_SESSION['user_id'];

try {
    $stmt = $conn->prepare("
        INSERT INTO Y_KIEN_KHACH_HANG (MA_NGUOI_DUNG, NOI_DUNG, NGAY_GUI, TRANG_THAI)
        VALUES (?, ?, NOW(), 'CHUA_XU_LY')
    ");
    $stmt->execute([$userId, $feedback]);

    echo json_encode(['success' => true, 'message' => 'Gửi feedback thành công']);
} catch (PDOException $e) {
    error_log('Feedback error: ' . $e->getMessage());
    echo json_encode(['success' => false, 'error' => 'Lỗi lưu feedback: ' . $e->getMessage()]);
}
?>