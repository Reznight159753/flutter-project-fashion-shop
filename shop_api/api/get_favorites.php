<?php
require '../config/database.php';
session_start();

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET');
header('Access-Control-Allow-Headers: Content-Type');

if (!isset($_SESSION['user_id'])) {
    echo json_encode(['success' => false, 'error' => 'Chưa đăng nhập']);
    exit;
}

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    echo json_encode(['success' => false, 'error' => 'Phương thức không được hỗ trợ']);
    exit;
}

$userId = $_SESSION['user_id'];

try {
    $stmt = $conn->prepare("
        SELECT 
            sp.MA_SAN_PHAM,
            sp.MA_DANH_MUC,
            sp.TEN_SAN_PHAM,
            sp.MO_TA,
            sp.GIA_BAN,
            sp.SO_LUONG_TON,
            sp.HINH_ANH
        FROM YEU_THICH yt
        JOIN SAN_PHAM sp ON yt.MA_SAN_PHAM = sp.MA_SAN_PHAM
        WHERE yt.MA_NGUOI_DUNG = ?
    ");
    $stmt->execute([$userId]);
    $favorites = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode([
        'success' => true,
        'favorites' => $favorites,
    ]);
} catch (PDOException $e) {
    error_log('Get favorites error: ' . $e->getMessage());
    echo json_encode(['success' => false, 'error' => 'Lỗi lấy danh sách yêu thích: ' . $e->getMessage()]);
}
?>