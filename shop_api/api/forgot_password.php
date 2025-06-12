<?php
require '../config/database.php';

// Include PHPMailer files trực tiếp
require 'PHPMailer/src/Exception.php';
require 'PHPMailer/src/PHPMailer.php';
require 'PHPMailer/src/SMTP.php';

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\SMTP;
use PHPMailer\PHPMailer\Exception;

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

if (empty($email)) {
    echo json_encode(['success' => false, 'error' => 'Email là bắt buộc']);
    exit;
}

try {
    // Check if email exists
    $stmt = $conn->prepare("SELECT MA_NGUOI_DUNG, HO_TEN FROM NGUOI_DUNG WHERE EMAIL = ?");
    $stmt->execute([$email]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);
    if (!$user) {
        echo json_encode(['success' => false, 'error' => 'Email không tồn tại']);
        exit;
    }

    // Static verification code
    $resetCode = 'CHANGEPASS';

    // Send email using PHPMailer
    
    $mail = new PHPMailer(true);
    try {
        // Server settings
        $mail->SMTPDebug = SMTP::DEBUG_OFF; // Set to SMTP::DEBUG_SERVER for debugging
        $mail->isSMTP();
        $mail->Host = 'smtp.gmail.com';
        $mail->SMTPAuth = true;
        $mail->Username = 'ba0139722@gmail.com';
        $mail->Password = 'eeat mbag qvbv rrsr';
        $mail->SMTPSecure = PHPMailer::ENCRYPTION_SMTPS;
        $mail->Port = 465;

        // Recipients
        $mail->setFrom('ba0139722@gmail.com', 'Shop Nhom2');
        $mail->addAddress($email, $user['HO_TEN']);

        // Content
        $mail->isHTML(true);
        $mail->Subject = 'Verification password change - Fashion shop group 2';
        $mail->Body = "Mã xác nhận của bạn là: <b>$resetCode</b>. Vui lòng sử dụng mã này để đặt lại mật khẩu.";
        $mail->AltBody = "Mã xác nhận của bạn là: $resetCode. Vui lòng sử dụng mã này để đặt lại mật khẩu.";

        $mail->send();
        echo json_encode(['success' => true, 'message' => 'Đã gửi mã xác nhận qua email']);
    } catch (Exception $e) {
        echo json_encode(['success' => false, 'error' => "Không thể gửi email. Lỗi: {$mail->ErrorInfo}"]);
    }
} catch (Exception $e) {
    error_log('Forgot password error: ' . $e->getMessage());
    echo json_encode(['success' => false, 'error' => 'Lỗi hệ thống: ' . $e->getMessage()]);
}
?>