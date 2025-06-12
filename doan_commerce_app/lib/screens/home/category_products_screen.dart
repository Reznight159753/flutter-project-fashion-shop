import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../constants.dart';
import '../../models/Model_shop.dart';
import 'components/item_card.dart';
import '../details/details_screen.dart';

class CategoryProductsScreen extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  const CategoryProductsScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  _CategoryProductsScreenState createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  List<Product> products = [];
  List<Product> filteredProducts = []; // Danh sách sản phẩm sau khi lọc
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Lấy tất cả sản phẩm từ API
      const productUrl = 'http://10.0.2.2/shop_api/api/products.php';
      final productResponse = await http.get(Uri.parse(productUrl));
      if (productResponse.statusCode == 200) {
        final dynamic data = jsonDecode(productResponse.body);
        if (data is List) {
          products = data.map((json) => Product.fromJson(json)).toList();
          // Lọc sản phẩm theo categoryId ở phía client
          filteredProducts = widget.categoryId == 0
              ? products // Hiển thị tất cả nếu categoryId là 0 (All)
              : products.where((product) => product.categoryId == widget.categoryId).toList();
        } else {
          throw Exception('Dữ liệu sản phẩm không phải là danh sách');
        }
      } else {
        throw Exception('Failed to load products: ${productResponse.statusCode}');
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load products: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
        backgroundColor: Colors.brown,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: kDefaultPaddin),
              child: GridView.builder(
                itemCount: filteredProducts.length, // Sử dụng danh sách đã lọc
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: kDefaultPaddin,
                  crossAxisSpacing: kDefaultPaddin,
                  childAspectRatio: 0.75,
                ),
                itemBuilder: (context, index) {
                  return ItemCard(
                    product: filteredProducts[index],
                    categories: [], // Không cần danh mục ở đây
                    press: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailsScreen(
                          product: filteredProducts[index],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}