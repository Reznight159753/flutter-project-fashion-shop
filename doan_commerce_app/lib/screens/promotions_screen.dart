import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import '../../constants.dart';
import '../../services/auth_service.dart';

class Promotion {
  final int maSuKien;
  final String tenSuKien;
  final String? moTa;
  final double? tyLeGiamGia;
  final DateTime ngayBatDau;
  final DateTime ngayKetThuc;

  Promotion({
    required this.maSuKien,
    required this.tenSuKien,
    this.moTa,
    this.tyLeGiamGia,
    required this.ngayBatDau,
    required this.ngayKetThuc,
  });

  factory Promotion.fromJson(Map<String, dynamic> json) {
    return Promotion(
      maSuKien: json['MA_SU_KIEN'],
      tenSuKien: json['TEN_SU_KIEN'],
      moTa: json['MO_TA'],
      tyLeGiamGia: json['TY_LE_GIAM_GIA'] != null ? double.tryParse(json['TY_LE_GIAM_GIA'].toString()) : null,
      ngayBatDau: DateTime.parse(json['NGAY_BAT_DAU']),
      ngayKetThuc: DateTime.parse(json['NGAY_KET_THUC']),
    );
  }
}

class DiscountCode {
  final int maCode;
  final String ma;
  final double giaTriGiam;
  final int soLanSuDungToiDa;
  final int soLanDaSuDung;
  final DateTime ngayHetHan;

  DiscountCode({
    required this.maCode,
    required this.ma,
    required this.giaTriGiam,
    required this.soLanSuDungToiDa,
    required this.soLanDaSuDung,
    required this.ngayHetHan,
  });

  factory DiscountCode.fromJson(Map<String, dynamic> json) {
    return DiscountCode(
      maCode: json['MA_CODE'],
      ma: json['MA'],
      giaTriGiam: double.parse(json['GIA_TRI_GIAM'].toString()),
      soLanSuDungToiDa: json['SO_LAN_SU_DUNG_TOI_DA'],
      soLanDaSuDung: json['SO_LAN_DA_SU_DUNG'],
      ngayHetHan: DateTime.parse(json['NGAY_HET_HAN']),
    );
  }
}

class PromotionsScreen extends StatefulWidget {
  const PromotionsScreen({super.key});

  @override
  _PromotionsScreenState createState() => _PromotionsScreenState();
}

class _PromotionsScreenState extends State<PromotionsScreen> {
  List<Promotion> promotions = [];
  List<DiscountCode> discountCodes = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final promotionResult = await AuthService.getPromotions();
      final discountResult = await AuthService.getDiscountCodes();

      setState(() {
        if (promotionResult['success'] == true) {
          promotions = (promotionResult['promotions'] as List)
              .map((json) => Promotion.fromJson(json))
              .toList();
        } else {
          errorMessage = promotionResult['error'] ?? 'Không thể tải sự kiện khuyến mãi';
        }

        if (discountResult['success'] == true) {
          discountCodes = (discountResult['discount_codes'] as List)
              .map((json) => DiscountCode.fromJson(json))
              .toList();
        } else {
          errorMessage = errorMessage ?? discountResult['error'] ?? 'Không thể tải mã giảm giá';
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Lỗi: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown,
        title: const Text(
          'Sự kiện khuyến mãi & Mã giảm giá',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(errorMessage!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: fetchData,
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(kDefaultPaddin),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Sự kiện khuyến mãi
                        Text(
                          'Sự kiện khuyến mãi',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: kDefaultPaddin),
                        promotions.isEmpty
                            ? const Center(
                                child: Text(
                                  'Chưa có sự kiện khuyến mãi',
                                  style: TextStyle(fontSize: 16, color: Colors.grey),
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: promotions.length,
                                itemBuilder: (context, index) {
                                  final promotion = promotions[index];
                                  return Card(
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    margin: const EdgeInsets.only(bottom: kDefaultPaddin),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            promotion.tenSuKien,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium!
                                                .copyWith(fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 8),
                                          if (promotion.moTa != null)
                                            Text(
                                              promotion.moTa!,
                                              style: Theme.of(context).textTheme.bodyMedium,
                                            ),
                                          const SizedBox(height: 8),
                                          if (promotion.tyLeGiamGia != null)
                                            Text(
                                              'Giảm ${promotion.tyLeGiamGia?.toStringAsFixed(2)}%',
                                              style: const TextStyle(
                                                color: Colors.redAccent,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Từ: ${DateFormat('dd/MM/yyyy').format(promotion.ngayBatDau)}',
                                            style: Theme.of(context).textTheme.bodySmall,
                                          ),
                                          Text(
                                            'Đến: ${DateFormat('dd/MM/yyyy').format(promotion.ngayKetThuc)}',
                                            style: Theme.of(context).textTheme.bodySmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                        const SizedBox(height: kDefaultPaddin * 2),
                        // Mã giảm giá
                        Text(
                          'Mã giảm giá',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: kDefaultPaddin),
                        discountCodes.isEmpty
                            ? const Center(
                                child: Text(
                                  'Chưa có mã giảm giá',
                                  style: TextStyle(fontSize: 16, color: Colors.grey),
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: discountCodes.length,
                                itemBuilder: (context, index) {
                                  final code = discountCodes[index];
                                  return Card(
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    margin: const EdgeInsets.only(bottom: kDefaultPaddin),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Mã: ${code.ma}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium!
                                                    .copyWith(fontWeight: FontWeight.bold),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                'Giảm: ${NumberFormat.currency(locale: 'vi_VN', symbol: 'VNĐ').format(code.giaTriGiam)}',
                                                style: const TextStyle(color: Colors.redAccent),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                'Hết hạn: ${DateFormat('dd/MM/yyyy').format(code.ngayHetHan)}',
                                                style: Theme.of(context).textTheme.bodySmall,
                                              ),
                                              Text(
                                                'Còn ${code.soLanSuDungToiDa - code.soLanDaSuDung} lần sử dụng',
                                                style: Theme.of(context).textTheme.bodySmall,
                                              ),
                                            ],
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              Clipboard.setData(ClipboardData(text: code.ma));
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Đã sao chép mã giảm giá'),
                                                ),
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.brown,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            ),
                                            child: const Text(
                                              'Sao chép',
                                              style: TextStyle(color: Colors.white),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ],
                    ),
                  ),
                ),
    );
  }
}