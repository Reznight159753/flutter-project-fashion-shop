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
$newPassword = $input['new_password'] ?? '';

if (empty($email) || empty($newPassword)) {
    echo json_encode(['success' => false, 'error' => 'Email và mật khẩu mới là bắt buộc']);
    exit;
}

try {
    $stmt = $conn->prepare("SELECT MA_NGUOI_DUNG FROM NGUOI_DUNG WHERE EMAIL = ?");
    $stmt->execute([$email]);
    if (!$stmt->fetch()) {
        echo json_encode(['success' => false, 'error' => 'Email không tồn tại']);
        exit;
    }
    $stmt = $conn->prepare("UPDATE NGUOI_DUNG SET MAT_KHAU = ? WHERE EMAIL = ?");
    $stmt->execute([$newPassword, $email]);

    echo json_encode(['success' => true, 'message' => 'Mật khẩu đã được cập nhật']);
} catch (PDOException $e) {
    error_log('Update password error: ' . $e->getMessage());
    echo json_encode(['success' => false, 'error' => 'Lỗi hệ thống: ' . $e->getMessage()]);
}
?>