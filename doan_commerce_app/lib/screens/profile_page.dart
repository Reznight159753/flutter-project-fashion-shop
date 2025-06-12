import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'edit_profile_screen.dart';
import 'payment_qr_selection_screen.dart';
import 'my_orders_screen.dart';
import 'help_center_screen.dart';
import 'warranty_policy_screen.dart';
import 'new_password_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _userName;
  String? _email;
  String? _avatarUrl;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  // Load user info from AuthService
  Future<void> _loadUserInfo() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final userInfo = await AuthService.getUserInfo();
    print('UserInfo: $userInfo'); // Log user info

    setState(() {
      if (userInfo['success'] == true) {
        _userName = userInfo['user']['ho_ten'];
        _email = userInfo['user']['email'];
        // Extract only the filename from anh_dai_dien
        String? rawAvatarUrl = userInfo['user']['anh_dai_dien'];
        _avatarUrl = rawAvatarUrl != null
            ? rawAvatarUrl.split('/').last // Get only the filename
            : null;
        print('Processed Avatar URL: $_avatarUrl'); // Log processed avatar URL
      } else {
        _errorMessage = userInfo['error'] ?? 'Không thể tải thông tin người dùng';
      }
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown,
        elevation: 0,
        title: const Text('Hồ sơ', style: TextStyle(color: Colors.white)),
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
                      Text(_errorMessage!),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _loadUserInfo,
                        child: const Text('Thử lại'),
                      ),
                      if (_errorMessage == 'Chưa đăng nhập')
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/login',
                              (route) => false,
                            );
                          },
                          child: const Text('Đăng nhập'),
                        ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    const SizedBox(height: 20),
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            key: ValueKey(_avatarUrl), // Force rebuild when _avatarUrl changes
                            radius: 50,
                            backgroundImage: _avatarUrl != null && _avatarUrl!.isNotEmpty
                                ? NetworkImage(
                                    'http://10.0.2.2/shop_api/images_customer/$_avatarUrl',
                                    headers: {'Cache-Control': 'no-cache'},
                                  )
                                : const AssetImage('assets/icons/Profile-active.svg') as ImageProvider,
                            backgroundColor: Colors.grey[300],
                            onBackgroundImageError: _avatarUrl != null && _avatarUrl!.isNotEmpty
                                ? (exception, stackTrace) {
                                    print('Error loading avatar: $exception');
                                    print('Avatar URL attempted: http://10.0.2.2/shop_api/images_customer/$_avatarUrl');
                                  }
                                : null,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _userName ?? 'Người dùng',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            _email ?? 'Chưa có email',
                            style: const TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    Expanded(
                      child: ListView(
                        children: [
                          _buildProfileOption(Icons.person, 'Hồ sơ cá nhân', onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditProfileScreen(
                                  userName: _userName ?? '',
                                  email: _email ?? '',
                                  phone: '',
                                  address: '',
                                  avatarUrl: _avatarUrl,
                                ),
                              ),
                            ).then((_) => _loadUserInfo());
                          }),
                          _buildProfileOption(Icons.payment, 'Phương thức thanh toán', onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PaymentQRSelectionScreen(),
                              ),
                            );
                          }),
                          _buildProfileOption(Icons.shopping_bag, 'Đơn hàng của tôi', onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MyOrdersScreen(),
                              ),
                            );
                          }),
                          _buildProfileOption(Icons.lock, 'Đổi mật khẩu', onTap: () {
                            if (_email != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NewPasswordScreen(email: _email!),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Không tìm thấy email người dùng')),
                              );
                            }
                          }),
                          _buildProfileOption(Icons.help_outline, 'Trung tâm trợ giúp', onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HelpCenterScreen(),
                              ),
                            );
                          }),
                          _buildProfileOption(Icons.security, 'Chính sách bảo hành', onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const WarrantyPolicyScreen(),
                              ),
                            );
                          }),
                          _buildProfileOption(Icons.logout, 'Đăng xuất', onTap: () async {
                            final result = await AuthService.logoutFromServer();
                            if (result['success'] == true) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Đăng xuất thành công')),
                              );
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/login',
                                (route) => false,
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(result['error'] ?? 'Đăng xuất thất bại')),
                              );
                            }
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildProfileOption(IconData icon, String title, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.brown),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap ?? () {},
    );
  }
}