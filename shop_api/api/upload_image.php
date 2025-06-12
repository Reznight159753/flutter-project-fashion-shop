<?php
header('Content-Type: application/json; charset=UTF-8');

$uploadDir = '../customer_img/';
if (!file_exists($uploadDir)) {
    mkdir($uploadDir, 0777, true);
}

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_FILES['image'])) {
    $file = $_FILES['image'];
    $fileName = basename($file['name']);
    $targetPath = $uploadDir . $fileName;

    // Kiểm tra loại file (chỉ cho phép ảnh)
    $allowedTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/jpg'];
    if (!in_array($file['type'], $allowedTypes)) {
        echo json_encode(['success' => false, 'error' => 'Chỉ hỗ trợ file JPEG, PNG, GIF']);
        exit;
    }

    // Kiểm tra kích thước file (giới hạn 5MB)
    if ($file['size'] > 5 * 1024 * 1024) {
        echo json_encode(['success' => false, 'error' => 'File quá lớn, tối đa 5MB']);
        exit;
    }

    // Upload file
    if (move_uploaded_file($file['tmp_name'], $targetPath)) {
        echo json_encode(['success' => true, 'message' => 'Upload thành công', 'file_name' => $fileName]);
    } else {
        echo json_encode(['success' => false, 'error' => 'Upload thất bại']);
    }
} else {
    echo json_encode(['success' => false, 'error' => 'Không có file hoặc phương thức không đúng']);
}
?>