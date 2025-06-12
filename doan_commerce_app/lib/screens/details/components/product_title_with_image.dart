import 'package:flutter/material.dart';
import '../../../constants.dart';
import '../../../models/Model_shop.dart';
import '../../../services/auth_service.dart';
import '../product_reviews.dart';

class ProductTitleWithImage extends StatefulWidget {
  final Product product;
  final String title;
  final String imageUrl;

  const ProductTitleWithImage({
    super.key,
    required this.product,
    required this.title,
    required this.imageUrl,
  });

  @override
  _ProductTitleWithImageState createState() => _ProductTitleWithImageState();
}

class _ProductTitleWithImageState extends State<ProductTitleWithImage> {
  int _soldQuantity = 0;
  double _averageRating = 0.0;
  int _totalReviews = 0;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final soldResult = await AuthService.getSoldQuantity(widget.product.id.toString());
      final ratingResult = await AuthService.getAverageRating(widget.product.id.toString());
      print('Sold quantity result: $soldResult');
      print('Average rating result: $ratingResult');

      setState(() {
        if (soldResult['success'] == true) {
          _soldQuantity = soldResult['sold_quantity'] ?? 0;
        } else {
          _errorMessage = soldResult['error'] ?? 'Không thể tải số lượng đã bán';
        }

        if (ratingResult['success'] == true) {
          _averageRating = ratingResult['average_rating']?.toDouble() ?? 0.0;
          _totalReviews = ratingResult['total_reviews'] ?? 0;
        } else {
          _errorMessage = _errorMessage ?? ratingResult['error'] ?? 'Không thể tải đánh giá';
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kDefaultPaddin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text("Tên sản phẩm", style: TextStyle(color: Colors.white)),
          Text(
            widget.title,
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: kDefaultPaddin),
          Row(
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(text: "Số lượng đã bán: "),
                        TextSpan(
                          text: _isLoading ? 'Đang tải...' : (_errorMessage != null ? 'Lỗi' : '$_soldQuantity'),
                          style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        _isLoading ? 'Đang tải...' : (_errorMessage != null ? 'Lỗi' : '${_averageRating.toStringAsFixed(1)}/5'),
                        style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Colors.white),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '($_totalReviews đánh giá)',
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductReviewsScreen(
                            productId: widget.product.id,
                            productTitle: widget.title,
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      'Xem chi tiết bình luận',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: kDefaultPaddin),
              Expanded(
                child: Hero(
                  tag: "${widget.product.id}",
                  child: Image.network(
                    widget.imageUrl,
                    fit: BoxFit.cover,
                    height: 200,
                    errorBuilder: (context, error, stackTrace) {
                      print('Image error: $error, URL: ${widget.imageUrl}');
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.error, color: Colors.red),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}