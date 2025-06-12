<?php
require '../config/database.php';

// Set headers
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Get POST data
    $data = json_decode(file_get_contents('php://input'), true);
    $userId = $data['user_id'] ?? '';
    $address = $data['address'] ?? '';
    
    if (empty($userId) || empty($address)) {
        echo json_encode(['success' => false, 'error' => 'User ID and address are required']);
        exit;
    }
    
    try {
        // Prepare and execute update query
        $stmt = $conn->prepare("UPDATE NGUOI_DUNG SET DIA_CHI = ? WHERE MA_NGUOI_DUNG = ?");
        $result = $stmt->execute([$address, $userId]);
        
        if ($result) {
            echo json_encode(['success' => true, 'message' => 'Địa chỉ đã được cập nhật thành công']);
        } else {
            echo json_encode(['success' => false, 'error' => 'Cập nhật địa chỉ thất bại']);
        }
    } catch (PDOException $e) {
        echo json_encode(['success' => false, 'error' => 'Lỗi cơ sở dữ liệu: ' . $e->getMessage()]);
    }
} else {
    echo json_encode(['success' => false, 'error' => 'Phương thức không được phép']);
}
?>