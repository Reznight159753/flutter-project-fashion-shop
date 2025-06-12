import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../constants.dart';
import '../../../models/Model_shop.dart';

class ItemCard extends StatelessWidget {
  const ItemCard({
    super.key,
    required this.product,
    required this.categories,
    required this.press,
  });

  final Product product;
  final List<Category> categories;
  final VoidCallback press;

  String getCategoryName(int categoryId) {
    try {
      final category = categories.firstWhere(
        (cat) => cat.maDanhMuc == categoryId,
        orElse: () => Category(maDanhMuc: 0, tenDanhMuc: 'Unknown', moTa: null),
      );
      return category.tenDanhMuc;
    } catch (e) {
      print('Error finding category: $e');
      return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: press,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  product.image,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.error, color: Colors.red),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(kDefaultPaddin / 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: kDefaultPaddin / 4),
                  Text(
                    getCategoryName(product.categoryId),
                    style: const TextStyle(
                      color: kTextLightColor,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: kDefaultPaddin / 4),
                  Text(
                    NumberFormat.currency(locale: 'vi_VN', symbol: 'VNĐ')
                        .format(product.price),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                  ),
                  const SizedBox(height: kDefaultPaddin / 4),
                  Text(
                    'Tồn kho: ${product.stock}',
                    style: const TextStyle(
                      color: kTextLightColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}