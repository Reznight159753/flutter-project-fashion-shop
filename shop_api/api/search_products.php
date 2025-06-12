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
    error_log('Search products input: ' . json_encode($data));

    // Validate required fields
    if (!isset($data['query']) || empty(trim($data['query']))) {
        error_log('Missing or empty query');
        echo json_encode(['success' => false, 'error' => 'Từ khóa tìm kiếm không được để trống']);
        exit;
    }

    $query = '%' . trim($data['query']) . '%';

    try {
        $stmt = $conn->prepare("
            SELECT MA_SAN_PHAM, TEN_SAN_PHAM, GIA_BAN, HINH_ANH, MA_DANH_MUC, SO_LUONG_TON, MO_TA
            FROM SAN_PHAM
            WHERE TEN_SAN_PHAM LIKE ?
            ORDER BY TEN_SAN_PHAM
        ");
        $stmt->execute([$query]);
        $products = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo json_encode([
            'success' => true,
            'products' => $products,
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