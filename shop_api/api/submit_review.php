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
error_log('Submit review input: ' . json_encode($data));

if (!isset($data['order_id'], $data['product_id'], $data['rating']) ||
    !is_numeric($data['rating']) || $data['rating'] < 1 || $data['rating'] > 5) {
    echo json_encode(['success' => false, 'error' => 'Dữ liệu không hợp lệ']);
    exit;
}

$orderId = $data['order_id'];
$productId = $data['product_id'];
$rating = (int)$data['rating'];
$comment = $data['comment'] ?? '';
$userId = $_SESSION['user_id'];

try {
    // Kiểm tra đơn hàng có tồn tại và thuộc người dùng
    $stmt = $conn->prepare("
        SELECT MA_DON_HANG
        FROM DON_HANG
        WHERE MA_DON_HANG = ? AND MA_NGUOI_DUNG = ? AND TRANG_THAI_DON_HANG IN ('DA_GIAO', 'HOAN_THANH')
    ");
    $stmt->execute([$orderId, $userId]);
    if (!$stmt->fetch()) {
        echo json_encode(['success' => false, 'error' => 'Đơn hàng không hợp lệ hoặc chưa giao']);
        exit;
    }

    // Kiểm tra sản phẩm có trong đơn hàng
    $stmt = $conn->prepare("
        SELECT MA_SAN_PHAM
        FROM CHI_TIET_DON_HANG
        WHERE MA_DON_HANG = ? AND MA_SAN_PHAM = ?
    ");
    $stmt->execute([$orderId, $productId]);
    if (!$stmt->fetch()) {
        echo json_encode(['success' => false, 'error' => 'Sản phẩm không có trong đơn hàng']);
        exit;
    }

    // Kiểm tra đã đánh giá chưa
    $stmt = $conn->prepare("
        SELECT MA_DANH_GIA
        FROM DANH_GIA
        WHERE MA_NGUOI_DUNG = ? AND MA_SAN_PHAM = ? AND MA_DANH_GIA IN (
            SELECT MA_DANH_GIA
            FROM CHI_TIET_DON_HANG ctdh
            JOIN DON_HANG dh ON ctdh.MA_DON_HANG = dh.MA_DON_HANG
            WHERE dh.MA_DON_HANG = ?
        )
    ");
    $stmt->execute([$userId, $productId, $orderId]);
    if ($stmt->fetch()) {
        echo json_encode(['success' => false, 'error' => 'Sản phẩm này đã được đánh giá']);
        exit;
    }

    // Lưu đánh giá
    $stmt = $conn->prepare("
        INSERT INTO DANH_GIA (MA_NGUOI_DUNG, MA_SAN_PHAM, DIEM_DANH_GIA, BINH_LUAN, NGAY_TAO)
        VALUES (?, ?, ?, ?, NOW())
    ");
    $stmt->execute([$userId, $productId, $rating, $comment]);

    echo json_encode(['success' => true, 'message' => 'Gửi đánh giá thành công']);
} catch (PDOException $e) {
    error_log('Submit review error: ' . $e->getMessage());
    echo json_encode(['success' => false, 'error' => 'Lỗi lưu đánh giá: ' . $e->getMessage()]);
}
?>