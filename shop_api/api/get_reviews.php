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
$stmt = $conn->prepare("
    SELECT d.MA_DANH_GIA, n.HO_TEN, d.DIEM_DANH_GIA, d.BINH_LUAN, d.NGAY_TAO
    FROM DANH_GIA d
    JOIN NGUOI_DUNG n ON d.MA_NGUOI_DUNG = n.MA_NGUOI_DUNG
    WHERE d.MA_SAN_PHAM = ?
    ORDER BY d.NGAY_TAO DESC
");
$stmt->bind_param('i', $ma_san_pham);
$stmt->execute();
$result = $stmt->get_result();

$reviews = [];
while ($row = $result->fetch_assoc()) {
    $reviews[] = [
        'MA_DANH_GIA' => $row['MA_DANH_GIA'],
        'HO_TEN' => $row['HO_TEN'],
        'DIEM_DANH_GIA' => $row['DIEM_DANH_GIA'],
        'BINH_LUAN' => $row['BINH_LUAN'],
        'NGAY_TAO' => $row['NGAY_TAO']
    ];
}

echo json_encode(['success' => true, 'reviews' => $reviews]);

$stmt->close();
$conn->close();
?>