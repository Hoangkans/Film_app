import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

/// Màn hình cho phép người dùng (admin) chỉnh sửa thông tin một bộ phim đã có.
///
/// Yêu cầu `token` để xác thực và `id`, `name`, `imageUrl` của phim cần sửa.
class EditMovieScreen extends StatefulWidget {
  final int id;
  final String token;
  final String name;
  final String imageUrl;
  final bool isAdmin;
  const EditMovieScreen({
    required this.id,
    required this.token,
    required this.name,
    required this.imageUrl,
    required this.isAdmin,
    super.key,
  });

  /// Phương thức tĩnh để tạo một [Route] cho màn hình này từ một Map các tham số.
  ///
  /// Giúp việc điều hướng trở nên dễ dàng và an toàn hơn.
  static Route routeWithArgs(Map args) {
    return MaterialPageRoute(
      builder: (_) => EditMovieScreen(
        id: args['id'],
        token: args['token'] ?? '',
        name: args['name'] ?? '',
        imageUrl: args['imageUrl'] ?? '',
        isAdmin: args['isAdmin'] ?? false,
      ),
    );
  }

  @override
  State<EditMovieScreen> createState() => _EditMovieScreenState();
}

class _EditMovieScreenState extends State<EditMovieScreen> {
  // Controller cho các trường nhập liệu
  late TextEditingController nameController;
  late TextEditingController durationController;
  late TextEditingController languageController;
  late TextEditingController ratingController;
  late TextEditingController genreController;
  late TextEditingController imageUrlController;

  // URL xem trước ảnh
  String _mainImagePreviewUrl = '';
  Timer? _debounce;

  // Trạng thái của màn hình
  bool isLoading = false;
  String? error;
  String? success;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.name);
    durationController = TextEditingController();
    languageController = TextEditingController();
    ratingController = TextEditingController();
    genreController = TextEditingController();
    imageUrlController = TextEditingController(text: widget.imageUrl);
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

  /// Gửi yêu cầu cập nhật thông tin phim đến API.
  ///
  /// Cập nhật trạng thái [isLoading], [error], và [success].
  /// Nếu thành công, quay lại màn hình trước đó.
  void editMovie() async {
    FocusScope.of(context).unfocus();
    setState(() {
      isLoading = true;
      error = null;
      success = null;
    });
    try {
      final ok = await ApiService.editMovie(
        id: widget.id,
        name: nameController.text,
        imageUrl: imageUrlController.text,
        token: widget.token,
      );
      setState(() {
        isLoading = false;
        if (ok) {
          success = 'Sửa phim thành công!';
          Future.delayed(Duration(milliseconds: 600), () {
            Navigator.pop(context, true);
          });
        } else {
          error = 'Sửa phim thất bại!';
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
      appBar: AppBar(title: Text('Sửa thông tin phim')),
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
              onPressed: isLoading ? null : editMovie,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              child: Text('Lưu thay đổi'),
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
