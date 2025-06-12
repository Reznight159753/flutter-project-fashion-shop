-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Máy chủ: 127.0.0.1
-- Thời gian đã tạo: Th6 10, 2025 lúc 08:13 AM
-- Phiên bản máy phục vụ: 10.4.32-MariaDB
-- Phiên bản PHP: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Cơ sở dữ liệu: `shop_nhom2`
--

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `chi_tiet_don_hang`
--

CREATE TABLE `chi_tiet_don_hang` (
  `MA_CHI_TIET_DON_HANG` int(11) NOT NULL,
  `MA_DON_HANG` int(11) DEFAULT NULL,
  `MA_SAN_PHAM` int(11) DEFAULT NULL,
  `SO_LUONG` int(11) NOT NULL,
  `DON_GIA` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `chi_tiet_don_hang`
--

INSERT INTO `chi_tiet_don_hang` (`MA_CHI_TIET_DON_HANG`, `MA_DON_HANG`, `MA_SAN_PHAM`, `SO_LUONG`, `DON_GIA`) VALUES
(1, 1, 1, 2, 199000.00),
(2, 1, 6, 1, 299000.00),
(3, 2, 11, 1, 349000.00),
(4, 3, 16, 3, 259000.00),
(5, 4, 21, 2, 199000.00),
(6, 5, 1, 3, 199000.00),
(7, 6, 2, 2, 249000.00),
(8, 7, 18, 1, 249000.00);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `chi_tiet_gio_hang`
--

CREATE TABLE `chi_tiet_gio_hang` (
  `MA_CHI_TIET_GIO_HANG` int(11) NOT NULL,
  `MA_GIO_HANG` int(11) DEFAULT NULL,
  `MA_SAN_PHAM` int(11) DEFAULT NULL,
  `SO_LUONG` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `chi_tiet_gio_hang`
--

INSERT INTO `chi_tiet_gio_hang` (`MA_CHI_TIET_GIO_HANG`, `MA_GIO_HANG`, `MA_SAN_PHAM`, `SO_LUONG`) VALUES
(1, 1, 1, 2),
(2, 1, 6, 1),
(3, 2, 11, 1),
(4, 3, 16, 3),
(5, 4, 21, 2),
(9, 8, 1, 3);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `danh_gia`
--

CREATE TABLE `danh_gia` (
  `MA_DANH_GIA` int(11) NOT NULL,
  `MA_NGUOI_DUNG` int(11) DEFAULT NULL,
  `MA_SAN_PHAM` int(11) DEFAULT NULL,
  `DIEM_DANH_GIA` int(11) DEFAULT NULL CHECK (`DIEM_DANH_GIA` >= 1 and `DIEM_DANH_GIA` <= 5),
  `BINH_LUAN` text DEFAULT NULL,
  `NGAY_TAO` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `danh_gia`
--

INSERT INTO `danh_gia` (`MA_DANH_GIA`, `MA_NGUOI_DUNG`, `MA_SAN_PHAM`, `DIEM_DANH_GIA`, `BINH_LUAN`, `NGAY_TAO`) VALUES
(1, 1, 1, 5, 'Áo rất mềm mại, mặc thoải mái, đáng tiền!', '2025-04-05 01:00:00'),
(2, 1, 6, 4, 'Áo đẹp, nhưng hơi chật ở phần vai.', '2025-04-05 01:05:00'),
(3, 2, 11, 5, 'Áo sơ mi chất lượng, rất lịch lãm.', '2025-04-06 03:00:00'),
(4, 3, 16, 3, 'Áo thể thao co giãn tốt, nhưng màu hơi phai sau khi giặt.', '2025-04-07 07:30:00');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `danh_muc`
--

CREATE TABLE `danh_muc` (
  `MA_DANH_MUC` int(11) NOT NULL,
  `TEN_DANH_MUC` varchar(100) NOT NULL,
  `MO_TA` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `danh_muc`
--

INSERT INTO `danh_muc` (`MA_DANH_MUC`, `TEN_DANH_MUC`, `MO_TA`) VALUES
(1, 'Áo Thun', 'Áo thun nam với thiết kế đơn giản, thoải mái, phù hợp cho mọi hoạt động hàng ngày.'),
(2, 'Áo Polo', 'Áo polo nam kết hợp giữa sự thanh lịch và năng động, phù hợp cho cả dịp trang trọng lẫn phong cách casual.'),
(3, 'Áo Sơ Mi', 'Áo sơ mi nam phong cách lịch lãm, sang trọng, lý tưởng cho công việc và các sự kiện trang trọng.'),
(4, 'Áo Thể Thao', 'Áo thể thao nam chất liệu thoáng mát, co giãn tốt, phù hợp cho các hoạt động thể thao và vận động mạnh.'),
(5, 'Áo Tanktop', 'Áo tanktop nam không tay, thoáng mát, thích hợp cho các hoạt động thể thao hoặc thời tiết nóng bức.'),
(6, 'Áo Khoác', 'Áo khoác nam giữ ấm tốt, bảo vệ cơ thể khỏi gió lạnh, đồng thời mang lại phong cách mạnh mẽ và năng động.'),
(7, 'Túi Sách', 'Túi sách nam và nữ với thiết kế thời trang, tiện dụng, phù hợp cho học tập và công việc.');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `don_hang`
--

CREATE TABLE `don_hang` (
  `MA_DON_HANG` int(11) NOT NULL,
  `MA_NGUOI_DUNG` int(11) DEFAULT NULL,
  `TONG_TIEN` decimal(10,2) NOT NULL,
  `DIA_CHI_GIAO_HANG` text NOT NULL,
  `PHUONG_THUC_THANH_TOAN` enum('VI_DIEN_TU','THE_NGAN_HANG','COD') NOT NULL,
  `TRANG_THAI_DON_HANG` enum('CHO_XU_LY','DANG_XU_LY','DA_GIAO','HOAN_THANH','DA_HUY','CHUA_THANH_TOAN') DEFAULT 'CHO_XU_LY',
  `NGAY_TAO` timestamp NOT NULL DEFAULT current_timestamp(),
  `MA_GIAM_GIA` varchar(50) DEFAULT NULL,
  `SO_TIEN_GIAM` decimal(10,2) DEFAULT 0.00
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `don_hang`
--

INSERT INTO `don_hang` (`MA_DON_HANG`, `MA_NGUOI_DUNG`, `TONG_TIEN`, `DIA_CHI_GIAO_HANG`, `PHUONG_THUC_THANH_TOAN`, `TRANG_THAI_DON_HANG`, `NGAY_TAO`, `MA_GIAM_GIA`, `SO_TIEN_GIAM`) VALUES
(1, 1, 597000.00, '123 Đường Láng, Đống Đa, Hà Nội', 'COD', 'HOAN_THANH', '2025-04-01 03:00:00', NULL, 0.00),
(2, 2, 319000.00, '45 Nguyễn Huệ, TP Huế', 'VI_DIEN_TU', 'DA_GIAO', '2025-04-02 07:30:00', 'SPRING2025', 30000.00),
(3, 3, 777000.00, '78 Lê Lợi, Quận 1, TP.HCM', 'THE_NGAN_HANG', 'DANG_XU_LY', '2025-04-03 02:15:00', NULL, 0.00),
(4, 4, 398000.00, '56 Trần Phú, Nha Trang', 'COD', 'DA_HUY', '2025-04-04 09:20:00', NULL, 0.00),
(5, 6, 597000.00, '182 BS', 'VI_DIEN_TU', 'CHUA_THANH_TOAN', '2025-06-07 07:47:32', NULL, 0.00),
(6, 7, 498000.00, '182', 'COD', 'DA_GIAO', '2025-06-07 13:30:37', NULL, 0.00),
(7, 7, 249000.00, '182', 'COD', 'CHO_XU_LY', '2025-06-07 15:16:06', NULL, 0.00);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `gio_hang`
--

CREATE TABLE `gio_hang` (
  `MA_GIO_HANG` int(11) NOT NULL,
  `MA_NGUOI_DUNG` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `gio_hang`
--

INSERT INTO `gio_hang` (`MA_GIO_HANG`, `MA_NGUOI_DUNG`) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(8, 7);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `ma_giam_gia`
--

CREATE TABLE `ma_giam_gia` (
  `MA_CODE` int(11) NOT NULL,
  `MA` varchar(50) NOT NULL,
  `GIA_TRI_GIAM` decimal(10,2) NOT NULL,
  `SO_LAN_SU_DUNG_TOI_DA` int(11) NOT NULL,
  `SO_LAN_DA_SU_DUNG` int(11) DEFAULT 0,
  `NGAY_HET_HAN` datetime NOT NULL,
  `NGAY_TAO` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `ma_giam_gia`
--

INSERT INTO `ma_giam_gia` (`MA_CODE`, `MA`, `GIA_TRI_GIAM`, `SO_LAN_SU_DUNG_TOI_DA`, `SO_LAN_DA_SU_DUNG`, `NGAY_HET_HAN`, `NGAY_TAO`) VALUES
(1, 'SPRING2025', 30000.00, 100, 1, '2025-03-15 23:59:59', '2025-02-20 03:00:00'),
(2, 'FLASHAPRIL', 50000.00, 50, 0, '2025-07-30 23:59:59', '2025-03-25 07:00:00'),
(3, 'SUMMER2025', 20000.00, 200, 0, '2025-07-31 23:59:59', '2025-04-20 02:00:00');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `nguoi_dung`
--

CREATE TABLE `nguoi_dung` (
  `MA_NGUOI_DUNG` int(11) NOT NULL,
  `HO_TEN` varchar(255) NOT NULL,
  `EMAIL` varchar(255) NOT NULL,
  `SO_DIEN_THOAI` varchar(20) NOT NULL,
  `MAT_KHAU` varchar(255) NOT NULL,
  `ANH_DAI_DIEN` varchar(255) DEFAULT NULL,
  `DIA_CHI` text DEFAULT NULL,
  `NGAY_TAO` timestamp NOT NULL DEFAULT current_timestamp(),
  `TRANG_THAI` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `nguoi_dung`
--

INSERT INTO `nguoi_dung` (`MA_NGUOI_DUNG`, `HO_TEN`, `EMAIL`, `SO_DIEN_THOAI`, `MAT_KHAU`, `ANH_DAI_DIEN`, `DIA_CHI`, `NGAY_TAO`, `TRANG_THAI`) VALUES
(1, 'Nguyễn Văn An', 'an.nguyen@gmail.com', '0909123456', 'hashed_password_1', 'avatar_an.jpg', '123 Đường Láng, Đống Đa, Hà Nội', '2025-01-01 03:00:00', 1),
(2, 'Trần Thị Bình', 'binh.tran@gmail.com', '0918234567', 'hashed_password_2', 'avatar_binh.jpg', '45 Nguyễn Huệ, TP Huế', '2025-01-02 07:30:00', 1),
(3, 'Lê Minh Cường', 'cuong.le@gmail.com', '0927345678', 'hashed_password_3', 'avatar_cuong.jpg', '78 Lê Lợi, Quận 1, TP.HCM', '2025-01-03 02:15:00', 1),
(4, 'Phạm Thị Dung', 'dung.pham@gmail.com', '0936456789', 'hashed_password_4', 'avatar_dung.jpg', '56 Trần Phú, Nha Trang', '2025-01-04 09:20:00', 1),
(5, 'Admin Shop', 'admin@shopnhom2.com', '0945567890', 'admin_hashed_password', 'avatar_admin.jpg', 'Tòa nhà Shop Nhóm 2, Hà Nội', '2025-01-01 01:00:00', 1),
(6, 'Thái Tấn Khang', 'khang@gmail.com', '0868050173', '123', '6843ee5ead597_1744.jpg', '182 BS', '2025-06-07 07:46:37', 1),
(7, 'a', 'a@gmail.com', '6', '1234', '6847c822b2248_14ca084c-1b58-4b16-b1ea-c8c121ad85cf6576052323676564168.jpg', '182', '2025-06-07 13:27:52', 1),
(9, 'a', 'a1@gmail.com', '0868050174', '123', '6847ac437e04d_1744.jpg', '182BS', '2025-06-10 03:53:38', 1);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `san_pham`
--

CREATE TABLE `san_pham` (
  `MA_SAN_PHAM` int(11) NOT NULL,
  `MA_DANH_MUC` int(11) DEFAULT NULL,
  `TEN_SAN_PHAM` varchar(255) NOT NULL,
  `MO_TA` text DEFAULT NULL,
  `GIA_BAN` decimal(10,2) NOT NULL,
  `SO_LUONG_TON` int(11) NOT NULL,
  `HINH_ANH` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `san_pham`
--

INSERT INTO `san_pham` (`MA_SAN_PHAM`, `MA_DANH_MUC`, `TEN_SAN_PHAM`, `MO_TA`, `GIA_BAN`, `SO_LUONG_TON`, `HINH_ANH`) VALUES
(1, 1, 'Áo Thun Cotton Compact', 'Áo thun nam Cotton Compact với chất liệu 95% Cotton Compact và 5% Spandex, mang lại cảm giác mềm mại và dễ chịu.', 199000.00, 97, 'ao_thun_1.jpg'),
(2, 1, 'Áo Thun Gym Powerfit', 'Áo thun Gym Powerfit dành cho hoạt động thể chất, chất liệu 86% Polyester Recycled và 14% Spandex, co giãn 4 chiều.', 249000.00, 78, 'ao_thun_2.jpg'),
(3, 1, 'Áo Thun Excool', 'Áo thun Excool với công nghệ sợi Sorona độc quyền, mềm mại và khô nhanh, phù hợp cho thời tiết nóng ẩm.', 219000.00, 90, 'ao_thun_3.jpg'),
(4, 1, 'Áo Thun Modal', 'Áo thun Modal làm từ sợi gỗ sồi, mềm mại và thân thiện với môi trường.', 229000.00, 70, 'ao_thun_4.jpg'),
(5, 1, 'Áo Thun Ice Cooling', 'Áo thun Ice Cooling với công nghệ làm mát, giúp cơ thể luôn mát mẻ trong thời tiết nóng.', 239000.00, 60, 'ao_thun_5.jpg'),
(6, 2, 'Áo Polo Cafe', 'Áo polo nam Cafe khử mùi, kháng khuẩn, làm từ vải sợi tái tạo từ bã cà phê và chai nhựa.', 299000.00, 100, 'ao_polo_1.jpg'),
(7, 2, 'Áo Polo Excool', 'Áo polo Excool với chất liệu thoáng mát, co giãn tốt, phù hợp cho các hoạt động hàng ngày.', 279000.00, 90, 'ao_polo_2.jpg'),
(8, 2, 'Áo Polo Cotton Compact', 'Áo polo Cotton Compact với chất liệu cao cấp, mang lại cảm giác êm ái và khả năng chống nhăn.', 289000.00, 80, 'ao_polo_3.jpg'),
(9, 2, 'Áo Polo Modal', 'Áo polo Modal làm từ sợi gỗ sồi, mềm mại và thân thiện với môi trường.', 269000.00, 70, 'ao_polo_4.jpg'),
(10, 2, 'Áo Polo Ice Cooling', 'Áo polo Ice Cooling với công nghệ làm mát, giúp cơ thể luôn mát mẻ trong thời tiết nóng.', 289000.00, 60, 'ao_polo_5.jpg'),
(11, 3, 'Áo Sơ Mi Dài Tay Essentials Cotton', 'Áo sơ mi dài tay Essentials Cotton với chất liệu 100% cotton mềm mại, thoáng mát và thấm hút mồ hôi tốt.', 349000.00, 100, 'ao_so_mi_1.jpg'),
(12, 3, 'Áo Sơ Mi Ngắn Tay Excool', 'Áo sơ mi ngắn tay Excool với chất liệu thoáng mát, phù hợp cho thời tiết nóng.', 329000.00, 90, 'ao_so_mi_2.jpg'),
(13, 3, 'Áo Sơ Mi Dài Tay Modal', 'Áo sơ mi dài tay Modal làm từ sợi gỗ sồi, mềm mại và thân thiện với môi trường.', 359000.00, 80, 'ao_so_mi_3.jpg'),
(14, 3, 'Áo Sơ Mi Ngắn Tay Cotton Compact', 'Áo sơ mi ngắn tay Cotton Compact với chất liệu cao cấp, mang lại cảm giác êm ái và khả năng chống nhăn.', 339000.00, 70, 'ao_so_mi_4.jpg'),
(15, 3, 'Áo Sơ Mi Dài Tay Ice Cooling', 'Áo sơ mi dài tay Ice Cooling với công nghệ làm mát, giúp cơ thể luôn mát mẻ trong thời tiết nóng.', 369000.00, 60, 'ao_so_mi_5.jpg'),
(16, 4, 'Áo Thể Thao Promax-S1', 'Áo thể thao Promax-S1 với chất liệu thoáng mát, co giãn tốt, phù hợp cho các hoạt động thể thao.', 259000.00, 100, 'ao_the_thao_1.jpg'),
(17, 4, 'Áo Thể Thao Excool', 'Áo thể thao Excool với công nghệ sợi Sorona độc quyền, mềm mại và khô nhanh, phù hợp cho thời tiết nóng ẩm.', 239000.00, 90, 'ao_the_thao_2.jpg'),
(18, 4, 'Áo Thể Thao Modal', 'Áo thể thao Modal làm từ sợi gỗ sồi, mềm mại và thân thiện với môi trường.', 249000.00, 79, 'ao_the_thao_3.jpg'),
(19, 4, 'Áo Thể Thao Ice Cooling', 'Áo thể thao Ice Cooling với công nghệ làm mát, giúp cơ thể luôn mát mẻ trong thời tiết nóng.', 269000.00, 70, 'ao_the_thao_4.jpg'),
(20, 4, 'Áo Thể Thao Cotton Compact', 'Áo thể thao Cotton Compact với chất liệu cao cấp, mang lại cảm giác êm ái và khả năng chống nhăn.', 259000.00, 60, 'ao_the_thao_5.jpg'),
(21, 5, 'Áo Tanktop Thể Thao T2', 'Áo tanktop nam thể thao T2 với chất liệu 100% Polyester, tính năng Quick Dry giúp thấm hút mồ hôi hiệu quả và thoát nhiệt tốt.', 199000.00, 100, 'ao_tanktop_1.jpg'),
(22, 5, 'Áo Tanktop Modal', 'Áo tanktop Modal làm từ sợi gỗ sồi, mềm mại và thân thiện với môi trường.', 189000.00, 90, 'ao_tanktop_2.jpg'),
(23, 5, 'Áo Tanktop Excool', 'Áo tanktop Excool với công nghệ sợi Sorona độc quyền, mềm mại và khô nhanh, phù hợp cho thời tiết nóng ẩm.', 179000.00, 80, 'ao_tanktop_3.jpg'),
(24, 5, 'Áo Tanktop Ice Cooling', 'Áo tanktop Ice Cooling với công nghệ làm mát, giúp cơ thể luôn mát mẻ trong thời tiết nóng.', 189000.00, 70, 'ao_tanktop_4.jpg'),
(25, 5, 'Áo Tanktop Cotton Compact', 'Áo tanktop Cotton Compact với chất liệu cao cấp, mang lại cảm giác êm ái và khả năng chống nhăn.', 199000.00, 60, 'ao_tanktop_5.jpg'),
(26, 6, 'Áo Khoác Nỉ Basic', 'Áo khoác nỉ Basic giữ ấm tốt, phù hợp cho thời tiết lạnh, mang lại phong cách năng động.', 399000.00, 100, 'ao_khoac_1.jpg'),
(27, 6, 'Áo Khoác Gió Excool', 'Áo khoác gió Excool với chất liệu thoáng mát, chống thấm nước nhẹ, phù hợp cho các hoạt động ngoài trời.', 429000.00, 90, 'ao_khoac_2.jpg'),
(28, 6, 'Áo Khoác Dù Modal', 'Áo khoác dù Modal làm từ sợi gỗ sồi, mềm mại và thân thiện với môi trường.', 449000.00, 80, 'ao_khoac_3.jpg'),
(29, 6, 'Áo Khoác Ice Cooling', 'Áo khoác Ice Cooling với công nghệ làm mát, giúp cơ thể luôn mát mẻ trong thời tiết nóng.', 459000.00, 70, 'ao_khoac_4.jpg'),
(30, 6, 'Áo Khoác Cotton Compact', 'Áo khoác Cotton Compact với chất liệu cao cấp, mang lại cảm giác êm ái và khả năng chống nhăn.', 479000.00, 60, 'ao_khoac_5.jpg'),
(31, 7, 'Túi Sách Đeo Chéo Basic', 'Túi đeo chéo thời trang, chất liệu vải polyester chống thấm, phù hợp cho cả nam và nữ.', 299000.00, 100, 'bag_1.png'),
(32, 7, 'Túi Sách Laptop Excool', 'Túi đựng laptop với lớp đệm chống sốc, chất liệu thoáng mát, thiết kế tối giản.', 399000.00, 80, 'bag_2.png'),
(33, 7, 'Túi Sách Du Lịch Modal', 'Túi sách du lịch làm từ sợi gỗ sồi, nhẹ và bền, thân thiện với môi trường.', 349000.00, 90, 'bag_3.png'),
(34, 7, 'Túi Sách Thể Thao Promax', 'Túi sách thể thao với ngăn đựng giày riêng, chất liệu co giãn, phù hợp cho gym.', 329000.00, 70, 'bag_4.png'),
(35, 7, 'Túi Sách Cotton Compact', 'Túi sách thời trang với chất liệu cotton cao cấp, chống nhăn, phù hợp công việc.', 379000.00, 60, 'bag_5.png'),
(36, 7, 'Túi Sách Ice Cooling', 'Túi sách công nghệ làm mát, thoáng khí, thích hợp cho thời tiết nóng.', 359000.00, 50, 'bag_6.png');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `su_kien_khuyen_mai`
--

CREATE TABLE `su_kien_khuyen_mai` (
  `MA_SU_KIEN` int(11) NOT NULL,
  `TEN_SU_KIEN` varchar(255) NOT NULL,
  `MO_TA` text DEFAULT NULL,
  `TY_LE_GIAM_GIA` decimal(5,2) DEFAULT NULL,
  `NGAY_BAT_DAU` datetime NOT NULL,
  `NGAY_KET_THUC` datetime NOT NULL,
  `NGAY_TAO` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `su_kien_khuyen_mai`
--

INSERT INTO `su_kien_khuyen_mai` (`MA_SU_KIEN`, `TEN_SU_KIEN`, `MO_TA`, `TY_LE_GIAM_GIA`, `NGAY_BAT_DAU`, `NGAY_KET_THUC`, `NGAY_TAO`) VALUES
(1, 'Khuyến mãi mùa xuân 2025', 'Giảm giá toàn bộ sản phẩm mùa xuân, áp dụng cho tất cả danh mục.', 20.00, '2025-03-01 00:00:00', '2025-03-15 23:59:59', '2025-02-20 03:00:00'),
(2, 'Flash Sale tháng 4', 'Giảm giá mạnh cho các sản phẩm thể thao và áo khoác.', 30.00, '2025-04-01 00:00:00', '2025-04-03 23:59:59', '2025-03-25 07:00:00'),
(3, 'Ưu đãi hè 2025', 'Giảm giá áo thun và tanktop, chuẩn bị cho mùa hè năng động.', 15.00, '2025-05-01 00:00:00', '2025-06-30 23:59:59', '2025-04-20 02:00:00');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `yeu_thich`
--

CREATE TABLE `yeu_thich` (
  `MA_NGUOI_DUNG` int(11) NOT NULL,
  `MA_SAN_PHAM` int(11) NOT NULL,
  `NGAY_THEM` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `yeu_thich`
--

INSERT INTO `yeu_thich` (`MA_NGUOI_DUNG`, `MA_SAN_PHAM`, `NGAY_THEM`) VALUES
(7, 2, '2025-06-07 14:34:52'),
(7, 14, '2025-06-07 13:33:50');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `y_kien_khach_hang`
--

CREATE TABLE `y_kien_khach_hang` (
  `MA_Y_KIEN` int(11) NOT NULL,
  `MA_NGUOI_DUNG` int(11) DEFAULT NULL,
  `NOI_DUNG` text NOT NULL,
  `NGAY_GUI` timestamp NOT NULL DEFAULT current_timestamp(),
  `TRANG_THAI` enum('CHUA_XU_LY','DA_XU_LY') DEFAULT 'CHUA_XU_LY'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `y_kien_khach_hang`
--

INSERT INTO `y_kien_khach_hang` (`MA_Y_KIEN`, `MA_NGUOI_DUNG`, `NOI_DUNG`, `NGAY_GUI`, `TRANG_THAI`) VALUES
(1, 1, 'Tôi muốn đổi size áo, shop hỗ trợ được không?', '2025-04-05 02:00:00', 'DA_XU_LY'),
(2, 2, 'Giao hàng nhanh, nhưng đóng gói hơi sơ sài.', '2025-04-06 04:00:00', 'CHUA_XU_LY'),
(3, 4, 'Tại sao đơn hàng của tôi bị hủy? Tôi cần giải thích!', '2025-04-04 10:00:00', 'DA_XU_LY');

--
-- Chỉ mục cho các bảng đã đổ
--

--
-- Chỉ mục cho bảng `chi_tiet_don_hang`
--
ALTER TABLE `chi_tiet_don_hang`
  ADD PRIMARY KEY (`MA_CHI_TIET_DON_HANG`),
  ADD KEY `MA_DON_HANG` (`MA_DON_HANG`),
  ADD KEY `MA_SAN_PHAM` (`MA_SAN_PHAM`);

--
-- Chỉ mục cho bảng `chi_tiet_gio_hang`
--
ALTER TABLE `chi_tiet_gio_hang`
  ADD PRIMARY KEY (`MA_CHI_TIET_GIO_HANG`),
  ADD KEY `MA_GIO_HANG` (`MA_GIO_HANG`),
  ADD KEY `MA_SAN_PHAM` (`MA_SAN_PHAM`);

--
-- Chỉ mục cho bảng `danh_gia`
--
ALTER TABLE `danh_gia`
  ADD PRIMARY KEY (`MA_DANH_GIA`),
  ADD KEY `MA_NGUOI_DUNG` (`MA_NGUOI_DUNG`),
  ADD KEY `MA_SAN_PHAM` (`MA_SAN_PHAM`);

--
-- Chỉ mục cho bảng `danh_muc`
--
ALTER TABLE `danh_muc`
  ADD PRIMARY KEY (`MA_DANH_MUC`);

--
-- Chỉ mục cho bảng `don_hang`
--
ALTER TABLE `don_hang`
  ADD PRIMARY KEY (`MA_DON_HANG`),
  ADD KEY `MA_NGUOI_DUNG` (`MA_NGUOI_DUNG`);

--
-- Chỉ mục cho bảng `gio_hang`
--
ALTER TABLE `gio_hang`
  ADD PRIMARY KEY (`MA_GIO_HANG`),
  ADD KEY `MA_NGUOI_DUNG` (`MA_NGUOI_DUNG`);

--
-- Chỉ mục cho bảng `ma_giam_gia`
--
ALTER TABLE `ma_giam_gia`
  ADD PRIMARY KEY (`MA_CODE`),
  ADD UNIQUE KEY `MA` (`MA`);

--
-- Chỉ mục cho bảng `nguoi_dung`
--
ALTER TABLE `nguoi_dung`
  ADD PRIMARY KEY (`MA_NGUOI_DUNG`),
  ADD UNIQUE KEY `EMAIL` (`EMAIL`),
  ADD UNIQUE KEY `SO_DIEN_THOAI` (`SO_DIEN_THOAI`);

--
-- Chỉ mục cho bảng `san_pham`
--
ALTER TABLE `san_pham`
  ADD PRIMARY KEY (`MA_SAN_PHAM`),
  ADD KEY `MA_DANH_MUC` (`MA_DANH_MUC`);

--
-- Chỉ mục cho bảng `su_kien_khuyen_mai`
--
ALTER TABLE `su_kien_khuyen_mai`
  ADD PRIMARY KEY (`MA_SU_KIEN`);

--
-- Chỉ mục cho bảng `yeu_thich`
--
ALTER TABLE `yeu_thich`
  ADD PRIMARY KEY (`MA_NGUOI_DUNG`,`MA_SAN_PHAM`),
  ADD KEY `MA_SAN_PHAM` (`MA_SAN_PHAM`);

--
-- Chỉ mục cho bảng `y_kien_khach_hang`
--
ALTER TABLE `y_kien_khach_hang`
  ADD PRIMARY KEY (`MA_Y_KIEN`),
  ADD KEY `MA_NGUOI_DUNG` (`MA_NGUOI_DUNG`);

--
-- AUTO_INCREMENT cho các bảng đã đổ
--

--
-- AUTO_INCREMENT cho bảng `chi_tiet_don_hang`
--
ALTER TABLE `chi_tiet_don_hang`
  MODIFY `MA_CHI_TIET_DON_HANG` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT cho bảng `chi_tiet_gio_hang`
--
ALTER TABLE `chi_tiet_gio_hang`
  MODIFY `MA_CHI_TIET_GIO_HANG` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT cho bảng `danh_gia`
--
ALTER TABLE `danh_gia`
  MODIFY `MA_DANH_GIA` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT cho bảng `danh_muc`
--
ALTER TABLE `danh_muc`
  MODIFY `MA_DANH_MUC` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT cho bảng `don_hang`
--
ALTER TABLE `don_hang`
  MODIFY `MA_DON_HANG` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT cho bảng `gio_hang`
--
ALTER TABLE `gio_hang`
  MODIFY `MA_GIO_HANG` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT cho bảng `ma_giam_gia`
--
ALTER TABLE `ma_giam_gia`
  MODIFY `MA_CODE` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT cho bảng `nguoi_dung`
--
ALTER TABLE `nguoi_dung`
  MODIFY `MA_NGUOI_DUNG` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT cho bảng `san_pham`
--
ALTER TABLE `san_pham`
  MODIFY `MA_SAN_PHAM` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=37;

--
-- AUTO_INCREMENT cho bảng `su_kien_khuyen_mai`
--
ALTER TABLE `su_kien_khuyen_mai`
  MODIFY `MA_SU_KIEN` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT cho bảng `y_kien_khach_hang`
--
ALTER TABLE `y_kien_khach_hang`
  MODIFY `MA_Y_KIEN` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- Các ràng buộc cho các bảng đã đổ
--

--
-- Các ràng buộc cho bảng `chi_tiet_don_hang`
--
ALTER TABLE `chi_tiet_don_hang`
  ADD CONSTRAINT `chi_tiet_don_hang_ibfk_1` FOREIGN KEY (`MA_DON_HANG`) REFERENCES `don_hang` (`MA_DON_HANG`),
  ADD CONSTRAINT `chi_tiet_don_hang_ibfk_2` FOREIGN KEY (`MA_SAN_PHAM`) REFERENCES `san_pham` (`MA_SAN_PHAM`);

--
-- Các ràng buộc cho bảng `chi_tiet_gio_hang`
--
ALTER TABLE `chi_tiet_gio_hang`
  ADD CONSTRAINT `chi_tiet_gio_hang_ibfk_1` FOREIGN KEY (`MA_GIO_HANG`) REFERENCES `gio_hang` (`MA_GIO_HANG`),
  ADD CONSTRAINT `chi_tiet_gio_hang_ibfk_2` FOREIGN KEY (`MA_SAN_PHAM`) REFERENCES `san_pham` (`MA_SAN_PHAM`);

--
-- Các ràng buộc cho bảng `danh_gia`
--
ALTER TABLE `danh_gia`
  ADD CONSTRAINT `danh_gia_ibfk_1` FOREIGN KEY (`MA_NGUOI_DUNG`) REFERENCES `nguoi_dung` (`MA_NGUOI_DUNG`),
  ADD CONSTRAINT `danh_gia_ibfk_2` FOREIGN KEY (`MA_SAN_PHAM`) REFERENCES `san_pham` (`MA_SAN_PHAM`);

--
-- Các ràng buộc cho bảng `don_hang`
--
ALTER TABLE `don_hang`
  ADD CONSTRAINT `don_hang_ibfk_1` FOREIGN KEY (`MA_NGUOI_DUNG`) REFERENCES `nguoi_dung` (`MA_NGUOI_DUNG`);

--
-- Các ràng buộc cho bảng `gio_hang`
--
ALTER TABLE `gio_hang`
  ADD CONSTRAINT `gio_hang_ibfk_1` FOREIGN KEY (`MA_NGUOI_DUNG`) REFERENCES `nguoi_dung` (`MA_NGUOI_DUNG`);

--
-- Các ràng buộc cho bảng `san_pham`
--
ALTER TABLE `san_pham`
  ADD CONSTRAINT `san_pham_ibfk_1` FOREIGN KEY (`MA_DANH_MUC`) REFERENCES `danh_muc` (`MA_DANH_MUC`);

--
-- Các ràng buộc cho bảng `yeu_thich`
--
ALTER TABLE `yeu_thich`
  ADD CONSTRAINT `yeu_thich_ibfk_1` FOREIGN KEY (`MA_NGUOI_DUNG`) REFERENCES `nguoi_dung` (`MA_NGUOI_DUNG`),
  ADD CONSTRAINT `yeu_thich_ibfk_2` FOREIGN KEY (`MA_SAN_PHAM`) REFERENCES `san_pham` (`MA_SAN_PHAM`);

--
-- Các ràng buộc cho bảng `y_kien_khach_hang`
--
ALTER TABLE `y_kien_khach_hang`
  ADD CONSTRAINT `y_kien_khach_hang_ibfk_1` FOREIGN KEY (`MA_NGUOI_DUNG`) REFERENCES `nguoi_dung` (`MA_NGUOI_DUNG`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
