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
$stmt = $conn->prepare("SELECT AVG(DIEM_DANH_GIA) as average_rating, COUNT(*) as total_reviews FROM DANH_GIA WHERE MA_SAN_PHAM = ?");
$stmt->bind_param('i', $ma_san_pham);
$stmt->execute();
$result = $stmt->get_result();
$row = $result->fetch_assoc();

$average_rating = $row['average_rating'] ?? 0.0;
$total_reviews = $row['total_reviews'] ?? 0;

echo json_encode([
    'success' => true,
    'average_rating' => round($average_rating, 1),
    'total_reviews' => (int)$total_reviews
]);

$stmt->close();
$conn->close();
?>