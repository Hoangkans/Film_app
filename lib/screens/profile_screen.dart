import 'package:flutter/material.dart';

/// Màn hình hồ sơ người dùng, phong cách Netflix
class ProfileScreen extends StatelessWidget {
  final VoidCallback onLogout; // Callback khi đăng xuất
  const ProfileScreen({required this.onLogout, super.key});

  @override
  Widget build(BuildContext context) {
    final String userName = 'Mark'; // Tên người dùng giả lập
    final String userEmail = 'mark@email.com'; // Email giả lập
    return Scaffold(
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
            // AppBar tùy chỉnh với gradient
            Container(
              padding: EdgeInsets.fromLTRB(16, 40, 16, 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.redAccent, Colors.deepPurple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Text(
                    'Tài khoản',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Avatar người dùng với hiệu ứng
                    AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.redAccent,
                        child: CircleAvatar(
                          radius: 56,
                          backgroundImage: AssetImage('assets/avatar_placeholder.png'),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      userName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      userEmail,
                      style: TextStyle(color: Colors.white70, fontSize: 18),
                    ),
                    SizedBox(height: 32),
                    AnimatedContainer(
                      duration: Duration(milliseconds: 300), // Hiệu ứng nút
                      width: 200,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: onLogout,
                        icon: Icon(Icons.logout, color: Colors.white),
                        label: Text(
                          'Đăng xuất',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
}