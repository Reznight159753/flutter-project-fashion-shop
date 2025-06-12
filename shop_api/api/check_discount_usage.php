<?php
require '../config/database.php';

// Set headers
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $data = json_decode(file_get_contents('php://input'), true);
    
    // Log input data
    error_log('Check discount usage input: ' . json_encode($data));

    // Validate required fields
    if (!isset($data['code']) || empty($data['code']) || !isset($data['user_id']) || empty($data['user_id'])) {
        error_log('Missing code or user_id');
        echo json_encode(['success' => false, 'error' => 'Mã giảm giá hoặc ID người dùng không được để trống']);
        exit;
    }

    $code = trim($data['code']);
    $userId = filter_var($data['user_id'], FILTER_VALIDATE_INT);

    if ($userId === false || $userId <= 0) {
        error_log('Invalid user_id: ' . $data['user_id']);
        echo json_encode(['success' => false, 'error' => 'ID người dùng không hợp lệ']);
        exit;
    }

    try {
        $stmt = $conn->prepare("
            SELECT COUNT(*) as count 
            FROM DON_HANG 
            WHERE MA_GIAM_GIA = ? AND MA_NGUOI_DUNG = ?
        ");
        $stmt->execute([$code, $userId]);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);

        echo json_encode([
            'success' => true,
            'used' => $result['count'] > 0,
        ]);
    } catch (PDOException $e) {
        error_log('Database error: ' . $e->getMessage());
        echo json_encode(['success' => false, 'error' => 'Lỗi cơ sở dữ liệu: ' . $e->getMessage()]);
    }
} else {
    error_log('Invalid request method: ' . $_SERVER['REQUEST_METHOD']);
    echo json_encode(['success' => false, 'error' => 'Phương thức không được phép']);
}
?>