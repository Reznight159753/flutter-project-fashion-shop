import 'package:flutter/material.dart';
import '../../../constants.dart';
import '../../../models/Model_shop.dart';

class Description extends StatelessWidget {
  const Description({
    Key? key,
    required this.product,
    required this.title,
    required this.description,
    required this.price,
    required this.stock,
  }) : super(key: key);

  final Product product;
  final String title;
  final String description;
  final double price;
  final int stock;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kDefaultPaddin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const SizedBox(height: kDefaultPaddin / 2),
          Text(
            '\$${price.toInt()}',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.brown,
            ),
          ),
          const SizedBox(height: kDefaultPaddin / 2),
          Text(
            'Còn lại: $stock sản phẩm',
            style: TextStyle(
              fontSize: 16,
              color: stock > 0 ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(height: kDefaultPaddin),
          Text(
            description.isNotEmpty ? description : 'Không có mô tả',
            style: const TextStyle(
              height: 1.5,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}