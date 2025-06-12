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
    $conn->beginTransaction();

    // Check order status
    $stmt = $conn->prepare("SELECT TRANG_THAI_DON_HANG FROM DON_HANG WHERE MA_DON_HANG = ?");
    $stmt->execute([$orderId]);
    $order = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$order) {
        $conn->rollBack();
        echo json_encode(['success' => false, 'error' => 'Đơn hàng không tồn tại']);
        exit;
    }

    if (!in_array($order['TRANG_THAI_DON_HANG'], ['CHO_XU_LY', 'CHUA_THANH_TOAN'])) {
        $conn->rollBack();
        echo json_encode(['success' => false, 'error' => 'Không thể hủy đơn hàng ở trạng thái này']);
        exit;
    }

    // Update order status to DA_HUY
    $updateStmt = $conn->prepare("UPDATE DON_HANG SET TRANG_THAI_DON_HANG = 'DA_HUY' WHERE MA_DON_HANG = ?");
    $updateStmt->execute([$orderId]);

    // Restore inventory
    $itemsStmt = $conn->prepare("SELECT MA_SAN_PHAM, SO_LUONG FROM CHI_TIET_DON_HANG WHERE MA_DON_HANG = ?");
    $itemsStmt->execute([$orderId]);
    $items = $itemsStmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($items as $item) {
        $restoreStmt = $conn->prepare("UPDATE SAN_PHAM SET SO_LUONG_TON = SO_LUONG_TON + ? WHERE MA_SAN_PHAM = ?");
        $restoreStmt->execute([$item['SO_LUONG'], $item['MA_SAN_PHAM']]);
    }

    $conn->commit();
    echo json_encode(['success' => true, 'message' => 'Đã hủy đơn hàng thành công']);
} catch (PDOException $e) {
    $conn->rollBack();
    error_log('Cancel order error: ' . $e->getMessage());
    echo json_encode(['success' => false, 'error' => 'Lỗi hệ thống: ' . $e->getMessage()]);
}
?>