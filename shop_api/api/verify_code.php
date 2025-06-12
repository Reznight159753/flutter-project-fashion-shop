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
$email = $input['email'] ?? '';
$code = $input['code'] ?? '';

if (empty($email) || empty($code)) {
    echo json_encode(['success' => false, 'error' => 'Email và mã xác nhận là bắt buộc']);
    exit;
}

try {
    // Check if email exists
    $stmt = $conn->prepare("SELECT MA_NGUOI_DUNG FROM NGUOI_DUNG WHERE EMAIL = ?");
    $stmt->execute([$email]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$user) {
        echo json_encode(['success' => false, 'error' => 'Email không tồn tại']);
        exit;
    }

    // Verify static code
    if ($code !== 'CHANGEPASS') {
        echo json_encode(['success' => false, 'error' => 'Mã xác nhận không đúng']);
        exit;
    }

    // Code is valid
    echo json_encode(['success' => true, 'message' => 'Mã xác nhận hợp lệ']);
} catch (PDOException $e) {
    error_log('Verify code error: ' . $e->getMessage());
    echo json_encode(['success' => false, 'error' => 'Lỗi hệ thống: ' . $e->getMessage()]);
}
?>