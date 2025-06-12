<?php
require '../config/database.php';
session_start();

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    if (!isset($_SESSION['user_id'])) {
        echo json_encode(['success' => false, 'error' => 'Chưa đăng nhập']);
        exit;
    }

    $userId = $_SESSION['user_id'];
    $stmt = $conn->prepare("SELECT * FROM NGUOI_DUNG WHERE MA_NGUOI_DUNG = ?");
    $stmt->execute([$userId]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($user) {
        echo json_encode([
            'success' => true,
            'user' => [
                'ma_nguoi_dung' => strval($user['MA_NGUOI_DUNG']),
                'ho_ten' => $user['HO_TEN'],
                'email' => $user['EMAIL'],
                'so_dien_thoai' => $user['SO_DIEN_THOAI'],
                'dia_chi' => $user['DIA_CHI'] ?? '',
                'anh_dai_dien' => $user['ANH_DAI_DIEN'] ? "http://10.0.2.2/shop_api/images/{$user['ANH_DAI_DIEN']}" : null,
            ]
        ]);
    } else {
        echo json_encode(['success' => false, 'error' => 'Không tìm thấy người dùng']);
    }
} else {
    echo json_encode(['success' => false, 'error' => 'Phương thức không được phép']);
}
?>