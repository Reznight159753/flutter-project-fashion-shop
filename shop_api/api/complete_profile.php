<?php
require '../config/database.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Nhận dữ liệu từ request
    $ho_ten = $_POST['ho_ten'] ?? '';
    $email = $_POST['email'] ?? '';
    $mat_khau = $_POST['mat_khau'] ?? '';
    $so_dien_thoai = $_POST['so_dien_thoai'] ?? '';
    $dia_chi = $_POST['dia_chi'] ?? '';
    $ngay_tao = $_POST['ngay_tao'] ?? '';
    $anh_dai_dien = '';

    // Kiểm tra các trường bắt buộc
    if (empty($ho_ten) || empty($email) || empty($mat_khau) || empty($so_dien_thoai) || empty($dia_chi)) {
        echo json_encode([
            'success' => false,
            'error' => 'Vui lòng nhập đầy đủ thông tin bắt buộc'
        ]);
        exit;
    }

    // Xử lý ảnh đại diện nếu được gửi
    if (!empty($_FILES['anh_dai_dien']['name'])) {
        $uploadDir = 'C:/xampp/htdocs/shop_api/images_customer/';
        // Đảm bảo thư mục tồn tại
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

    // Lưu mật khẩu dạng văn bản thuần
    $mat_khau_plain = $mat_khau;

    // Lưu vào cơ sở dữ liệu
    try {
        $stmt = $conn->prepare("
            INSERT INTO NGUOI_DUNG (HO_TEN, EMAIL, MAT_KHAU, SO_DIEN_THOAI, DIA_CHI, NGAY_TAO, ANH_DAI_DIEN)
            VALUES (?, ?, ?, ?, ?, ?, ?)
        ");
        $stmt->execute([$ho_ten, $email, $mat_khau_plain, $so_dien_thoai, $dia_chi, $ngay_tao, $anh_dai_dien]);

        echo json_encode([
            'success' => true,
            'message' => 'Đăng ký thành công'
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