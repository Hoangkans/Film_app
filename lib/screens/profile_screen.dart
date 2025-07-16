import 'package:flutter/material.dart';

/// Màn hình hồ sơ người dùng với giao diện theo phong cách Netflix.
///
/// Hiển thị avatar và nút đăng xuất.
class ProfileScreen extends StatelessWidget {
  /// Callback được gọi khi người dùng nhấn nút Đăng xuất.
  final VoidCallback onLogout;
  final String? userEmail;

  const ProfileScreen({required this.onLogout, this.userEmail, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Container chính với nền gradient.
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.deepPurple.shade900], // Gradient nền
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // AppBar tùy chỉnh để có thể thêm gradient.
            _buildCustomAppBar(),
            // Phần thân chính của màn hình.
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Avatar người dùng với hiệu ứng viền.
                    CircleAvatar(
                      radius: 64,
                      backgroundColor: Colors.redAccent.withOpacity(0.8),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: AssetImage(
                          'assets/avatar_placeholder.png',
                        ),
                        onBackgroundImageError: (e, s) =>
                            print('Lỗi tải ảnh avatar'),
                      ),
                    ),
                    SizedBox(height: 24),
                    if (userEmail != null)
                      Text(
                        userEmail!,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    SizedBox(height: 24),
                    // Nút Đăng xuất.
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                      ),
                      onPressed: onLogout,
                      icon: Icon(Icons.logout, color: Colors.white),
                      label: Text(
                        'Đăng xuất',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Xây dựng một AppBar tùy chỉnh.
  Widget _buildCustomAppBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 40, 16, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red[900]!, Colors.deepPurple.shade900],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.person_pin, color: Colors.white, size: 30),
          SizedBox(width: 12),
          Text(
            'Tài khoản của tôi',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
