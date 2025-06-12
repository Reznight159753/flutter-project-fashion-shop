<?php
require '../config/database.php';

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    echo json_encode(['success' => false, 'error' => 'Phương thức không được hỗ trợ']);
    exit;
}

$userId = isset($_GET['user_id']) ? filter_var($_GET['user_id'], FILTER_VALIDATE_INT) : null;

if (!$userId || $userId <= 0) {
    echo json_encode(['success' => false, 'error' => 'ID người dùng không hợp lệ']);
    exit;
}

try {
    // Fetch orders
    $orderStmt = $conn->prepare("
        SELECT 
            MA_DON_HANG,
            DATE_FORMAT(NGAY_TAO, '%Y-%m-%d %H:%i:%s') AS NGAY_DAT,
            TONG_TIEN,
            DIA_CHI_GIAO_HANG AS DIA_CHI_GIAO,
            TRANG_THAI_DON_HANG AS TRANG_THAI,
            PHUONG_THUC_THANH_TOAN,
            MA_GIAM_GIA AS MA_KHUYEN_MAI,
            SO_TIEN_GIAM AS GIA_GIAM
        FROM DON_HANG
        WHERE MA_NGUOI_DUNG = ?
        ORDER BY NGAY_TAO DESC
    ");
    $orderStmt->execute([$userId]);
    $orders = $orderStmt->fetchAll(PDO::FETCH_ASSOC);

    // Fetch items for each order
    $itemStmt = $conn->prepare("
        SELECT 
            c.MA_SAN_PHAM,
            s.TEN_SAN_PHAM,
            c.SO_LUONG,
            c.DON_GIA,
            s.HINH_ANH
        FROM CHI_TIET_DON_HANG c
        JOIN SAN_PHAM s ON c.MA_SAN_PHAM = s.MA_SAN_PHAM
        WHERE c.MA_DON_HANG = ?
    ");

    foreach ($orders as &$order) {
        $itemStmt->execute([$order['MA_DON_HANG']]);
        $order['items'] = $itemStmt->fetchAll(PDO::FETCH_ASSOC);
    }

    echo json_encode([
        'success' => true,
        'orders' => $orders,
        'total' => count($orders)
    ]);
} catch (PDOException $e) {
    error_log('Get orders error: ' . $e->getMessage());
    echo json_encode(['success' => false, 'error' => 'Lỗi cơ sở dữ liệu: ' . $e->getMessage()]);
}
?>