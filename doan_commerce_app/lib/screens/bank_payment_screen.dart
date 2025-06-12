import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'payment_result.dart';

class BankPaymentScreen extends StatelessWidget {
  final int userId;
  final double totalAmount;
  final String deliveryAddress;
  final List<Map<String, dynamic>> cartItems;
  final String? discountCode;
  final double discountAmount;
  final String paymentMethod;

  const BankPaymentScreen({
    super.key,
    required this.userId,
    required this.totalAmount,
    required this.deliveryAddress,
    required this.cartItems,
    this.discountCode,
    this.discountAmount = 0,
    required this.paymentMethod,
  });

  Future<Map<String, dynamic>> _processSaveOrder() async {
    print('Cart items sent: $cartItems');
    print('Payment method: $paymentMethod');
    return await AuthService.saveOrder(
      userId: userId.toString(),
      totalAmount: totalAmount,
      deliveryAddress: deliveryAddress,
      paymentMethod: paymentMethod,
      cartItems: cartItems,
      discountCode: discountCode,
      promotionDiscount: discountAmount,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        elevation: 2,
        title: const Text(
          'Thanh toán bằng Thẻ Ngân Hàng',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Thông tin ngân hàng',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow('Ngân hàng', 'VietComBank'),
                      _buildInfoRow('Số tài khoản', '1031657390'),
                      _buildInfoRow('Chủ tài khoản', 'BUI DUC THUAN'),
                      _buildInfoRow('Nội dung chuyển khoản', 'DH0219'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Quét mã QR để thanh toán',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Container(

                    child: Image.asset(
                      'assets/images/qr1.jpg',
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Số tiền cần thanh toán: ${totalAmount.toStringAsFixed(0)}đ',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final result = await _processSaveOrder();
                  if (!context.mounted) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PaymentResultScreen(
                        success: result['success'] == true,
                        orderId: result['order_id'] != null ? int.parse(result['order_id'].toString()) : null,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.brown.withOpacity(0.3),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.brown[600]!, Colors.brown[400]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: const Text(
                      'Xác nhận đã thanh toán',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}