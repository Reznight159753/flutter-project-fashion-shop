import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class ReviewScreen extends StatefulWidget {
  final String orderId;
  final List<Map<String, dynamic>> products;

  const ReviewScreen({
    super.key,
    required this.orderId,
    required this.products,
  });

  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final Map<String, int> _ratings = {};
  final Map<String, TextEditingController> _commentControllers = {};
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    for (var product in widget.products) {
      final productId = product['MA_SAN_PHAM'].toString();
      _ratings[productId] = 0;
      _commentControllers[productId] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (var controller in _commentControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submitReviews() async {
    setState(() {
      _isSubmitting = true;
    });

    bool allSuccess = true;
    String? errorMessage;

    for (var product in widget.products) {
      final productId = product['MA_SAN_PHAM'].toString();
      final rating = _ratings[productId] ?? 0;
      final comment = _commentControllers[productId]?.text.trim() ?? '';

      if (rating < 1 || rating > 5) {
        allSuccess = false;
        errorMessage = 'Vui lòng chọn số sao (1-5) cho ${product['TEN_SAN_PHAM']}';
        break;
      }

      final result = await AuthService.submitReview(
        orderId: widget.orderId,
        productId: productId,
        rating: rating,
        comment: comment,
      );

      print('Submit review result for $productId: $result');

      if (!result['success']) {
        allSuccess = false;
        errorMessage = result['error'] ?? 'Lỗi khi gửi đánh giá cho ${product['TEN_SAN_PHAM']}';
        break;
      }
    }

    setState(() {
      _isSubmitting = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(allSuccess ? 'Gửi đánh giá thành công' : errorMessage ?? 'Lỗi không xác định'),
      ),
    );

    if (allSuccess) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đánh giá sản phẩm'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: widget.products.length,
                itemBuilder: (context, index) {
                  final product = widget.products[index];
                  final productId = product['MA_SAN_PHAM'].toString();
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product['TEN_SAN_PHAM'],
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: List.generate(5, (i) {
                              return IconButton(
                                icon: Icon(
                                  i < (_ratings[productId] ?? 0) ? Icons.star : Icons.star_border,
                                  color: Colors.amber,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _ratings[productId] = i + 1;
                                  });
                                },
                              );
                            }),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _commentControllers[productId],
                            decoration: const InputDecoration(
                              labelText: 'Bình luận',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitReviews,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
              ),
              child: _isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Gửi đánh giá',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}