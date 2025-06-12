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

$userId = $_GET['user_id'] ?? $_SESSION['user_id'];
$page = isset($_GET['page']) ? max(1, (int)$_GET['page']) : 1;
$limit = isset($_GET['limit']) ? max(1, (int)$_GET['limit']) : 10;
$offset = ($page - 1) * $limit;

if ($userId != $_SESSION['user_id']) {
    echo json_encode(['success' => false, 'error' => 'Người dùng không hợp lệ']);
    exit;
}

try {
    // Count total orders
    $stmt = $conn->prepare("
        SELECT COUNT(*) as total
        FROM DON_HANG
        WHERE MA_NGUOI_DUNG = :userId
    ");
    $stmt->bindValue(':userId', (int)$userId, PDO::PARAM_INT);
    $stmt->execute();
    $total = $stmt->fetch(PDO::FETCH_ASSOC)['total'];

    // Fetch orders
    $stmt = $conn->prepare("
        SELECT 
            MA_DON_HANG,
            NGAY_TAO as NGAY_DAT,
            TONG_TIEN,
            DIA_CHI_GIAO_HANG as DIA_CHI_GIAO,
            TRANG_THAI_DON_HANG as TRANG_THAI,
            PHUONG_THUC_THANH_TOAN,
            MA_GIAM_GIA as MA_KHUYEN_MAI,
            SO_TIEN_GIAM as GIA_GIAM
        FROM DON_HANG
        WHERE MA_NGUOI_DUNG = :userId
        ORDER BY NGAY_TAO DESC
        LIMIT :limit OFFSET :offset
    ");
    $stmt->bindValue(':userId', (int)$userId, PDO::PARAM_INT);
    $stmt->bindValue(':limit', (int)$limit, PDO::PARAM_INT);
    $stmt->bindValue(':offset', (int)$offset, PDO::PARAM_INT);
    $stmt->execute();
    $orders = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // Fetch order items
    foreach ($orders as &$order) {
        $itemStmt = $conn->prepare("
            SELECT 
                ctdh.MA_SAN_PHAM,
                sp.TEN_SAN_PHAM,
                ctdh.SO_LUONG,
                ctdh.DON_GIA as GIA_BAN,
                sp.HINH_ANH
            FROM CHI_TIET_DON_HANG ctdh
            JOIN SAN_PHAM sp ON ctdh.MA_SAN_PHAM = sp.MA_SAN_PHAM
            WHERE ctdh.MA_DON_HANG = ?
        ");
        $itemStmt->execute([$order['MA_DON_HANG']]);
        $order['items'] = $itemStmt->fetchAll(PDO::FETCH_ASSOC);
    }

    echo json_encode([
        'success' => true,
        'orders' => $orders,
        'total' => $total,
    ]);
} catch (PDOException $e) {
    error_log('Get orders error: ' . $e->getMessage());
    echo json_encode(['success' => false, 'error' => 'Lỗi lấy đơn hàng: ' . $e->getMessage()]);
}
?>