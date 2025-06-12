import 'package:flutter/material.dart';
import '../screens/home/home_screen.dart';

class PaymentResultScreen extends StatefulWidget {
  final bool success;
  final int? orderId;

  const PaymentResultScreen({
    super.key,
    required this.success,
    this.orderId,
  });

  @override
  _PaymentResultScreenState createState() => _PaymentResultScreenState();
}

class _PaymentResultScreenState extends State<PaymentResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  
  late Animation<double> _bounceAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _bounceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    // Start animations
    Future.delayed(const Duration(milliseconds: 300), () {
      _bounceController.forward();
    });
    
    Future.delayed(const Duration(milliseconds: 600), () {
      _fadeController.forward();
    });
    
    Future.delayed(const Duration(milliseconds: 900), () {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: widget.success 
                ? [
                    Colors.green[400]!,
                    Colors.teal[300]!,
                    Colors.blue[200]!,
                  ]
                : [
                    Colors.red[400]!,
                    Colors.pink[300]!,
                    Colors.orange[200]!,
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height - 
                                 kToolbarHeight - 
                                 MediaQuery.of(context).padding.top - 
                                 MediaQuery.of(context).padding.bottom - 
                                 100, // Approximate height of app bar + padding
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          _buildResultIcon(),
                          const SizedBox(height: 24),
                          _buildResultContent(),
                          const SizedBox(height: 20),
                          _buildActionButtons(context),
                          const SizedBox(height: 20),
                        ],
                      ),
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

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const Expanded(
            child: Text(
              'Kết quả thanh toán',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 48), // Balance the back button
        ],
      ),
    );
  }

  Widget _buildResultIcon() {
    return ScaleTransition(
      scale: _bounceAnimation,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              Colors.white,
              Colors.white.withOpacity(0.9),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 5,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24), // Reduced from 32
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.success 
                  ? [Colors.green[400]!, Colors.teal[500]!]
                  : [Colors.red[400]!, Colors.pink[500]!],
            ),
            boxShadow: [
              BoxShadow(
                color: (widget.success ? Colors.green : Colors.red).withOpacity(0.4),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20), // Reduced from 24
          child: Icon(
            widget.success ? Icons.check_rounded : Icons.close_rounded,
            color: Colors.white,
            size: 56, // Reduced from 64
          ),
        ),
      ),
    );
  }

  Widget _buildResultContent() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          _buildResultTitle(),
          const SizedBox(height: 12), // Reduced from 16
          _buildResultMessage(),
          if (widget.success && widget.orderId != null) ...[
            const SizedBox(height: 16), // Reduced from 24
            _buildOrderIdCard(),
          ],
          if (widget.success) ...[
            const SizedBox(height: 16), // Reduced from 24
            _buildSuccessFeatures(),
          ],
        ],
      ),
    );
  }

  Widget _buildResultTitle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Reduced padding
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        widget.success ? 'Thanh toán thành công!' : 'Thanh toán thất bại!',
        style: TextStyle(
          fontSize: 22, // Reduced from 24
          fontWeight: FontWeight.bold,
          color: widget.success ? Colors.green[700] : Colors.red[700],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildResultMessage() {
    return Container(
      padding: const EdgeInsets.all(16), // Reduced from 20
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        widget.success
            ? 'Cảm ơn bạn đã tin tựởng và mua sắm tại cửa hàng của chúng tôi! Đơn hàng sẽ được xử lý và giao đến bạn trong thời gian sớm nhất.'
            : 'Rất tiếc! Đã xảy ra lỗi trong quá trình xử lý thanh toán. Đừng lo lắng, hãy thử lại hoặc liên hệ với chúng tôi để được hỗ trợ.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 15, // Reduced from 16
          color: Colors.grey[700],
          height: 1.4, // Reduced from 1.5
        ),
      ),
    );
  }

  Widget _buildOrderIdCard() {
    return Container(
      padding: const EdgeInsets.all(16), // Reduced from 20
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[50]!, Colors.indigo[50]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue[200]!, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.receipt_long, color: Colors.blue[600], size: 24),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mã đơn hàng',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                '#${widget.orderId}',
                style: TextStyle(
                  fontSize: 18, // Reduced from 20
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessFeatures() {
    return Container(
      padding: const EdgeInsets.all(16), // Reduced from 20
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Những gì sẽ xảy ra tiếp theo:',
            style: TextStyle(
              fontSize: 15, // Reduced from 16
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          _buildFeatureItem(Icons.local_shipping_outlined, 'Đơn hàng sẽ được chuẩn bị'),
          _buildFeatureItem(Icons.notifications_active_outlined, 'Thông báo khi giao hàng'),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6), // Reduced from 8
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.green[600], size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ),
          Icon(Icons.check_circle, color: Colors.green[500], size: 16),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 52, // Reduced from 56
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: widget.success 
                    ? [Colors.orange[500]!, Colors.red[400]!]
                    : [Colors.blue[500]!, Colors.indigo[400]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: (widget.success ? Colors.orange : Colors.blue).withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.home_rounded, color: Colors.white, size: 22), // Reduced from 24
                  const SizedBox(width: 8),
                  const Text(
                    'Quay lại trang chủ',
                    style: TextStyle(
                      fontSize: 16, // Reduced from 18
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!widget.success) ...[
            const SizedBox(height: 12),
            Container(
              height: 52, // Reduced from 56
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[300]!, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Go back to try again
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.refresh_rounded, color: Colors.grey[700], size: 22), // Reduced from 24
                    const SizedBox(width: 8),
                    Text(
                      'Thử lại thanh toán',
                      style: TextStyle(
                        fontSize: 16, // Reduced from 18
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}