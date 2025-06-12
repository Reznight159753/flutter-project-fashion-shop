import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:doan_commerce_app/screens/cart_screen.dart';
import 'package:doan_commerce_app/screens/profile_page.dart';
import 'package:doan_commerce_app/screens/search_page.dart';
import 'package:doan_commerce_app/screens/favorites_screen.dart';
import '../login_screen.dart';
import '../../services/auth_service.dart';
import '../../constants.dart';

class CustomScaffold extends StatefulWidget {
  final Widget body;

  const CustomScaffold({super.key, required this.body});

  @override
  _CustomScaffoldState createState() => _CustomScaffoldState();
}

class _CustomScaffoldState extends State<CustomScaffold> {
  int _favoriteCount = 0;

  @override
  void initState() {
    super.initState();
    _loadFavoriteCount();
  }

  Future<void> _loadFavoriteCount() async {
    final result = await AuthService.getFavorites();
    print('Favorites count result: $result');
    if (result['success'] == true) {
      setState(() {
        _favoriteCount = (result['favorites'] as List<dynamic>?)?.length ?? 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController searchController = TextEditingController();

    void performSearch(String query) {
      if (query.trim().isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SearchPage(searchQuery: query.trim()),
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown,
        elevation: 2,
        titleSpacing: 0,
        title: Row(
          children: [
            const SizedBox(width: kDefaultPaddin / 2),
            const Text(
              'Nhóm 2',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(width: kDefaultPaddin),
            Expanded(
              flex: 4,
              child: Container(
                height: 36,
                margin: const EdgeInsets.symmetric(horizontal: kDefaultPaddin / 2),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm sản phẩm...',
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    icon: const Icon(Icons.search, color: Colors.grey, size: 20),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.send, color: Colors.grey),
                      onPressed: () => performSearch(searchController.text),
                    ),
                  ),
                  onSubmitted: performSearch,
                ),
              ),
            ),
            IconButton(
              icon: SvgPicture.asset(
                'assets/icons/Bag.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ShoppingBagScreen()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () async {
                final result = await AuthService.logoutFromServer();
                if (result['success'] == true) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đăng xuất thành công')),
                  );
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/',
                    (route) => false,
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result['error'] ?? 'Đăng xuất thất bại'),
                    ),
                  );
                }
              },
            ),
            const SizedBox(width: kDefaultPaddin / 2),
          ],
        ),
      ),
      body: widget.body,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          selectedItemColor: Colors.brown,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
          onTap: (index) {
            if (index == 0) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/home',
                (route) => false,
              );
            } else if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavoritesScreen()),
              );
            } else if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            }
          },
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Stack(
                children: [
                  const Icon(Icons.favorite),
                  if (_favoriteCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.brown,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$_favoriteCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              label: 'Favourite',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}