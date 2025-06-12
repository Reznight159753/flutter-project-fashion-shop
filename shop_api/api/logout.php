<?php
session_start();

// Xóa tất cả dữ liệu session
session_unset();
session_destroy();

echo json_encode([
    'success' => true,
    'message' => 'Vui lòng đăng nhập'
]);
?>