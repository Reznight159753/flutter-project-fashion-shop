import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import 'checkout_screen.dart';
import '../constants.dart';

class ShoppingBagScreen extends StatefulWidget {
  const ShoppingBagScreen({Key? key}) : super(key: key);

  @override
  State<ShoppingBagScreen> createState() => _ShoppingBagScreenState();
}

class _ShoppingBagScreenState extends State<ShoppingBagScreen> {
  List<dynamic> _cartItems = [];
  bool _isLoading = true;
  String? _errorMessage;
  double _promotionDiscountPercent = 0.0;
  double _discountCodeValue = 0.0;
  String? _appliedDiscountCode;
  final TextEditingController _discountCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCartItems();
    _loadPromotions();
  }

  Future<void> _loadCartItems() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await AuthService.getCart();
    print('Cart result: $result');

    setState(() {
      if (result['success'] == true) {
        _cartItems = result['cart_items'] ?? [];
      } else {
        _errorMessage = result['error'] ?? 'Không thể tải giỏ hàng';
        if (_errorMessage == 'Chưa đăng nhập') {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => false,
          );
        }
      }
      _isLoading = false;
    });
  }

  Future<void> _loadPromotions() async {
    final result = await AuthService.getPromotions();
    print('Promotions result: $result');

    if (result['success'] == true && result['promotions'].isNotEmpty) {
      final promotion = result['promotions'][0];
      final now = DateTime.now();
      final startDate = DateTime.parse(promotion['NGAY_BAT_DAU']);
      final endDate = DateTime.parse(promotion['NGAY_KET_THUC']);

      if (now.isAfter(startDate) && now.isBefore(endDate)) {
        setState(() {
          _promotionDiscountPercent = double.tryParse(promotion['TY_LE_GIAM_GIA'].toString()) ?? 0.0;
        });
      }
    }
  }

  Future<void> _applyDiscountCode() async {
    if (_appliedDiscountCode != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chỉ được áp dụng một mã giảm giá')),
      );
      return;
    }

    final code = _discountCodeController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập mã giảm giá')),
      );
      return;
    }

    final userId = await AuthService.getUserId();
    if (userId == null) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      return;
    }

    final result = await AuthService.applyDiscountCode(code: code, userId: userId);
    print('Apply discount code result: $result');

    if (result['success'] == true) {
      final checkUsedResult = await AuthService.checkDiscountCodeUsage(
        code: code,
        userId: userId,
      );
      if (checkUsedResult['used'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mã giảm giá đã được bạn sử dụng')),
        );
        return;
      }

      setState(() {
        _discountCodeValue = double.tryParse(result['discount_value'].toString()) ?? 0.0;
        _appliedDiscountCode = code;
        _discountCodeController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Áp dụng mã giảm giá thành công')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['error'] ?? 'Mã giảm giá không hợp lệ')),
      );
    }
  }

  double get totalAmount {
    return _cartItems.fold(0.0, (sum, item) {
      final giaBan = double.tryParse(item['GIA_BAN'].toString()) ?? 0.0;
      final soLuong = double.tryParse(item['SO_LUONG'].toString()) ?? 0.0;
      return sum + (giaBan * soLuong);
    });
  }

  double get promotionDiscount {
    return totalAmount * (_promotionDiscountPercent / 100);
  }

  double get finalAmount {
    return totalAmount - promotionDiscount - _discountCodeValue;
  }

  Future<void> _removeItem(int index) async {
    final removedItem = _cartItems[index];
    setState(() {
      _cartItems.removeAt(index);
    });

    final result = await AuthService.deleteCartItem(
      maChiTietGioHang: removedItem['MA_CHI_TIET_GIO_HANG'].toString(),
    );

    if (!result['success']) {
      setState(() {
        _cartItems.insert(index, removedItem);
        _errorMessage = result['error'] ?? 'Xóa sản phẩm thất bại';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorMessage!)),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Sản phẩm đã được xóa khỏi giỏ hàng'),
        action: SnackBarAction(
          label: 'HOÀN TÁC',
          onPressed: () async {
            final addResult = await AuthService.addToCart(
              maSanPham: removedItem['MA_SAN_PHAM'].toString(),
              soLuong: int.parse(removedItem['SO_LUONG'].toString()),
            );
            if (addResult['success']) {
              setState(() {
                _cartItems.insert(index, removedItem);
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(addResult['error'] ?? 'Hoàn tác thất bại'),
                ),
              );
            }
          },
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _showRemoveConfirmationDialog(int index, String itemName) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final item = _cartItems[index];
        final imageUrl =
            item['HINH_ANH'] != null && item['HINH_ANH'].isNotEmpty
                ? 'http://10.0.2.2/shop_api/images/${item['HINH_ANH']}'
                : 'https://via.placeholder.com/60';
        print('Dialog image URL: $imageUrl');

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Xóa khỏi giỏ hàng?',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Hero(
                        tag: "${item['MA_SAN_PHAM']}",
                        child: Image.network(
                          imageUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            print('Dialog image error: $error, URL: $imageUrl');
                            return Container(
                              color: Colors.grey[300],
                              child: const Icon(Icons.error, color: Colors.brown),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['TEN_SAN_PHAM'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${NumberFormat.currency(locale: 'vi_VN', symbol: 'VNĐ').format(double.tryParse(item['GIA_BAN'].toString()) ?? 0)}',
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.remove,
                                size: 16,
                                color: Colors.grey,
                              ),
                              Text(
                                ' ${item['SO_LUONG']} ',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Icon(
                                Icons.add,
                                size: 16,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.black87,
                          backgroundColor: Colors.grey.shade200,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          minimumSize: const Size(0, 48),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Hủy'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.brown,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          minimumSize: const Size(0, 48),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          _removeItem(index);
                        },
                        child: const Text('Xóa'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: Colors.brown,
        elevation: 2,
        title: const Text(
          'Giỏ hàng',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.shopping_bag_outlined,
                  color: Colors.white,
                ),
                onPressed: () {},
              ),
              if (_cartItems.isNotEmpty)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${_cartItems.length}',
                      style: const TextStyle(color: Colors.brown, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_errorMessage!),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _loadCartItems,
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : _cartItems.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_bag_outlined,
                            size: 80,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Giỏ hàng của bạn đang trống',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Thêm sản phẩm để bắt đầu mua sắm',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: _cartItems.length,
                            itemBuilder: (context, index) {
                              return SlideToDeleteItem(
                                key: Key(
                                  _cartItems[index]['MA_CHI_TIET_GIO_HANG'].toString(),
                                ),
                                onDelete: () {
                                  _showRemoveConfirmationDialog(
                                    index,
                                    _cartItems[index]['TEN_SAN_PHAM'],
                                  );
                                },
                                child: SwipeableCartItemWidget(
                                  item: _cartItems[index],
                                  onIncrease: () async {
                                    final newQuantity =
                                        int.parse(_cartItems[index]['SO_LUONG'].toString()) + 1;
                                    final result = await AuthService.updateCartItem(
                                      maChiTietGioHang:
                                          _cartItems[index]['MA_CHI_TIET_GIO_HANG'].toString(),
                                      soLuong: newQuantity,
                                    );
                                    if (result['success']) {
                                      setState(() {
                                        _cartItems[index]['SO_LUONG'] = newQuantity.toString();
                                      });
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            result['error'] ?? 'Cập nhật thất bại',
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  onDecrease: () async {
                                    final currentQuantity =
                                        int.parse(_cartItems[index]['SO_LUONG'].toString());
                                    if (currentQuantity > 1) {
                                      final newQuantity = currentQuantity - 1;
                                      final result = await AuthService.updateCartItem(
                                        maChiTietGioHang:
                                            _cartItems[index]['MA_CHI_TIET_GIO_HANG'].toString(),
                                        soLuong: newQuantity,
                                      );
                                      if (result['success']) {
                                        setState(() {
                                          _cartItems[index]['SO_LUONG'] = newQuantity.toString();
                                        });
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              result['error'] ?? 'Cập nhật thất bại',
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  onDelete: () {
                                    _showRemoveConfirmationDialog(
                                      index,
                                      _cartItems[index]['TEN_SAN_PHAM'],
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(kDefaultPaddin),
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.white,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                        child: TextField(
                                          controller: _discountCodeController,
                                          enabled: _appliedDiscountCode == null,
                                          decoration: InputDecoration(
                                            hintText: _appliedDiscountCode == null
                                                ? 'Nhập mã giảm giá'
                                                : 'Mã $_appliedDiscountCode đã áp dụng',
                                            border: InputBorder.none,
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (_appliedDiscountCode == null)
                                      Container(
                                        margin: const EdgeInsets.all(4),
                                        child: ElevatedButton(
                                          onPressed: _applyDiscountCode,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.brown,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: const Text(
                                            'Áp dụng',
                                            style: TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: kDefaultPaddin),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Tạm tính:',
                                    style: TextStyle(fontSize: 16, color: Colors.grey),
                                  ),
                                  Text(
                                    NumberFormat.currency(locale: 'vi_VN', symbol: 'VNĐ')
                                        .format(totalAmount),
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                              if (_promotionDiscountPercent > 0) ...[
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Giảm giá sự kiện ($_promotionDiscountPercent%):',
                                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                                    ),
                                    Text(
                                      '-${NumberFormat.currency(locale: 'vi_VN', symbol: 'VNĐ').format(promotionDiscount)}',
                                      style: const TextStyle(fontSize: 16, color: Colors.brown),
                                    ),
                                  ],
                                ),
                              ],
                              if (_discountCodeValue > 0) ...[
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Giảm giá mã ($_appliedDiscountCode):',
                                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                                    ),
                                    Text(
                                      '-${NumberFormat.currency(locale: 'vi_VN', symbol: 'VNĐ').format(_discountCodeValue)}',
                                      style: const TextStyle(fontSize: 16, color: Colors.brown),
                                    ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Phí vận chuyển:',
                                    style: TextStyle(fontSize: 16, color: Colors.grey),
                                  ),
                                  const Text(
                                    'MIỄN PHÍ',
                                    style: TextStyle(fontSize: 16, color: Colors.green),
                                  ),
                                ],
                              ),
                              const Divider(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Tổng cộng:',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    NumberFormat.currency(locale: 'vi_VN', symbol: 'VNĐ')
                                        .format(finalAmount),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.brown,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: kDefaultPaddin),
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: finalAmount > 0
                                      ? () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => CheckoutScreen(
                                                totalAmount: finalAmount,
                                                discountCode: _appliedDiscountCode,
                                                promotionDiscount: promotionDiscount,
                                                discountCodeValue: _discountCodeValue,
                                              ),
                                            ),
                                          );
                                        }
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.brown,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'THANH TOÁN',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
    );
  }
}

class SlideToDeleteItem extends StatefulWidget {
  final Widget child;
  final VoidCallback onDelete;

  const SlideToDeleteItem({
    Key? key,
    required this.child,
    required this.onDelete,
  }) : super(key: key);

  @override
  State<SlideToDeleteItem> createState() => _SlideToDeleteItemState();
}

class _SlideToDeleteItemState extends State<SlideToDeleteItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _dragExtent = 0;
  final double _dragThreshold = 60.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragExtent += details.delta.dx;
      _dragExtent = _dragExtent.clamp(-_dragThreshold, 0);
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_dragExtent <= -_dragThreshold / 2) {
      setState(() {
        _dragExtent = -_dragThreshold;
      });
    } else {
      setState(() {
        _dragExtent = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: _handleDragUpdate,
      onHorizontalDragEnd: _handleDragEnd,
      child: Stack(
        children: [
          Positioned.fill(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: _dragThreshold,
                  color: Colors.brown,
                  child: GestureDetector(
                    onTap: widget.onDelete,
                    child: const Center(
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Transform.translate(
            offset: Offset(_dragExtent, 0),
            child: Container(color: Colors.white, child: widget.child),
          ),
        ],
      ),
    );
  }
}

class SwipeableCartItemWidget extends StatelessWidget {
  final dynamic item;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onDelete;

  const SwipeableCartItemWidget({
    Key? key,
    required this.item,
    required this.onIncrease,
    required this.onDecrease,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageUrl = item['HINH_ANH'] != null && item['HINH_ANH'].isNotEmpty
        ? 'http://10.0.2.2/shop_api/images/${item['HINH_ANH']}'
        : 'https://via.placeholder.com/70';
    print('Cart item image URL: $imageUrl');

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Hero(
              tag: "${item['MA_SAN_PHAM']}",
              child: Image.network(
                imageUrl,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  print('Cart item image error: $error, URL: $imageUrl');
                  return Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.error, color: Colors.brown),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item['TEN_SAN_PHAM'],
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, size: 20),
                      onSelected: (value) {
                        if (value == 'favorite') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Đã thêm vào yêu thích')),
                          );
                        } else if (value == 'delete') {
                          onDelete();
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'favorite',
                          child: Row(
                            children: [
                              Icon(Icons.favorite_border, color: Colors.grey),
                              SizedBox(width: 8),
                              Text('Thêm vào yêu thích'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.brown),
                              SizedBox(width: 8),
                              Text('Xóa'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: onDecrease,
                        iconSize: 18,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      Text(
                        '${item['SO_LUONG']}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: onIncrease,
                        iconSize: 18,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 8),
            child: Text(
              NumberFormat.currency(locale: 'vi_VN', symbol: 'VNĐ')
                  .format(double.tryParse(item['GIA_BAN'].toString()) ?? 0),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}