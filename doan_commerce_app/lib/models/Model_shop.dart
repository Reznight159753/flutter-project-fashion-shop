class Product {
  final int id;
  final int categoryId;
  final String title;
  final String description;
  final double price;
  final int stock;
  final String image;

  Product({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.description,
    required this.price,
    required this.stock,
    required this.image,
  });

  // Thêm fromJson để ánh xạ từ JSON (nếu cần)
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: int.parse(json['MA_SAN_PHAM'].toString()),
      categoryId: int.parse(json['MA_DANH_MUC'].toString()),
      title: json['TEN_SAN_PHAM'],
      price: double.parse(json['GIA_BAN'].toString()),
      description: json['MO_TA'] ?? '',
      stock: int.parse(json['SO_LUONG_TON'].toString()),
      image: 'http://10.0.2.2/shop_api/images/${json['HINH_ANH']}',
    );
  }
}

class Category {
  final int maDanhMuc;
  final String tenDanhMuc;
  final String? moTa;

  Category({
    required this.maDanhMuc,
    required this.tenDanhMuc,
    this.moTa,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      maDanhMuc: int.parse(json['MA_DANH_MUC'].toString()), // Thêm int.parse để đảm bảo kiểu int
      tenDanhMuc: json['TEN_DANH_MUC'],
      moTa: json['MO_TA'],
    );
  }
}

class NguoiDung {
  final int maNguoiDung;
  final String hoTen;
  final String email;
  final String soDienThoai;
  final String matKhau;
  final String? anhDaiDien;
  final String? diaChi;
  final DateTime ngayTao;
  final bool trangThai;

  NguoiDung({
    required this.maNguoiDung,
    required this.hoTen,
    required this.email,
    required this.soDienThoai,
    required this.matKhau,
    this.anhDaiDien,
    this.diaChi,
    required this.ngayTao,
    required this.trangThai,
  });

  factory NguoiDung.fromJson(Map<String, dynamic> json) {
    return NguoiDung(
      maNguoiDung: int.parse(json['MA_NGUOI_DUNG'].toString()),
      hoTen: json['HO_TEN'],
      email: json['EMAIL'],
      soDienThoai: json['SO_DIEN_THOAI'],
      matKhau: json['MAT_KHAU'],
      anhDaiDien: json['ANH_DAI_DIEN'],
      diaChi: json['DIA_CHI'],
      ngayTao: DateTime.parse(json['NGAY_TAO']),
      trangThai: json['TRANG_THAI'] == 1,
    );
  }
}

class GioHang {
  final int maGioHang;
  final int? maNguoiDung;

  GioHang({
    required this.maGioHang,
    this.maNguoiDung,
  });

  factory GioHang.fromJson(Map<String, dynamic> json) {
    return GioHang(
      maGioHang: int.parse(json['MA_GIO_HANG'].toString()),
      maNguoiDung: json['MA_NGUOI_DUNG'],
    );
  }
}

class ChiTietGioHang {
  final int maChiTietGioHang;
  final int maGioHang;
  final int maSanPham;
  final int soLuong;

  ChiTietGioHang({
    required this.maChiTietGioHang,
    required this.maGioHang,
    required this.maSanPham,
    required this.soLuong,
  });

  factory ChiTietGioHang.fromJson(Map<String, dynamic> json) {
    return ChiTietGioHang(
      maChiTietGioHang: int.parse(json['MA_CHI_TIET_GIO_HANG'].toString()),
      maGioHang: int.parse(json['MA_GIO_HANG'].toString()),
      maSanPham: int.parse(json['MA_SAN_PHAM'].toString()),
      soLuong: int.parse(json['SO_LUONG'].toString()),
    );
  }
}

class DonHang {
  final int maDonHang;
  final int? maNguoiDung;
  final double tongTien;
  final String diaChiGiaoHang;
  final String phuongThucThanhToan;
  final String trangThaiDonHang;
  final DateTime ngayTao;
  final String? maGiamGia;
  final double? soTienGiam;

