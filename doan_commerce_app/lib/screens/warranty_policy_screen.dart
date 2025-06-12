import 'package:flutter/material.dart';

class WarrantyPolicyScreen extends StatelessWidget {
  const WarrantyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown,
        elevation: 0,
        title: const Text('Chính sách bảo hành', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Chính sách bảo hành',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                '''
1. **Điều kiện bảo hành**:
- Sản phẩm được bảo hành trong vòng 12 tháng kể từ ngày mua.
- Sản phẩm phải còn nguyên vẹn, không bị hư hỏng do tác động bên ngoài (rơi vỡ, ngấm nước, ...).
- Cần xuất trình hóa đơn mua hàng hoặc mã đơn hàng để xác nhận.

2. **Quy trình bảo hành**:
- Khách hàng liên hệ Trung tâm trợ giúp để đăng ký bảo hành.
- Sản phẩm sẽ được kiểm tra trong vòng 7-14 ngày làm việc.
- Nếu đủ điều kiện, sản phẩm sẽ được sửa chữa hoặc thay thế miễn phí.

3. **Sản phẩm không được bảo hành**:
- Sản phẩm đã hết thời gian bảo hành.
- Sản phẩm bị hư hỏng do sử dụng sai cách hoặc tự ý sửa chữa.
- Phụ kiện đi kèm (dây sạc, tai nghe, ...).

4. **Liên hệ**:
- Vui lòng liên hệ qua Trung tâm trợ giúp hoặc email: support@shop.com.
- Hotline: 0123 456 789 (8:00 - 17:00, Thứ 2 - Thứ 6).
                ''',
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}