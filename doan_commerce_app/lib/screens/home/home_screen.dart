import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../constants.dart';
import '../../models/Model_shop.dart';
import '../details/details_screen.dart';
import '../welcome_page.dart';
import 'components/categorries.dart';
import 'components/item_card.dart';
import 'category_products_screen.dart';
import '../promotions_screen.dart';
import '../widgets/custom_appbar_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  List<Category> categories = [];
  List<Product> products = [];
  List<Product> allProducts = [];
  bool isLoading = true;
  int currentPage = 1;
  int productsPerPage = 6;
  int totalPages = 1;
  bool isLoadingMore = false;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    fetchData();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> fetchData({int? categoryId}) async {
    setState(() {
      isLoading = true;
    });

    try {
      // Lấy danh mục từ API
      final categoryResponse = await http.get(
        Uri.parse('http://10.0.2.2/shop_api/api/categories.php'),
      );
      if (categoryResponse.statusCode == 200) {
        final dynamic data = jsonDecode(categoryResponse.body);
        if (data is List) {
          categories =
              [Category(maDanhMuc: 0, tenDanhMuc: 'All')] +
              data.map((json) => Category.fromJson(json)).toList();
        } else {
          throw Exception('Dữ liệu danh mục không phải là danh sách');
        }
      } else {
        throw Exception(
          'Failed to load categories: ${categoryResponse.statusCode}',
        );
      }

      // Lấy sản phẩm từ API
      String productUrl = 'http://10.0.2.2/shop_api/api/products.php';
      if (categoryId != null) {
        productUrl += '?category_id=$categoryId';
      }
      final productResponse = await http.get(Uri.parse(productUrl));
      if (productResponse.statusCode == 200) {
        final dynamic data = jsonDecode(productResponse.body);
        if (data is List) {
          allProducts = data.map((json) => Product.fromJson(json)).toList();
          _updatePagination();
        } else {
          throw Exception('Dữ liệu sản phẩm không phải là danh sách');
        }
      } else {
        throw Exception(
          'Failed to load products: ${productResponse.statusCode}',
        );
      }

      setState(() {
        isLoading = false;
      });

      // Start animations
      _fadeController.forward();
      _slideController.forward();
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load data: $e'),
          backgroundColor: Colors.red[400],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _updatePagination() {
    totalPages = (allProducts.length / productsPerPage).ceil();
    int startIndex = (currentPage - 1) * productsPerPage;
    int endIndex = startIndex + productsPerPage;

    setState(() {
      products = allProducts.sublist(
        startIndex,
        endIndex > allProducts.length ? allProducts.length : endIndex,
      );
    });
  }

  void _changePage(int page) {
    if (page >= 1 && page <= totalPages) {
      setState(() {
        currentPage = page;
        isLoadingMore = true;
      });

      _updatePagination();

      // Simulate loading delay for smooth UX
      Future.delayed(const Duration(milliseconds: 300), () {
        setState(() {
          isLoadingMore = false;
        });
      });
    }
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onSeeAll}) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: kDefaultPaddin),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.brown.withOpacity(0.1), Colors.transparent],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              if (onSeeAll != null)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.brown.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextButton.icon(
                    onPressed: onSeeAll,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                    ),
                    icon: const Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Colors.brown,
                    ),
                    label: const Text(
                      "Xem tất cả",
                      style: TextStyle(
                        color: Colors.brown,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPromotionButton() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: kDefaultPaddin),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [
                Color(0xFF5D4037),
                Color(0xFF795548),
                Color(0xFFA1887F),
                Color.fromARGB(255, 164, 157, 155),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.brown.withOpacity(0.4),
                blurRadius: 15,
                offset: const Offset(0, 8),
                spreadRadius: 2,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PromotionsScreen(),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 18,
                  horizontal: 24,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.local_offer,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Khám phá ưu đãi hấp dẫn',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCarousel() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.only(
          top: kDefaultPaddin,
          bottom: kDefaultPaddin / 2,
        ),
        child: CarouselSlider(
          options: CarouselOptions(
            height: 200.0,
            autoPlay: true,
            enlargeCenterPage: true,
            aspectRatio: 16 / 9,
            autoPlayInterval: const Duration(seconds: 5),
            viewportFraction: 0.9,
            enableInfiniteScroll: true,
            autoPlayCurve: Curves.easeInOutCubic,
            enlargeStrategy: CenterPageEnlargeStrategy.zoom,
          ),
          items:
              [
                'assets/images/banner1.jpg',
                'assets/images/banner2.jpg',
                'assets/images/banner3.jpg',
                'assets/images/banner4.jpg',
              ].map((imagePath) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: Stack(
                          children: [
                            Image.asset(
                              imagePath,
                              fit: BoxFit.cover,
                              width: MediaQuery.of(context).size.width,
                              height: 200,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.4),
                                  ],
                                ),
                              ),
                            ),
                            // Decorative elements
                            Positioned(
                              top: 15,
                              right: 15,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: const Text(
                                  'NEW',
                                  style: TextStyle(
                                    color: Colors.brown,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
        ),
      ),
    );
  }

  Widget _buildPagination() {
    if (totalPages <= 1) return const SizedBox();

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: kDefaultPaddin,
        vertical: kDefaultPaddin,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Previous button
          _buildPaginationButton(
            icon: Icons.chevron_left,
            onTap: currentPage > 1 ? () => _changePage(currentPage - 1) : null,
            isEnabled: currentPage > 1,
          ),

          const SizedBox(width: 12),

          // Page numbers
          ...List.generate(totalPages, (index) {
            int pageNumber = index + 1;
            bool isCurrentPage = pageNumber == currentPage;

            // Show only nearby pages for better UX
            if (totalPages > 5) {
              if (pageNumber == 1 ||
                  pageNumber == totalPages ||
                  (pageNumber >= currentPage - 1 &&
                      pageNumber <= currentPage + 1)) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _buildPageNumber(pageNumber, isCurrentPage),
                );
              } else if (pageNumber == currentPage - 2 ||
                  pageNumber == currentPage + 2) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Text('...', style: TextStyle(color: Colors.grey)),
                );
              }
              return const SizedBox();
            } else {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _buildPageNumber(pageNumber, isCurrentPage),
              );
            }
          }),

          const SizedBox(width: 12),

          // Next button
          _buildPaginationButton(
            icon: Icons.chevron_right,
            onTap:
                currentPage < totalPages
                    ? () => _changePage(currentPage + 1)
                    : null,
            isEnabled: currentPage < totalPages,
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationButton({
    required IconData icon,
    VoidCallback? onTap,
    required bool isEnabled,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isEnabled ? Colors.brown : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
          boxShadow:
              isEnabled
                  ? [
                    BoxShadow(
                      color: Colors.brown.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                  : [],
        ),
        child: Icon(
          icon,
          color: isEnabled ? Colors.white : Colors.grey[500],
          size: 20,
        ),
      ),
    );
  }

  Widget _buildPageNumber(int pageNumber, bool isCurrentPage) {
    return GestureDetector(
      onTap: () => _changePage(pageNumber),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isCurrentPage ? Colors.brown : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCurrentPage ? Colors.brown : Colors.grey[300]!,
            width: 1.5,
          ),
          boxShadow:
              isCurrentPage
                  ? [
                    BoxShadow(
                      color: Colors.brown.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                  : [],
        ),
        child: Text(
          pageNumber.toString(),
          style: TextStyle(
            color: isCurrentPage ? Colors.white : Colors.grey[700],
            fontWeight: isCurrentPage ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const WelcomePage()),
        );
        return false;
      },
      child: CustomScaffold(
        body:
            isLoading
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.brown,
                              ),
                              strokeWidth: 3,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Đang tải dữ liệu...',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
                : RefreshIndicator(
                  onRefresh: () => fetchData(),
                  color: Colors.brown,
                  backgroundColor: Colors.white,
                  strokeWidth: 3,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Carousel với hiệu ứng đẹp hơn
                            _buildCarousel(),

                            const SizedBox(height: kDefaultPaddin / 2),

                            // Nút khuyến mãi với gradient
                            _buildPromotionButton(),

                            const SizedBox(height: kDefaultPaddin * 1.5),

                            // Header danh mục
                            _buildSectionHeader(
                              "Danh mục sản phẩm",
                              onSeeAll: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            const CategoryProductsScreen(
                                              categoryId: 0,
                                              categoryName: 'All',
                                            ),
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: kDefaultPaddin / 2),

                            // Danh mục
                            SlideTransition(
                              position: _slideAnimation,
                              child: Categories(
                                categories: categories,
                                onCategorySelected: (int categoryId) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => CategoryProductsScreen(
                                            categoryId: categoryId,
                                            categoryName:
                                                categories
                                                    .firstWhere(
                                                      (cat) =>
                                                          cat.maDanhMuc ==
                                                          categoryId,
                                                    )
                                                    .tenDanhMuc,
                                          ),
                                    ),
                                  );
                                },
                              ),
                            ),

                            const SizedBox(height: kDefaultPaddin * 1.5),

                            // Header sản phẩm với thông tin phân trang
                            _buildSectionHeader("Sản phẩm nổi bật"),

                            // Thông tin phân trang
                            if (allProducts.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: kDefaultPaddin,
                                ),
                                child: Text(
                                  'Hiển thị ${((currentPage - 1) * productsPerPage) + 1}-${currentPage * productsPerPage > allProducts.length ? allProducts.length : currentPage * productsPerPage} trong ${allProducts.length} sản phẩm',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 13,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),

                            const SizedBox(height: kDefaultPaddin),
                          ],
                        ),
                      ),
                      // Lưới sản phẩm với loading state
                      if (isLoadingMore)
                        const SliverToBoxAdapter(
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.brown,
                                ),
                              ),
                            ),
                          ),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: kDefaultPaddin,
                          ),
                          sliver: SliverGrid(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: kDefaultPaddin,
                                  crossAxisSpacing: kDefaultPaddin,
                                  childAspectRatio: 0.75,
                                ),
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              return AnimatedContainer(
                                duration: Duration(
                                  milliseconds: 400 + (index * 100),
                                ),
                                curve: Curves.easeOutBack,
                                child: ItemCard(
                                  product: products[index],
                                  categories: categories,
                                  press:
                                      () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => DetailsScreen(
                                                product: products[index],
                                              ),
                                        ),
                                      ),
                                ),
                              );
                            }, childCount: products.length),
                          ),
                        ),

                      // Pagination
                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            _buildPagination(),
                            const SizedBox(height: kDefaultPaddin),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}
