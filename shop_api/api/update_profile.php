<?php
require '../config/database.php';
session_start();

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Kiểm tra đăng nhập
    if (!isset($_SESSION['user_id'])) {
        echo json_encode([
            'success' => false,
            'error' => 'Chưa đăng nhập'
        ]);
        exit;
    }

    $user_id = $_SESSION['user_id'];
    $ho_ten = $_POST['ho_ten'] ?? '';
    $email = $_POST['email'] ?? '';
    $so_dien_thoai = $_POST['so_dien_thoai'] ?? '';
    $dia_chi = $_POST['dia_chi'] ?? '';
    $anh_dai_dien = '';

    // Kiểm tra các trường bắt buộc
    if (empty($ho_ten) || empty($email) || empty($so_dien_thoai) || empty($dia_chi)) {
        echo json_encode([
            'success' => false,
            'error' => 'Vui lòng nhập đầy đủ thông tin bắt buộc'
        ]);
        exit;
    }

    // Xử lý ảnh đại diện nếu được gửi
    if (!empty($_FILES['anh_dai_dien']['name'])) {
        $uploadDir = 'C:/xampp/htdocs/shop_api/images_customer/';
        if (!is_dir($uploadDir)) {
            mkdir($uploadDir, 0777, true);
        }

        $fileName = uniqid() . '_' . basename($_FILES['anh_dai_dien']['name']);
        $uploadPath = $uploadDir . $fileName;

        if (move_uploaded_file($_FILES['anh_dai_dien']['tmp_name'], $uploadPath)) {
            $anh_dai_dien = $fileName;
        } else {
            echo json_encode([
                'success' => false,
                'error' => 'Không thể tải ảnh đại diện'
            ]);
            exit;
        }
    }

    // Cập nhật cơ sở dữ liệu
    try {
        $query = "UPDATE NGUOI_DUNG SET HO_TEN = ?, EMAIL = ?, SO_DIEN_THOAI = ?, DIA_CHI = ?";
        $params = [$ho_ten, $email, $so_dien_thoai, $dia_chi];

        if ($anh_dai_dien !== '') {
            $query .= ", ANH_DAI_DIEN = ?";
            $params[] = $anh_dai_dien;
        }

        $query .= " WHERE MA_NGUOI_DUNG = ?";
        $params[] = $user_id;

        $stmt = $conn->prepare($query);
        $stmt->execute($params);

        echo json_encode([
            'success' => true,
            'message' => 'Cập nhật hồ sơ thành công',
            'anh_dai_dien' => $anh_dai_dien ?: null
        ]);
    } catch (PDOException $e) {
        echo json_encode([
            'success' => false,
            'error' => 'Lỗi cơ sở dữ liệu: ' . $e->getMessage()
        ]);
    }
} else {
    echo json_encode([
        'success' => false,
        'error' => 'Phương thức không được phép'
    ]);
}
?>