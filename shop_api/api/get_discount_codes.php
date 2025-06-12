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

$stmt = $conn->prepare("SELECT MA_CODE, MA, GIA_TRI_GIAM, SO_LAN_SU_DUNG_TOI_DA, SO_LAN_DA_SU_DUNG, NGAY_HET_HAN FROM MA_GIAM_GIA WHERE NGAY_HET_HAN >= NOW() ORDER BY NGAY_TAO DESC");
$stmt->execute();
$result = $stmt->get_result();

$discount_codes = [];
while ($row = $result->fetch_assoc()) {
    $discount_codes[] = [
        'MA_CODE' => $row['MA_CODE'],
        'MA' => $row['MA'],
        'GIA_TRI_GIAM' => $row['GIA_TRI_GIAM'],
        'SO_LAN_SU_DUNG_TOI_DA' => $row['SO_LAN_SU_DUNG_TOI_DA'],
        'SO_LAN_DA_SU_DUNG' => $row['SO_LAN_DA_SU_DUNG'],
        'NGAY_HET_HAN' => $row['NGAY_HET_HAN']
    ];
}

echo json_encode(['success' => true, 'discount_codes' => $discount_codes]);

$stmt->close();
$conn->close();
?>