import 'package:flutter/material.dart';
import '../../../constants.dart';
import '../../../services/auth_service.dart';

class CounterWithFavBtn extends StatefulWidget {
  final Function(int) onQuantityChanged;
  final int productId; // Thêm productId để biết sản phẩm nào

  const CounterWithFavBtn({
    Key? key,
    required this.onQuantityChanged,
    required this.productId,
  }) : super(key: key);

  @override
  CounterWithFavBtnState createState() => CounterWithFavBtnState();
}

class CounterWithFavBtnState extends State<CounterWithFavBtn> {
  int numOfItems = 1;
  bool isFavorite = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    setState(() {
      isLoading = true;
    });
    final result = await AuthService.getFavorites();
    if (result['success'] == true) {
      final favorites = result['favorites'] as List<dynamic>;
      setState(() {
        isFavorite = favorites.any((item) => item['MA_SAN_PHAM'].toString() == widget.productId.toString());
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    setState(() {
      isLoading = true;
    });

    final result = isFavorite
        ? await AuthService.removeFavorite(widget.productId.toString())
        : await AuthService.addFavorite(widget.productId.toString());

    print('Toggle favorite result: $result');

    if (result['success'] == true) {
      setState(() {
        isFavorite = !isFavorite;
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isFavorite
              ? 'Đã thêm vào danh sách yêu thích'
              : 'Đã xóa khỏi danh sách yêu thích'),
        ),
      );
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['error'] ?? 'Thao tác thất bại')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    if (numOfItems > 1) {
                      numOfItems--;
                      widget.onQuantityChanged(numOfItems);
                    }
                  });
                },
                child: const Icon(Icons.remove),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: kDefaultPaddin / 2),
              child: Text(
                numOfItems.toString().padLeft(2, "0"),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            SizedBox(
              width: 40,
              height: 40,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    numOfItems++;
                    widget.onQuantityChanged(numOfItems);
                  });
                },
                child: const Icon(Icons.add),
              ),
            ),
          ],
        ),
        isLoading
            ? const CircularProgressIndicator(strokeWidth: 2)
            : IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.grey,
                ),
                onPressed: _toggleFavorite,
              ),
      ],
    );
  }
}