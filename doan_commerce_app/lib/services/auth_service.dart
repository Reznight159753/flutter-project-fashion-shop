import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class AuthService {
  static const String baseUrl = 'http://10.0.2.2/shop_api/api';
  static String? _sessionCookie;

  // Login method
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users.php'),
        body: json.encode({
          'email': email,
          'password': password,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.headers.containsKey('set-cookie')) {
        _sessionCookie = response.headers['set-cookie'];
        print('Session cookie saved: $_sessionCookie');
      }

      final data = json.decode(response.body);
      if (data['success'] == true) {
        await _saveUserData(data['user_id'], data['user_name']);
        await _saveLoginState(true);
      }
      return data;
    } catch (e) {
      print('Error in login: $e');
      return {
        'success': false,
        'error': 'An error occurred: ${e.toString()}'
      };
    }
  }

  // Forgot password
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/forgot_password.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );

      print('forgotPassword response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          return {
            'success': data['success'] ?? false,
            'message': data['message'],
            'error': data['error'],
          };
        } catch (e) {
          print('JSON parse error in forgotPassword: $e');
          return {
            'success': false,
            'error': 'Lỗi định dạng phản hồi từ server: $e'
          };
        }
      } else {
        return {
          'success': false,
          'error': 'Lỗi server: ${response.statusCode} - ${response.reasonPhrase}'
        };
      }
    } catch (e) {
      print('Error in forgotPassword: $e');
      return {
        'success': false,
        'error': 'Lỗi kết nối: ${e.toString()}'
      };
    }
  }

  // Verify code
  static Future<Map<String, dynamic>> verifyCode(String email, String code) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verify_code.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'code': code,
        }),
      );

      print('verifyCode response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          return {
            'success': data['success'] ?? false,
            'message': data['message'],
            'error': data['error'],
          };
        } catch (e) {
          print('JSON parse error in verifyCode: $e');
          return {
            'success': false,
            'error': 'Lỗi định dạng phản hồi từ server: $e'
          };
        }
      } else {
        return {
          'success': false,
          'error': 'Lỗi server: ${response.statusCode} - ${response.reasonPhrase}'
        };
      }
    } catch (e) {
      print('Error in verifyCode: $e');
      return {
        'success': false,
        'error': 'Lỗi kết nối: ${e.toString()}'
      };
    }
  }

  // Update password
  static Future<Map<String, dynamic>> updatePassword(String email, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/update_password.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'new_password': newPassword,
        }),
      );

      print('updatePassword response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          return {
            'success': data['success'] ?? false,
            'message': data['message'],
            'error': data['error'],
          };
        } catch (e) {
          print('JSON parse error in updatePassword: $e');
          return {
            'success': false,
            'error': 'Lỗi định dạng phản hồi từ server: $e'
          };
        }
      } else {
        return {
          'success': false,
          'error': 'Lỗi server: ${response.statusCode} - ${response.reasonPhrase}'
        };
      }
    } catch (e) {
      print('Error in updatePassword: $e');
      return {
        'success': false,
        'error': 'Lỗi kết nối: ${e.toString()}'
      };
    }
  }

  // Save order
  static Future<Map<String, dynamic>> saveOrder({
    required String userId,
    required double totalAmount,
    required String deliveryAddress,
    required String paymentMethod,
    required List<Map<String, dynamic>> cartItems,
    String? discountCode,
    double promotionDiscount = 0,
  }) async {
    try {
      final headers = {'Content-Type': 'application/json'};
      if (_sessionCookie != null) {
        headers['Cookie'] = _sessionCookie!;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/save_order.php'),
        headers: headers,
        body: json.encode({
          'user_id': userId,
          'total_amount': totalAmount,
          'delivery_address': deliveryAddress,
          'payment_method': paymentMethod,
          'cart_items': cartItems,
          'discount_code': discountCode,
          'promotion_discount': promotionDiscount,
        }),
      );

      print('saveOrder response: ${response.body}');
      final data = json.decode(response.body);
      return data;
    } catch (e) {
      print('Error in saveOrder: $e');
      return {
        'success': false,
        'error': 'An error occurred: ${e.toString()}'
      };
    }
  }

  // Submit feedback
  static Future<Map<String, dynamic>> submitFeedback(String feedback) async {
    try {
      final userId = await getUserId();
      if (userId == null) {
        return {
          'success': false,
          'error': 'Chưa đăng nhập'
        };
      }
      final headers = {'Content-Type': 'application/json'};
      if (_sessionCookie != null) {
        headers['Cookie'] = _sessionCookie!;
      }
      final response = await http.post(
        Uri.parse('$baseUrl/submit_feedback.php'),
        headers: headers,
        body: json.encode({
          'feedback': feedback,
        }),
      );
      print('submitFeedback response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          return {
            'success': data['success'] ?? false,
            'message': data['message'],
            'error': data['error'],
          };
        } catch (e) {
          print('JSON parse error: $e');
          return {
            'success': false,
            'error': 'Lỗi định dạng phản hồi từ server'
          };
        }
      } else {
        return {
          'success': false,
          'error': 'Lỗi server: ${response.statusCode} - ${response.reasonPhrase}',
        };
      }
    } catch (e) {
      print('Error in submitFeedback: $e');
      return {
        'success': false,
        'error': 'Lỗi kết nối: ${e.toString()}'
      };
    }
  }

  // Get user orders
  static Future<Map<String, dynamic>> getUserOrders({int page = 1, int limit = 10}) async {
    try {
      final userId = await getUserId();
      if (userId == null) {
        return {
          'success': false,
          'error': 'Chưa đăng nhập'
        };
      }

      final headers = {'Content-Type': 'application/json'};
      if (_sessionCookie != null) {
        headers['Cookie'] = _sessionCookie!;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/user_orders.php?user_id=$userId&page=$page&limit=$limit'),
        headers: headers,
      );

      print('getUserOrders response: ${response.body}');
      final data = json.decode(response.body);
      return {
        'success': data['success'] ?? false,
        'orders': data['orders'] ?? [],
        'total': data['total'] ?? 0,
        'error': data['error'],
      };
    } catch (e) {
      print('Error in getUserOrders: $e');
      return {
        'success': false,
        'orders': [],
        'total': 0,
        'error': 'An error occurred: ${e.toString()}'
      };
    }
  }

  // Save user data to SharedPreferences
  static Future<void> _saveUserData(String userId, String userName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', userId);
    await prefs.setString('user_name', userName);
  }

  // Save login state
  static Future<void> _saveLoginState(bool isLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', isLoggedIn);
  }

  // Get user info from API
  static Future<Map<String, dynamic>> getUserInfo() async {
    try {
      final userId = await getUserId();
      if (userId == null) {
        return {
          'success': false,
          'error': 'Chưa đăng nhập'
        };
      }

      final headers = {'Content-Type': 'application/json'};
      if (_sessionCookie != null) {
        headers['Cookie'] = _sessionCookie!;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/get_user_info.php'),
        headers: headers,
      );

      print('getUserInfo response: ${response.body}');

      final data = json.decode(response.body);
      if (data['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('email', data['user']['email'] ?? '');
        await prefs.setString('phone', data['user']['so_dien_thoai'] ?? '');
        await prefs.setString('address', data['user']['dia_chi'] ?? '');
        await prefs.setString('avatar', data['user']['anh_dai_dien'] ?? '');
        return data;
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Không thể lấy thông tin người dùng'
        };
      }
    } catch (e) {
      print('Error in getUserInfo: $e');
      return {
        'success': false,
        'error': 'An error occurred: ${e.toString()}'
      };
    }
  }

  // Update profile
  static Future<Map<String, dynamic>> updateProfile({
    required String userId,
    String? hoTen,
    String? email,
    String? soDienThoai,
    String? diaChi,
    File? anhDaiDien,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/update_profile.php'),
      );

      request.fields['user_id'] = userId;
      if (hoTen != null) request.fields['ho_ten'] = hoTen;
      if (email != null) request.fields['email'] = email;
      if (soDienThoai != null) request.fields['so_dien_thoai'] = soDienThoai;
      if (diaChi != null) request.fields['dia_chi'] = diaChi;

      if (anhDaiDien != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'anh_dai_dien',
            anhDaiDien.path,
            filename: anhDaiDien.path.split('/').last,
          ),
        );
      }

      if (_sessionCookie != null) {
        request.headers['Cookie'] = _sessionCookie!;
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final data = json.decode(responseBody);

      if (data['success'] == true) {
        // Update SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        if (hoTen != null) await prefs.setString('user_name', hoTen);
        if (email != null) await prefs.setString('email', email);
        if (soDienThoai != null) await prefs.setString('phone', soDienThoai);
        if (diaChi != null) await prefs.setString('address', diaChi);
        if (data['anh_dai_dien'] != null) {
          await prefs.setString('avatar', data['anh_dai_dien']);
        }
      }

      return data;
    } catch (e) {
      print('Error in updateProfile: $e');
      return {
        'success': false,
        'error': 'An error occurred: ${e.toString()}'
      };
    }
  }

  // Logout from server
  static Future<Map<String, dynamic>> logoutFromServer() async {
    try {
      final headers = {'Content-Type': 'application/json'};
      if (_sessionCookie != null) {
        headers['Cookie'] = _sessionCookie!;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/logout.php'),
        headers: headers,
      );

      print('logoutFromServer response: ${response.body}');

      final data = json.decode(response.body);
      if (data['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        _sessionCookie = null;
        return {
          'success': true,
          'message': 'Vui lòng đăng nhập để có thể sử dụng một số chức năng'
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Không thể đăng xuất'
        };
      }
    } catch (e) {
      print('Error in logoutFromServer: $e');
      return {
        'success': false,
        'error': 'An error occurred: ${e.toString()}'
      };
    }
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }

  // Get user ID
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  // Get user name
  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_name');
  }

  // Get email
  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('email');
  }

  // Get phone
  static Future<String?> getPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('phone');
  }

  // Get address
  static Future<String?> getAddress() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('address');
  }

  // Get avatar
  static Future<String?> getAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('avatar');
  }

  // Logout (client-side only, for compatibility)
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _sessionCookie = null;
  }

  // Get cart items
  static Future<Map<String, dynamic>> getCart() async {
    try {
      final userId = await getUserId();
      if (userId == null) {
        return {
          'success': false,
          'error': 'Chưa đăng nhập'
        };
      }

      final headers = {'Content-Type': 'application/json'};
      if (_sessionCookie != null) {
        headers['Cookie'] = _sessionCookie!;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/get_cart.php'),
        headers: headers,
      );

      print('getCart response: ${response.body}');

      final data = json.decode(response.body);
      return data;
    } catch (e) {
      print('Error in getCart: $e');
      return {
        'success': false,
        'error': 'An error occurred: ${e.toString()}'
      };
    }
  }

  // Add item to cart
  static Future<Map<String, dynamic>> addToCart({
    required String maSanPham,
    required int soLuong,
  }) async {
    try {
      final userId = await getUserId();
      if (userId == null) {
        return {
          'success': false,
          'error': 'Chưa đăng nhập'
        };
      }

      final headers = {'Content-Type': 'application/x-www-form-urlencoded'};
      if (_sessionCookie != null) {
        headers['Cookie'] = _sessionCookie!;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/add_to_cart.php'),
        headers: headers,
        body: {
          'ma_san_pham': maSanPham,
          'so_luong': soLuong.toString(),
        },
      );

      print('addToCart response: ${response.body}');

      final data = json.decode(response.body);
      return data;
    } catch (e) {
      print('Error in addToCart: $e');
      return {
        'success': false,
        'error': 'An error occurred: ${e.toString()}'
      };
    }
  }

  // Update cart item quantity
  static Future<Map<String, dynamic>> updateCartItem({
    required String maChiTietGioHang,
    required int soLuong,
  }) async {
    try {
      final userId = await getUserId();
      if (userId == null) {
        return {
          'success': false,
          'error': 'Chưa đăng nhập'
        };
      }

      final headers = {'Content-Type': 'application/x-www-form-urlencoded'};
      if (_sessionCookie != null) {
        headers['Cookie'] = _sessionCookie!;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/update_cart_item.php'),
        headers: headers,
        body: {
          'ma_chi_tiet_gio_hang': maChiTietGioHang,
          'so_luong': soLuong.toString(),
        },
      );

      print('updateCartItem response: ${response.body}');

      final data = json.decode(response.body);
      return data;
    } catch (e) {
      print('Error in updateCartItem: $e');
      return {
        'success': false,
        'error': 'An error occurred: ${e.toString()}'
      };
    }
  }

  // Delete cart item
  static Future<Map<String, dynamic>> deleteCartItem({
    required String maChiTietGioHang,
  }) async {
    try {
      final userId = await getUserId();
      if (userId == null) {
        return {
          'success': false,
          'error': 'Chưa đăng nhập'
        };
      }

      final headers = {'Content-Type': 'application/x-www-form-urlencoded'};
      if (_sessionCookie != null) {
        headers['Cookie'] = _sessionCookie!;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/delete_cart_item.php'),
        headers: headers,
        body: {
          'ma_chi_tiet_gio_hang': maChiTietGioHang,
        },
      );

      print('deleteCartItem response: ${response.body}');

      final data = json.decode(response.body);
      return data;
    } catch (e) {
      print('Error in deleteCartItem: $e');
      return {
        'success': false,
        'error': 'An error occurred: ${e.toString()}'
      };
    }
  }

  // Get sold quantity for a product
  static Future<Map<String, dynamic>> getSoldQuantity(String maSanPham) async {
    try {
      final headers = {'Content-Type': 'application/json'};
      if (_sessionCookie != null) {
        headers['Cookie'] = _sessionCookie!;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/get_sold_quantity.php?ma_san_pham=$maSanPham'),
        headers: headers,
      );

      print('getSoldQuantity response: ${response.body}');

      final data = json.decode(response.body);
      return data;
    } catch (e) {
      print('Error in getSoldQuantity: $e');
      return {
        'success': false,
        'error': 'An error occurred: ${e.toString()}'
      };
    }
  }

  // Get reviews for a product
  static Future<Map<String, dynamic>> getReviews(String maSanPham) async {
    try {
      final headers = {'Content-Type': 'application/json'};
      if (_sessionCookie != null) {
        headers['Cookie'] = _sessionCookie!;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/get_reviews.php?ma_san_pham=$maSanPham'),
        headers: headers,
      );

      print('getReviews response: ${response.body}');

      final data = json.decode(response.body);
      return data;
    } catch (e) {
      print('Error in getReviews: $e');
      return {
        'success': false,
        'error': 'An error occurred: ${e.toString()}'
      };
    }
  }

  // Get average rating for a product
  static Future<Map<String, dynamic>> getAverageRating(String maSanPham) async {
    try {
      final headers = {'Content-Type': 'application/json'};
      if (_sessionCookie != null) {
        headers['Cookie'] = _sessionCookie!;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/get_average_rating.php?ma_san_pham=$maSanPham'),
        headers: headers,
      );

      print('getAverageRating response: ${response.body}');

      final data = json.decode(response.body);
      return data;
    } catch (e) {
      print('Error in getAverageRating: $e');
      return {
        'success': false,
        'error': 'An error occurred: ${e.toString()}'
      };
    }
  }

  // Get promotions
  static Future<Map<String, dynamic>> getPromotions() async {
    try {
      final headers = {'Content-Type': 'application/json'};
      if (_sessionCookie != null) {
        headers['Cookie'] = _sessionCookie!;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/get_promotions.php'),
        headers: headers,
      );

      print('getPromotions response: ${response.body}');

      final data = json.decode(response.body);
      return data;
    } catch (e) {
      print('Error in getPromotions: $e');
      return {
        'success': false,
        'error': 'An error occurred: ${e.toString()}'
      };
    }
  }

  // Get discount codes
  static Future<Map<String, dynamic>> getDiscountCodes() async {
    try {
      final headers = {'Content-Type': 'application/json'};
      if (_sessionCookie != null) {
        headers['Cookie'] = _sessionCookie!;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/get_discount_codes.php'),
        headers: headers,
      );

      print('getDiscountCodes response: ${response.body}');

      final data = json.decode(response.body);
      return data;
    } catch (e) {
      print('Error in getDiscountCodes: $e');
      return {
        'success': false,
        'error': 'An error occurred: ${e.toString()}'
      };
    }
  }

  // Apply discount code
  static Future<Map<String, dynamic>> applyDiscountCode({
    required String code,
    required String userId,
  }) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
      };
      if (_sessionCookie != null) {
        headers['Cookie'] = _sessionCookie!;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/apply_discount_code.php'),
        headers: headers,
        body: json.encode({
          'ma': code,
          'user_id': userId,
        }),
      );

      print('applyDiscountCode response: ${response.body}');

      final data = json.decode(response.body);
      return data;
    } catch (e) {
      print('Error in applyDiscountCode: $e');
      return {
        'success': false,
        'error': 'An error occurred: ${e.toString()}'
      };
    }
  }

  // Check discount code usage
  static Future<Map<String, dynamic>> checkDiscountCodeUsage({
    required String code,
    required String userId,
  }) async {
    try {
      final headers = {'Content-Type': 'application/json'};
      if (_sessionCookie != null) {
        headers['Cookie'] = _sessionCookie!;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/check_discount_usage.php'),
        headers: headers,
        body: json.encode({
          'code': code,
          'user_id': userId,
        }),
      );

      print('checkDiscountCodeUsage response: ${response.body}');
      final data = json.decode(response.body);
      return {
        'success': data['success'] ?? false,
        'used': data['used'] ?? true,
        'error': data['error'],
      };
    } catch (e) {
      print('Error in checkDiscountCodeUsage: $e');
      return {
        'success': false,
        'used': true,
        'error': 'An error occurred: ${e.toString()}'
      };
    }
  }

  // Get categories
  static Future<Map<String, dynamic>> getCategories() async {
    try {
      final headers = {'Content-Type': 'application/json'};
      if (_sessionCookie != null) {
        headers['Cookie'] = _sessionCookie!;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/categories.php'),
        headers: headers,
      );

      print('getCategories response: ${response.body}');
      final data = json.decode(response.body);

      // Handle both List and Map responses
      if (data is List) {
        return {
          'success': true,
          'categories': data,
          'error': null,
        };
      } else {
        return {
          'success': data['success'] ?? false,
          'categories': data['categories'] ?? [],
          'error': data['error'],
        };
      }
    } catch (e) {
      print('Error in getCategories: $e');
      return {
        'success': false,
        'categories': [],
        'error': 'An error occurred: ${e.toString()}'
      };
    }
  }

  // Search products
  static Future<Map<String, dynamic>> searchProducts(String query) async {
    try {
      final headers = {'Content-Type': 'application/json'};
      if (_sessionCookie != null) {
        headers['Cookie'] = _sessionCookie!;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/search_products.php'),
        headers: headers,
        body: json.encode({'query': query}),
      );

      print('searchProducts response: ${response.body}');
      final data = json.decode(response.body);
      return {
        'success': data['success'] ?? false,
        'products': data['products'] ?? [],
        'error': data['error'],
      };
    } catch (e) {
      print('Error in searchProducts: $e');
      return {
        'success': false,
        'products': [],
        'error': 'An error occurred: ${e.toString()}'
      };
    }
  }

  // Submit review
  static Future<Map<String, dynamic>> submitReview({
    required String orderId,
    required String productId,
    required int rating,
    required String comment,
  }) async {
    try {
      final headers = {'Content-Type': 'application/json'};
      if (_sessionCookie != null) {
        headers['Cookie'] = _sessionCookie!;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/submit_review.php'),
        headers: headers,
        body: json.encode({
          'order_id': orderId,
          'product_id': productId,
          'rating': rating,
          'comment': comment,
        }),
      );

      print('submitReview response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          return {
            'success': data['success'] ?? false,
            'message': data['message'],
            'error': data['error'],
          };
        } catch (e) {
          print('JSON parse error: $e');
          return {
            'success': false,
            'error': 'Lỗi định dạng phản hồi từ server'
          };
        }
      } else {
        return {
          'success': false,
          'error': 'Lỗi server: ${response.statusCode} - ${response.reasonPhrase}',
        };
      }
    } catch (e) {
      print('Error in submitReview: $e');
      return {
        'success': false,
        'error': 'Lỗi kết nối: ${e.toString()}'
      };
    }
  }

  // Add favorite
  static Future<Map<String, dynamic>> addFavorite(String productId) async {
    try {
      final headers = {'Content-Type': 'application/json'};
      if (_sessionCookie != null) {
        headers['Cookie'] = _sessionCookie!;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/add_favorite.php'),
        headers: headers,
        body: json.encode({'product_id': productId}),
      );

      print('addFavorite response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          return {
            'success': data['success'] ?? false,
            'message': data['message'],
            'error': data['error'],
          };
        } catch (e) {
          print('JSON parse error: $e');
          return {'success': false, 'error': 'Lỗi định dạng phản hồi từ server'};
        }
      } else {
        return {'success': false, 'error': 'Lỗi server: ${response.statusCode}'};
      }
    } catch (e) {
      print('Error in addFavorite: $e');
      return {'success': false, 'error': 'Lỗi kết nối: $e'};
    }
  }

  // Remove favorite
  static Future<Map<String, dynamic>> removeFavorite(String productId) async {
    try {
      final headers = {'Content-Type': 'application/json'};
      if (_sessionCookie != null) {
        headers['Cookie'] = _sessionCookie!;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/remove_favorite.php'),
        headers: headers,
        body: json.encode({'product_id': productId}),
      );

      print('removeFavorite response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          return {
            'success': data['success'] ?? false,
            'message': data['message'],
            'error': data['error'],
          };
        } catch (e) {
          print('JSON parse error: $e');
          return {'success': false, 'error': 'Lỗi định dạng phản hồi từ server'};
        }
      } else {
        return {'success': false, 'error': 'Lỗi server: ${response.statusCode}'};
      }
    } catch (e) {
      print('Error in removeFavorite: $e');
      return {'success': false, 'error': 'Lỗi kết nối: $e'};
    }
  }

  // Get favorites
  static Future<Map<String, dynamic>> getFavorites() async {
    try {
      final headers = {'Content-Type': 'application/json'};
      if (_sessionCookie != null) {
        headers['Cookie'] = _sessionCookie!;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/get_favorites.php'),
        headers: headers,
      );

      print('getFavorites response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          return {
            'success': data['success'] ?? false,
            'favorites': data['favorites'],
            'error': data['error'],
          };
        } catch (e) {
          print('JSON parse error: $e');
          return {'success': false, 'error': 'Lỗi định dạng phản hồi từ server'};
        }
      } else {
        return {'success': false, 'error': 'Lỗi server: ${response.statusCode}'};
      }
    } catch (e) {
      print('Error in getFavorites: $e');
      return {'success': false, 'error': 'Lỗi kết nối: $e'};
    }
  }
  static Future<Map<String, dynamic>> cancelOrder(String orderId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/cancel_order.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'order_id': orderId}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'error': 'Lỗi server: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Lỗi kết nối: $e'};
    }
  }
}