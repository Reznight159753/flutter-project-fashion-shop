<?php
require '../config/database.php';
header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $data = json_decode(file_get_contents('php://input'), true);
    $email = $data['email'] ?? '';
    $password = $data['password'] ?? '';

    if (empty($email) || empty($password)) {
        echo json_encode([
            'success' => false,
            'error' => 'Vui lòng nhập email và mật khẩu'
        ]);
        exit;
    }

    try {
        $stmt = $conn->prepare("SELECT * FROM NGUOI_DUNG WHERE EMAIL = ?");
        $stmt->execute([$email]);
        $user = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($user && $user['MAT_KHAU'] === $password) {
            session_start();
            $_SESSION['user_id'] = $user['MA_NGUOI_DUNG'];
            echo json_encode([
                'success' => true,
                'user_id' => $user['MA_NGUOI_DUNG'],
                'user_name' => $user['HO_TEN']
            ]);
        } else {
            echo json_encode([
                'success' => false,
                'error' => 'Email hoặc mật khẩu không đúng'
            ]);
        }
    } catch (PDOException $e) {
        echo json_encode([
            'success' => false,
            'error' => 'Lỗi cơ sở dữ liệu: ' . $e->getMessage()
        ]);
    }
} else {
    echo json_encode([
        'success' => false,
        'error' => 'Phương thức không được phép'
    ]);
}
?>