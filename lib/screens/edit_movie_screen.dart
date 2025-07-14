import 'package:flutter/material.dart';
import '../services/api_service.dart';

class EditMovieScreen extends StatefulWidget {
  final int id;
  final String token;
  final String name;
  final String imageUrl;
  const EditMovieScreen({
    required this.id,
    required this.token,
    required this.name,
    required this.imageUrl,
    super.key,
  });

  static Route routeWithArgs(Map args) {
    return MaterialPageRoute(
      builder: (_) => EditMovieScreen(
        id: args['id'],
        token: args['token'] ?? '',
        name: args['name'] ?? '',
        imageUrl: args['imageUrl'] ?? '',
      ),
    );
  }

  @override
  State<EditMovieScreen> createState() => _EditMovieScreenState();
}

class _EditMovieScreenState extends State<EditMovieScreen> {
  late TextEditingController nameController;
  late TextEditingController imageUrlController;
  bool isLoading = false;
  String? error;
  String? success;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.name);
    imageUrlController = TextEditingController(text: widget.imageUrl);
  }

  void editMovie() async {
    setState(() {
      isLoading = true;
      error = null;
      success = null;
    });
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sửa phim')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Tên phim'),
            ),
            TextField(
              controller: imageUrlController,
              decoration: InputDecoration(labelText: 'Image URL'),
            ),
            SizedBox(height: 20),
            if (isLoading) CircularProgressIndicator(),
            if (error != null)
              Text(error!, style: TextStyle(color: Colors.red)),
            if (success != null)
              Text(success!, style: TextStyle(color: Colors.green)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : editMovie,
              child: Text('Lưu thay đổi'),
            ),
          ],
        ),
      ),
    );
  }
}
