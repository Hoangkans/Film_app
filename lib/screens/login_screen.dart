import 'package:flutter/material.dart';
import '../services/api_service.dart';

/// Màn hình đăng nhập với giao diện hiện đại, tối màu.
///
/// Cung cấp các trường nhập email, mật khẩu và các nút để đăng nhập,
/// chuyển sang màn hình đăng ký, hoặc thoát về trang chủ.
class LoginScreen extends StatefulWidget {
  /// Callback được gọi khi đăng nhập thành công.
  ///
  /// Trả về `token` và `email` của người dùng.
  final Function(String token, String email) onLogin;

  /// Callback để điều hướng đến màn hình đăng ký.
  final VoidCallback? onRegister;

  /// Callback để thoát khỏi màn hình đăng nhập và quay về trang chủ (chế độ khách).
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
  // Controller để quản lý text trong các trường nhập liệu.
  // Khởi tạo sẵn với tài khoản demo để tiện cho việc kiểm thử.
  final emailController = TextEditingController(text: 'mark@email.com');
  final passwordController = TextEditingController(text: 'User2#4509');

  // Biến trạng thái
  String? error; // Lưu thông báo lỗi nếu có.
  bool isLoading =
      false; // Cờ cho biết có đang trong quá trình đăng nhập hay không.

  /// Xử lý logic đăng nhập.
  ///
  /// Gọi [ApiService.login] và xử lý kết quả trả về.
  /// Cập nhật trạng thái [isLoading] và [error].
  /// Gọi callback [onLogin] nếu thành công.
  void login() async {
    // Ẩn bàn phím nếu đang mở.
    FocusScope.of(context).unfocus();

    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final result = await ApiService.login(
        emailController.text,
        passwordController.text,
      );

      // Sau khi await, kiểm tra xem widget có còn tồn tại không.
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      if (result != null) {
        // Đăng nhập thành công, gọi callback.
        widget.onLogin(result['token']!, result['email']!);
      } else {
        // Đăng nhập thất bại, hiển thị thông báo lỗi.
        setState(
          () => error =
              'Đăng nhập thất bại. Kiểm tra lại tài khoản hoặc mật khẩu!',
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        error = 'Đã xảy ra lỗi: $e';
      });
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
                // Icon và tiêu đề của màn hình
                Icon(
                  Icons.movie_filter_sharp,
                  color: Colors.redAccent,
                  size: 64,
                ),
                SizedBox(height: 16),
                Text(
                  'Đăng nhập Cinema',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 32),
                // Trường nhập email
                TextField(
                  controller: emailController,
                  style: TextStyle(color: Colors.white),
                  keyboardType: TextInputType.emailAddress,
                  decoration: _buildInputDecoration('Email'),
                ),
                SizedBox(height: 20),
                // Trường nhập mật khẩu
                TextField(
                  controller: passwordController,
                  style: TextStyle(color: Colors.white),
                  obscureText: true, // Ẩn mật khẩu
                  decoration: _buildInputDecoration('Mật khẩu'),
                ),
                SizedBox(height: 16),
                // Hiển thị thông báo lỗi (nếu có)
                if (error != null)
                  Text(
                    error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.redAccent),
                  ),
                SizedBox(height: 16),
                // Nút Đăng nhập
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    // Vô hiệu hóa nút khi đang tải
                    onPressed: isLoading ? null : login,
                    child: isLoading
                        // Hiển thị vòng quay tải nhỏ trên nút
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : Text(
                            'Đăng nhập',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                  ),
                ),
                SizedBox(height: 16),

                SizedBox(height: 24),
                // Hộp thông tin tài khoản demo
                _buildDemoAccountBox(),
                SizedBox(height: 24),
                // Nút thoát (nếu được cung cấp)
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

  /// Helper để xây dựng trang trí cho các trường TextField.
  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Colors.white10,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none, // Bỏ viền mặc định
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.redAccent), // Viền khi focus
      ),
    );
  }

  /// Widget hiển thị thông tin tài khoản demo.
  Widget _buildDemoAccountBox() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          Text(
            'Sử dụng tài khoản demo:',
            style: TextStyle(color: Colors.white70),
          ),
          SizedBox(height: 4),
          SelectableText(
            'Email: mark@email.com',
            style: TextStyle(color: Colors.white),
          ),
          SelectableText(
            'Mật khẩu: User2#4509',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
