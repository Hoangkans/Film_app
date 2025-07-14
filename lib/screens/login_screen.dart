import 'package:flutter/material.dart';
import '../services/api_service.dart';

/// Màn hình đăng nhập hiện đại, đẹp mắt
class LoginScreen extends StatefulWidget {
  final Function(String token, String email) onLogin;
  final VoidCallback? onRegister;
  final VoidCallback? onExit;
  const LoginScreen({
    required this.onLogin,
    this.onRegister,
    this.onExit,
    super.key,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController(text: 'mark@email.com');
  final passwordController = TextEditingController(text: 'User2#4509');
  String? error;
  bool isLoading = false;

  void login() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    final result = await ApiService.login(
      emailController.text,
      passwordController.text,
    );
    setState(() {
      isLoading = false;
    });
    if (result != null) {
      widget.onLogin(result['token']!, result['email']!);
    } else {
      setState(
        () =>
            error = 'Đăng nhập thất bại. Kiểm tra lại tài khoản hoặc mật khẩu!',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.movie, color: Colors.redAccent, size: 64),
                SizedBox(height: 16),
                Text(
                  'Đăng nhập',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 32),
                TextField(
                  controller: emailController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white10,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: passwordController,
                  style: TextStyle(color: Colors.white),
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu',
                    labelStyle: TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white10,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                if (error != null)
                  Text(error!, style: TextStyle(color: Colors.redAccent)),
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: isLoading ? null : login,
                    child: isLoading
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text('Đăng nhập', style: TextStyle(fontSize: 18)),
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Chưa có tài khoản?',
                      style: TextStyle(color: Colors.white70),
                    ),
                    TextButton(
                      onPressed: widget.onRegister,
                      child: Text(
                        'Đăng ký ngay',
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Tài khoản demo:',
                        style: TextStyle(color: Colors.white70),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Email: mark@email.com',
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(
                        'Mật khẩu: User2#4509',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                if (widget.onExit != null)
                  TextButton.icon(
                    onPressed: widget.onExit,
                    icon: Icon(Icons.home, color: Colors.white70),
                    label: Text(
                      'Thoát về trang chủ',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