  DonHang({
    required this.maDonHang,
    this.maNguoiDung,
    required this.tongTien,
    required this.diaChiGiaoHang,
    required this.phuongThucThanhToan,
    required this.trangThaiDonHang,
    required this.ngayTao,
    this.maGiamGia,
    this.soTienGiam,
  });

  factory DonHang.fromJson(Map<String, dynamic> json) {
    return DonHang(
      maDonHang: int.parse(json['MA_DON_HANG'].toString()),
      maNguoiDung: json['MA_NGUOI_DUNG'],
      tongTien: double.parse(json['TONG_TIEN'].toString()),
      diaChiGiaoHang: json['DIA_CHI_GIAO_HANG'],
      phuongThucThanhToan: json['PHUONG_THUC_THANH_TOAN'],
      trangThaiDonHang: json['TRANG_THAI_DON_HANG'],
      ngayTao: DateTime.parse(json['NGAY_TAO']),
      maGiamGia: json['MA_GIAM_GIA'],
      soTienGiam: json['SO_TIEN_GIAM'] != null ? double.parse(json['SO_TIEN_GIAM'].toString()) : null,
    );
  }
}

class ChiTietDonHang {
  final int maChiTietDonHang;
  final int maDonHang;
  final int maSanPham;
  final int soLuong;
  final double donGia;

  ChiTietDonHang({
    required this.maChiTietDonHang,
    required this.maDonHang,
    required this.maSanPham,
    required this.soLuong,
    required this.donGia,
  });

  factory ChiTietDonHang.fromJson(Map<String, dynamic> json) {
    return ChiTietDonHang(
      maChiTietDonHang: int.parse(json['MA_CHI_TIET_DON_HANG'].toString()),
      maDonHang: int.parse(json['MA_DON_HANG'].toString()),
      maSanPham: int.parse(json['MA_SAN_PHAM'].toString()),
      soLuong: int.parse(json['SO_LUONG'].toString()),
      donGia: double.parse(json['DON_GIA'].toString()),
    );
  }
}

class DanhGia {
  final int maDanhGia;
  final int? maNguoiDung;
  final int? maSanPham;
  final int diemDanhGia;
  final String? binhLuan;
  final DateTime ngayTao;

  DanhGia({
    required this.maDanhGia,
    this.maNguoiDung,
    this.maSanPham,
    required this.diemDanhGia,
    this.binhLuan,
    required this.ngayTao,
  });

  factory DanhGia.fromJson(Map<String, dynamic> json) {
    return DanhGia(
      maDanhGia: int.parse(json['MA_DANH_GIA'].toString()),
      maNguoiDung: json['MA_NGUOI_DUNG'],
      maSanPham: json['MA_SAN_PHAM'],
      diemDanhGia: int.parse(json['DIEM_DANH_GIA'].toString()),
      binhLuan: json['BINH_LUAN'],
      ngayTao: DateTime.parse(json['NGAY_TAO']),
    );
  }
}

class YKienKhachHang {
  final int maYKien;
  final int? maNguoiDung;
  final String noiDung;
  final DateTime ngayGui;
  final String trangThai;

  YKienKhachHang({
    required this.maYKien,
    this.maNguoiDung,
    required this.noiDung,
    required this.ngayGui,
    required this.trangThai,
  });

  factory YKienKhachHang.fromJson(Map<String, dynamic> json) {
    return YKienKhachHang(
      maYKien: int.parse(json['MA_Y_KIEN'].toString()),
      maNguoiDung: json['MA_NGUOI_DUNG'],
      noiDung: json['NOI_DUNG'],
      ngayGui: DateTime.parse(json['NGAY_GUI']),
      trangThai: json['TRANG_THAI'],
    );
  }
}

class SuKienKhuyenMai {
  final int maSuKien;

  SuKienKhuyenMai({
    required this.maSuKien,
  });

  factory SuKienKhuyenMai.fromJson(Map<String, dynamic> json) {
    return SuKienKhuyenMai(
      maSuKien: int.parse(json['MA_SU_KIEN'].toString()),
    );
  }
}