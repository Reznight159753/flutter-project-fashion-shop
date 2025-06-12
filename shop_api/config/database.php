<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *'); // Cho phép Flutter truy cập
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE');
header('Access-Control-Allow-Headers: Content-Type');

$host = 'localhost';
$username = 'root'; // Mặc định XAMPP là 'root'
$password = ''; // Mặc định XAMPP không có mật khẩu
$database = 'Shop_Nhom2';

try {
    $conn = new PDO("mysql:host=$host;dbname=$database;charset=utf8", $username, $password);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    echo json_encode(['error' => 'Connection failed: ' . $e->getMessage()]);
    exit();
}
?>