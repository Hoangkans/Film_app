import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

/// Màn hình cho phép người dùng (admin) thêm một bộ phim mới.
///
/// Yêu cầu `token` để xác thực với API.
class AddMovieScreen extends StatefulWidget {
  /// Token xác thực của người dùng (admin).
  final String token;
  final bool isAdmin;
  const AddMovieScreen({required this.token, required this.isAdmin, super.key});

  /// Phương thức tĩnh để tạo một [Route] cho màn hình này.
  ///
  /// Giúp việc điều hướng trở nên dễ dàng và an toàn hơn bằng cách xử lý token null.
  static Route routeWithToken(String? token, bool isAdmin) {
    return MaterialPageRoute(
      builder: (_) => AddMovieScreen(token: token ?? '', isAdmin: isAdmin),
    );
  }

  @override
  State<AddMovieScreen> createState() => _AddMovieScreenState();
}

class _AddMovieScreenState extends State<AddMovieScreen> {
  // Controller cho các trường nhập liệu
  final nameController = TextEditingController();
  final durationController = TextEditingController();
  final languageController = TextEditingController();
  final ratingController = TextEditingController();
  final genreController = TextEditingController();
  final imageUrlController = TextEditingController();

  // URL xem trước ảnh
  String _mainImagePreviewUrl = '';
  Timer? _debounce;

  // Trạng thái của màn hình
  bool isLoading = false; // Cờ cho biết có đang tải dữ liệu không
  String? error; // Thông báo lỗi
  String? success; // Thông báo thành công

  @override
  void initState() {
    super.initState();
    imageUrlController.addListener(
      () => _onUrlChanged(imageUrlController, (url) {
        if (mounted) setState(() => _mainImagePreviewUrl = url);
      }),
    );
  }

  /// Xử lý khi URL thay đổi với debounce để tránh gọi lại liên tục
  void _onUrlChanged(
    TextEditingController controller,
    Function(String) updatePreviewUrl,
  ) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      updatePreviewUrl(controller.text);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    nameController.dispose();
    durationController.dispose();
    languageController.dispose();
    ratingController.dispose();
    genreController.dispose();
    imageUrlController.dispose();
    super.dispose();
  }

  /// Gửi yêu cầu thêm phim mới đến API.
  ///
  /// Cập nhật trạng thái [isLoading], [error], và [success] tương ứng.
  /// Nếu thành công, xóa các trường nhập liệu và quay lại màn hình trước đó.
  void addMovie() async {
    FocusScope.of(context).unfocus();
    setState(() {
      isLoading = true;
      error = null;
      success = null;
    });
    try {
      final ok = await ApiService.addMovie(
        name: nameController.text,
        imageUrl: imageUrlController.text,
        token: widget.token,
      );
      setState(() {
        isLoading = false;
        if (ok) {
          success = 'Thêm phim thành công!';
          nameController.clear();
          durationController.clear();
          languageController.clear();
          ratingController.clear();
          genreController.clear();
          imageUrlController.clear();
          Future.delayed(Duration(milliseconds: 600), () {
            Navigator.pop(context, true);
          });
        } else {
          error = 'Thêm phim thất bại!';
        }
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        error = 'Đã xảy ra lỗi: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Thêm phim mới')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Tên phim',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: durationController,
              decoration: InputDecoration(
                labelText: 'Thời lượng',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: languageController,
              decoration: InputDecoration(
                labelText: 'Ngôn ngữ',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: ratingController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Điểm đánh giá',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: genreController,
              decoration: InputDecoration(
                labelText: 'Thể loại',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: imageUrlController,
              decoration: InputDecoration(
                labelText: 'URL Hình ảnh',
                border: OutlineInputBorder(),
              ),
            ),
            _buildImagePreview(imageUrlController.text),
            SizedBox(height: 20),
            if (isLoading)
              CircularProgressIndicator()
            else if (error != null)
              Text(error!, style: TextStyle(color: Colors.red, fontSize: 16))
            else if (success != null)
              Text(
                success!,
                style: TextStyle(color: Colors.green, fontSize: 16),
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : addMovie,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              child: Text('Thêm phim'),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget hiển thị ảnh xem trước từ URL
  Widget _buildImagePreview(String url) {
    // Chỉ hiển thị nếu URL hợp lệ
    if (url.isEmpty ||
        !(url.startsWith('http://') || url.startsWith('https://'))) {
      return SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Image.network(
        url,
        height: 150,
        width: double.infinity,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            height: 150,
            alignment: Alignment.center,
            child: CircularProgressIndicator(
              value: progress.expectedTotalBytes != null
                  ? progress.cumulativeBytesLoaded /
                        progress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 100,
            color: Colors.grey[850],
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.redAccent),
                SizedBox(height: 8),
                Text(
                  'Không thể tải ảnh xem trước',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
