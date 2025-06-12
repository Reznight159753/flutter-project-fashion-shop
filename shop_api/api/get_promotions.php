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

$stmt = $conn->prepare("SELECT MA_SU_KIEN, TEN_SU_KIEN, MO_TA, TY_LE_GIAM_GIA, NGAY_BAT_DAU, NGAY_KET_THUC FROM SU_KIEN_KHUYEN_MAI WHERE NGAY_KET_THUC >= NOW() ORDER BY NGAY_BAT_DAU DESC");
$stmt->execute();
$result = $stmt->get_result();

$promotions = [];
while ($row = $result->fetch_assoc()) {
    $promotions[] = [
        'MA_SU_KIEN' => $row['MA_SU_KIEN'],
        'TEN_SU_KIEN' => $row['TEN_SU_KIEN'],
        'MO_TA' => $row['MO_TA'],
        'TY_LE_GIAM_GIA' => $row['TY_LE_GIAM_GIA'],
        'NGAY_BAT_DAU' => $row['NGAY_BAT_DAU'],
        'NGAY_KET_THUC' => $row['NGAY_KET_THUC']
    ];
}

echo json_encode(['success' => true, 'promotions' => $promotions]);

$stmt->close();
$conn->close();
?>