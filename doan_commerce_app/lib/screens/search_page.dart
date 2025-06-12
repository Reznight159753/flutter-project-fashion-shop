import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import '../../constants.dart';
import '../../models/Model_shop.dart';
import '../screens/details/details_screen.dart';
import '../screens/home/components/item_card.dart';

class SearchPage extends StatefulWidget {
  final String searchQuery;

  const SearchPage({super.key, required this.searchQuery});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<Product> _products = [];
  List<Category> _categories = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _searchProducts();
  }

  Future<void> _searchProducts() async {
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
              .map((json) {
                if (json is Map<String, dynamic>) {
                  return Category.fromJson(json);
                } else {
                  throw Exception('Invalid category data: $json');
                }
              })
              .toList();
        } else {
          throw Exception('Categories is not a list: ${categoryResult['categories']}');
        }
      } else {
        throw Exception(categoryResult['error'] ?? 'Không thể tải danh mục');
      }

      // Lấy sản phẩm tìm kiếm
      final productResult = await AuthService.searchProducts(widget.searchQuery);
      print('Search products result: $productResult');

      if (productResult['success'] == true) {
        if (productResult['products'] is List<dynamic>) {
          _products = (productResult['products'] as List<dynamic>)
              .map((json) {
                if (json is Map<String, dynamic>) {
                  return Product(
                    id: int.tryParse(json['MA_SAN_PHAM']?.toString() ?? '0') ?? 0,
                    title: json['TEN_SAN_PHAM']?.toString() ?? 'Không có tên',
                    description: json['MO_TA']?.toString() ?? 'Không có mô tả',
                    price: double.tryParse(json['GIA_BAN']?.toString() ?? '0') ?? 0.0,
                    image: json['HINH_ANH'] != null && json['HINH_ANH'].toString().isNotEmpty
                        ? 'http://10.0.2.2/shop_api/images/${json['HINH_ANH']}'
                        : 'https://via.placeholder.com/70',
                    categoryId: int.tryParse(json['MA_DANH_MUC']?.toString() ?? '0') ?? 0,
                    stock: int.tryParse(json['SO_LUONG_TON']?.toString() ?? '0') ?? 0,
                  );
                } else {
                  throw Exception('Invalid product data: $json');
                }
              })
              .toList();
        } else {
          throw Exception('Products is not a list: ${productResult['products']}');
        }
      } else {
        _errorMessage = productResult['error'] ?? 'Không thể tìm kiếm sản phẩm';
      }
    } catch (e) {
      print('Search error: $e');
      _errorMessage = 'Lỗi: $e';
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: Colors.brown,
        elevation: 2,
        title: Text(
          'Kết quả tìm kiếm: "${widget.searchQuery}"',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_errorMessage!, style: const TextStyle(fontSize: 16, color: Colors.grey)),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _searchProducts,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
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
              : _products.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.search_off,
                            size: 80,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Không tìm thấy sản phẩm nào cho "${widget.searchQuery}"',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Vui lòng thử từ khóa khác',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
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
                      itemCount: _products.length,
                      itemBuilder: (context, index) {
                        return ItemCard(
                          product: _products[index],
                          categories: _categories,
                          press: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailsScreen(
                                product: _products[index],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}