import 'package:flutter/material.dart';
import '../../../constants.dart';
import '../../../models/Model_shop.dart';
import '../../../services/auth_service.dart';

class AddToCart extends StatelessWidget {
  final Product product;
  final int quantity;

  const AddToCart({
    Key? key,
    required this.product,
    required this.quantity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kDefaultPaddin),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.brown,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            elevation: 3,
          ),
          onPressed: () async {
            if (quantity > product.stock) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Số lượng vượt quá tồn kho')),
              );
              return;
            }

            final result = await AuthService.addToCart(
              maSanPham: product.id.toString(),
              soLuong: quantity,
            );

            if (result['success'] == true) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Thêm vào giỏ hàng thành công')),
              );
            } else {
              final error = result['error'] ?? 'Không thể thêm vào giỏ hàng';
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(error)),
              );
              if (error == 'Chưa đăng nhập') {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              }
            }
          },
          child: const Text(
            "THÊM VÀO GIỎ HÀNG",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}