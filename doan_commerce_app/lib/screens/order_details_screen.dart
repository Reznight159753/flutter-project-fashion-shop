import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderDetailsScreen extends StatelessWidget {
  final dynamic order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final items = order['items'] as List<dynamic>? ?? [];
    final discount = double.tryParse(order['GIA_GIAM'].toString()) ?? 0;
    final paymentMethod =
        order['PHUONG_THUC_THANH_TOAN'] == 'COD'
            ? 'Thanh toán khi nhận hàng'
            : order['PHUONG_THUC_THANH_TOAN'] == 'VI_DIEN_TU'
            ? 'Ví điện tử'
            : 'Thẻ ngân hàng';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown,
        elevation: 0,
        title: Text(
          'Chi tiết đơn hàng #${order['MA_DON_HANG']}',
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Thông tin đơn hàng',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Mã đơn hàng: ${order['MA_DON_HANG']}'),
                    Text('Ngày đặt: ${order['NGAY_DAT']}'),
                    Text(
                      'Tổng tiền: ${NumberFormat.currency(locale: 'vi_VN', symbol: 'VNĐ').format(double.tryParse(order['TONG_TIEN'].toString()) ?? 0)}',
                    ),
                    Text('Trạng thái: ${order['TRANG_THAI']}'),
                    Text('Địa chỉ giao hàng: ${order['DIA_CHI_GIAO']}'),
                    Text('Phương thức thanh toán: $paymentMethod'),
                    if (order['MA_KHUYEN_MAI'] != null && discount > 0)
                      Text(
                        'Mã giảm giá: ${order['MA_KHUYEN_MAI']} (-${NumberFormat.currency(locale: 'vi_VN', symbol: 'VNĐ').format(discount)})',
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sản phẩm',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    items.isEmpty
                        ? const Text(
                          'Không có sản phẩm nào trong đơn hàng',
                          style: TextStyle(color: Colors.grey),
                        )
                        : Column(
                          children:
                              items.map((item) {
                                final imageUrl =
                                    item['HINH_ANH'] != null &&
                                            item['HINH_ANH']
                                                .toString()
                                                .isNotEmpty
                                        ? 'http://10.0.2.2/shop_api/images/${item['HINH_ANH']}'
                                        : 'https://via.placeholder.com/70';
                                return ListTile(
                                  leading: Image.network(
                                    imageUrl,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                              Icons.image_not_supported,
                                            ),
                                  ),
                                  title: Text(
                                    item['TEN_SAN_PHAM'] ??
                                        'Sản phẩm không xác định',
                                  ),
                                  subtitle: Text(
                                    'Số lượng: ${item['SO_LUONG']}',
                                  ),
                                  trailing: Text(
                                    NumberFormat.currency(
                                      locale: 'vi_VN',
                                      symbol: 'VNĐ',
                                    ).format(
                                      double.tryParse(
                                            item['DON_GIA'].toString(),
                                          ) ??
                                          0,
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
