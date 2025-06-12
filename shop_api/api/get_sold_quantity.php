<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET');
header('Access-Control-Allow-Headers: Content-Type, Cookie');

$conn = new mysqli('localhost', 'root', '', 'Shop_Nhom2');
if ($conn->connect_error) {
    die(json_encode(['success' => false, 'error' => 'Database connection failed']));
}
$conn->set_charset('utf8');

if (!isset($_GET['ma_san_pham'])) {
    echo json_encode(['success' => false, 'error' => 'Missing ma_san_pham']);
    exit;
}

$ma_san_pham = $_GET['ma_san_pham'];
$stmt = $conn->prepare("SELECT SUM(SO_LUONG) as sold_quantity FROM CHI_TIET_DON_HANG WHERE MA_SAN_PHAM = ?");
$stmt->bind_param('i', $ma_san_pham);
$stmt->execute();
$result = $stmt->get_result();
$row = $result->fetch_assoc();

$sold_quantity = $row['sold_quantity'] ?? 0;
echo json_encode(['success' => true, 'sold_quantity' => (int)$sold_quantity]);

$stmt->close();
$conn->close();
?>