import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import '../../models/Model_shop.dart';
import '../../constants.dart';
import 'details/details_screen.dart';
import 'home/components/item_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<dynamic> _favorites = [];
  List<Category> _categories = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Lấy danh mục
      final categoryResult = await AuthService.getCategories();
      print('Category result: $categoryResult');
      if (categoryResult['success'] == true) {
        if (categoryResult['categories'] is List<dynamic>) {
          _categories = (categoryResult['categories'] as List<dynamic>)
              .map((json) => Category.fromJson(json))
              .toList();
        } else {
          throw Exception('Categories is not a list');
        }
      } else {
        throw Exception(categoryResult['error'] ?? 'Không thể tải danh mục');
      }

      // Lấy danh sách yêu thích
      final result = await AuthService.getFavorites();
      print('Favorites result: $result');

      if (result['success'] == true) {
        _favorites = result['favorites'] ?? [];
        // Log chi tiết sản phẩm
        for (var favorite in _favorites) {
          print('Product: ${favorite['MA_SAN_PHAM']}, MO_TA: ${favorite['MO_TA']}, SO_LUONG_TON: ${favorite['SO_LUONG_TON']}');
        }
      } else {
        _errorMessage = result['error'] ?? 'Không thể tải danh sách yêu thích';
      }
    } catch (e) {
      print('Error: $e');
      _errorMessage = 'Lỗi: $e';
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _removeFavorite(String productId) async {
    final result = await AuthService.removeFavorite(productId);
    print('Remove favorite result: $result');

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xóa khỏi danh sách yêu thích')),
      );
      _loadFavorites();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['error'] ?? 'Xóa thất bại')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown,
        elevation: 0,
        title: const Text(
          'Danh sách yêu thích',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _errorMessage!,
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _loadFavorites,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Thử lại',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                )
              : _favorites.isEmpty
                  ? const Center(
                      child: Text(
                        'Chưa có sản phẩm yêu thích',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(kDefaultPaddin),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: kDefaultPaddin,
                        crossAxisSpacing: kDefaultPaddin,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: _favorites.length,
                      itemBuilder: (context, index) {
                        final favorite = _favorites[index];
                        final product = Product(
                          id: int.tryParse(favorite['MA_SAN_PHAM']?.toString() ?? '0') ?? 0,
                          categoryId: int.tryParse(favorite['MA_DANH_MUC']?.toString() ?? '0') ?? 0,
                          title: favorite['TEN_SAN_PHAM']?.toString() ?? 'Không có tên',
                          description: favorite['MO_TA']?.toString() ?? 'Không có mô tả',
                          price: double.tryParse(favorite['GIA_BAN']?.toString() ?? '0') ?? 0.0,
                          stock: int.tryParse(favorite['SO_LUONG_TON']?.toString() ?? '0') ?? 0,
                          image: favorite['HINH_ANH'] != null && favorite['HINH_ANH'].toString().isNotEmpty
                              ? favorite['HINH_ANH'].startsWith('http')
                                  ? favorite['HINH_ANH']
                                  : 'http://10.0.2.2/shop_api/images/${favorite['HINH_ANH']}'
                              : 'https://via.placeholder.com/70',
                        );
                        return Stack(
                          children: [
                            ItemCard(
                              product: product,
                              categories: _categories,
                              press: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailsScreen(product: product),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: IconButton(
                                icon: const Icon(Icons.favorite, color: Colors.red),
                                onPressed: () => _removeFavorite(favorite['MA_SAN_PHAM'].toString()),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
    );
  }
}