import 'package:doan_commerce_app/screens/payment_result.dart';
import 'package:flutter/material.dart';
import 'bank_payment_screen.dart';
import 'momo_payment_screen.dart';
import '../services/auth_service.dart';
import '../constants.dart';

class PaymentMethodsScreen extends StatefulWidget {
  final int userId;
  final double totalAmount;
  final String deliveryAddress;
  final List<Map<String, dynamic>> cartItems;
  final String? discountCode;
  final double promotionDiscount;

  const PaymentMethodsScreen({
    super.key,
    required this.userId,
    required this.totalAmount,
    required this.deliveryAddress,
    required this.cartItems,
    this.discountCode,
    required this.promotionDiscount,
  });

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  String? selectedPaymentMethod;
  bool isLoading = false;
  String? errorMessage;

  Future<void> _proceedToPayment() async {
    if (selectedPaymentMethod == null) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    Widget paymentScreen;
    if (selectedPaymentMethod == 'COD') {
      try {
        final result = await AuthService.saveOrder(
          userId: widget.userId.toString(),
          totalAmount: widget.totalAmount,
          deliveryAddress: widget.deliveryAddress,
          paymentMethod: selectedPaymentMethod!,
          cartItems: widget.cartItems,
          discountCode: widget.discountCode,
          promotionDiscount: widget.promotionDiscount,
        );
        print('COD save order result: $result');

        if (!context.mounted) return;

        if (result['success'] == true) {
          paymentScreen = PaymentResultScreen(
            success: true,
            orderId: result['order_id'] != null ? int.parse(result['order_id'].toString()) : null,
          );
        } else {
          setState(() {
            errorMessage = result['error'] ?? 'Không thể lưu đơn hàng COD';
            isLoading = false;
          });
          return;
        }
      } catch (e) {
        print('COD save order error: $e');
        setState(() {
          errorMessage = 'Lỗi khi lưu đơn hàng COD: $e';
          isLoading = false;
        });
        return;
      }
    } else {
      switch (selectedPaymentMethod) {
        case 'VI_DIEN_TU':
          paymentScreen = MomoPaymentScreen(
            userId: widget.userId,
            totalAmount: widget.totalAmount,
            deliveryAddress: widget.deliveryAddress,
            cartItems: widget.cartItems,
            discountCode: widget.discountCode,
            discountAmount: widget.promotionDiscount,
            paymentMethod: selectedPaymentMethod!,
          );
          break;
        case 'THE_NGAN_HANG':
          paymentScreen = BankPaymentScreen(
            userId: widget.userId,
            totalAmount: widget.totalAmount,
            deliveryAddress: widget.deliveryAddress,
            cartItems: widget.cartItems,
            discountCode: widget.discountCode,
            discountAmount: widget.promotionDiscount,
            paymentMethod: selectedPaymentMethod!,
          );
          break;
        default:
          setState(() {
            isLoading = false;
          });
          return;
      }
    }

    setState(() {
      isLoading = false;
    });

    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => paymentScreen),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.brown[600],
        elevation: 2,
        title: const Text(
          'Phương thức thanh toán',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.brown))
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chọn phương thức thanh toán',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown[800],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildPaymentOption(
                    title: 'Ví điện tử (Momo)',
                    value: 'VI_DIEN_TU',
                    icon: Icons.account_balance_wallet,
                    color: const Color(0xFFAE2070),
                  ),
                  _buildPaymentOption(
                    title: 'Thẻ ngân hàng',
                    value: 'THE_NGAN_HANG',
                    icon: Icons.credit_card,
                    color: Colors.blue,
                  ),
                  _buildPaymentOption(
                    title: 'Thanh toán khi nhận hàng (COD)',
                    value: 'COD',
                    icon: Icons.local_shipping,
                    color: Colors.green,
                  ),
                  if (errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  ],
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: selectedPaymentMethod == null || isLoading
                          ? null
                          : _proceedToPayment,
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
                            'Xác nhận',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  Widget _buildPaymentOption({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: RadioListTile<String>(
        value: value,
        groupValue: selectedPaymentMethod,
        onChanged: (newValue) {
          setState(() {
            selectedPaymentMethod = newValue;
          });
        },
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        secondary: Icon(icon, color: color, size: 28),
        activeColor: Colors.brown,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}