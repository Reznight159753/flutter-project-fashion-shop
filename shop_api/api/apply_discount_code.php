<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type, Cookie');

$conn = new mysqli('localhost', 'root', '', 'Shop_Nhom2');
if ($conn->connect_error) {
    die(json_encode(['success' => false, 'error' => 'Database connection failed']));
}
$conn->set_charset('utf8');

$input = json_decode(file_get_contents('php://input'), true);
$code = $input['ma'] ?? '';
$userId = $input['user_id'] ?? '';

if (empty($code) || empty($userId)) {
    echo json_encode(['success' => false, 'error' => 'Mã giảm giá hoặc ID người dùng không được để trống']);
    exit;
}

$stmt = $conn->prepare("SELECT MA_CODE, GIA_TRI_GIAM, SO_LAN_SU_DUNG_TOI_DA, SO_LAN_DA_SU_DUNG, NGAY_HET_HAN FROM MA_GIAM_GIA WHERE MA = ? AND NGAY_HET_HAN >= NOW()");
$stmt->bind_param('s', $code);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 0) {
    echo json_encode(['success' => false, 'error' => 'Mã giảm giá không hợp lệ hoặc đã hết hạn']);
    $stmt->close();
    $conn->close();
    exit;
}

$discount = $result->fetch_assoc();
if ($discount['SO_LAN_DA_SU_DUNG'] >= $discount['SO_LAN_SU_DUNG_TOI_DA']) {
    echo json_encode(['success' => false, 'error' => 'Mã giảm giá đã hết lượt sử dụng']);
    $stmt->close();
    $conn->close();
    exit;
}

// Kiểm tra xem người dùng đã sử dụng mã này chưa (nếu cần giới hạn 1 lần/người dùng)
$stmt = $conn->prepare("SELECT COUNT(*) as count FROM DON_HANG WHERE MA_NGUOI_DUNG = ? AND MA_GIAM_GIA = ?");
$stmt->bind_param('is', $userId, $code);
$stmt->execute();
$result = $stmt->get_result();
$usageCount = $result->fetch_assoc()['count'];
if ($usageCount > 0) {
    echo json_encode(['success' => false, 'error' => 'Bạn đã sử dụng mã này trước đây']);
    $stmt->close();
    $conn->close();
    exit;
}

echo json_encode([
    'success' => true,
    'discount_value' => $discount['GIA_TRI_GIAM'],
    'message' => 'Mã giảm giá hợp lệ'
]);

$stmt->close();
$conn->close();
?>