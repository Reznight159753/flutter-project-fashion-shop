import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/auth_service.dart';

class EditProfileScreen extends StatefulWidget {
  final String userName;
  final String email;
  final String phone;
  final String address;
  final String? avatarUrl;

  const EditProfileScreen({
    super.key,
    required this.userName,
    required this.email,
    required this.phone,
    required this.address,
    this.avatarUrl,
  });

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  File? _profileImage;
  final _picker = ImagePicker();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final userInfo = await AuthService.getUserInfo();
    setState(() {
      if (userInfo['success'] == true) {
        _nameController.text = userInfo['user']['ho_ten'] ?? widget.userName;
        _emailController.text = userInfo['user']['email'] ?? widget.email;
        _phoneController.text = userInfo['user']['so_dien_thoai'] ?? widget.phone;
        _addressController.text = userInfo['user']['dia_chi'] ?? widget.address;
      } else {
        _errorMessage = userInfo['error'] ?? 'Không thể tải thông tin';
      }
      _isLoading = false;
    });
  }

  Future<void> _requestPermissionAndPickImage() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.photos,
      Permission.storage,
    ].request();

    final cameraGranted = statuses[Permission.camera]?.isGranted ?? false;
    final photosGranted = statuses[Permission.photos]?.isGranted ?? false;
    final storageGranted = statuses[Permission.storage]?.isGranted ?? false;

    if (cameraGranted && (photosGranted || storageGranted)) {
      _showImageSourcePicker();
    } else {
      _showPermissionDeniedDialog();
    }
  }

  void _showImageSourcePicker() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Chụp ảnh"),
              onTap: () async {
                Navigator.pop(context);
                final file = await _picker.pickImage(source: ImageSource.camera);
                if (file != null) {
                  setState(() {
                    _profileImage = File(file.path);
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Chọn từ thư viện"),
              onTap: () async {
                Navigator.pop(context);
                final file = await _picker.pickImage(source: ImageSource.gallery);
                if (file != null) {
                  setState(() {
                    _profileImage = File(file.path);
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Yêu cầu quyền truy cập'),
        content: const Text(
          'Để thay đổi ảnh đại diện, vui lòng cho phép truy cập vào máy ảnh và thư viện ảnh.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Mở cài đặt'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Vui lòng nhập họ tên';
      });
      return;
    }
    if (_emailController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Vui lòng nhập email';
      });
      return;
    }
    if (_phoneController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Vui lòng nhập số điện thoại';
      });
      return;
    }
    if (_addressController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Vui lòng nhập địa chỉ';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final userId = await AuthService.getUserId();
    if (userId == null) {
      setState(() {
        _errorMessage = 'Chưa đăng nhập';
        _isLoading = false;
      });
      return;
    }

    final result = await AuthService.updateProfile(
      userId: userId,
      hoTen: _nameController.text.trim(),
      email: _emailController.text.trim(),
      soDienThoai: _phoneController.text.trim(),
      diaChi: _addressController.text.trim(),
      anhDaiDien: _profileImage,
    );

    setState(() {
      _isLoading = false;
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật hồ sơ thành công')),
        );
        Navigator.pop(context);
      } else {
        _errorMessage = result['error'] ?? 'Cập nhật hồ sơ thất bại';
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown,
        elevation: 0,
        title: const Text('Chỉnh sửa hồ sơ', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Chỉnh sửa hồ sơ',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Cập nhật thông tin cá nhân của bạn. Các trường có dấu (*) là bắt buộc.',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: GestureDetector(
                      onTap: _requestPermissionAndPickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: _profileImage != null
                            ? FileImage(_profileImage!)
                            : widget.avatarUrl != null && widget.avatarUrl!.isNotEmpty
                                ? NetworkImage('http://10.0.2.2/shop_api/images_customer/${widget.avatarUrl}')
                                : const AssetImage('assets/icons/Profile-active.svg') as ImageProvider,
                        child: _profileImage == null && widget.avatarUrl == null
                            ? const Icon(
                                Icons.camera_alt,
                                size: 30,
                                color: Colors.white70,
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    label: 'Họ tên (*)',
                    controller: _nameController,
                    hint: 'Nguyen Van A',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Email (*)',
                    controller: _emailController,
                    hint: 'example@gmail.com',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Số điện thoại (*)',
                    controller: _phoneController,
                    hint: '+84 • Nhập số điện thoại',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Địa chỉ (*)',
                    controller: _addressController,
                    hint: '123 Đường ABC, Quận XYZ',
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Lưu thay đổi',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
        ),
      ],
    );
  }
}