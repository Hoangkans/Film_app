import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddMovieScreen extends StatefulWidget {
  final String token;
  const AddMovieScreen({required this.token, super.key});

  static Route routeWithToken(String? token) {
    return MaterialPageRoute(
      builder: (_) => AddMovieScreen(token: token ?? ''),
    );
  }

  @override
  State<AddMovieScreen> createState() => _AddMovieScreenState();
}

class _AddMovieScreenState extends State<AddMovieScreen> {
  final nameController = TextEditingController();
  final imageUrlController = TextEditingController();
  bool isLoading = false;
  String? error;
  String? success;

  void addMovie() async {
    setState(() {
      isLoading = true;
      error = null;
      success = null;
    });
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
        imageUrlController.clear();
        Future.delayed(Duration(milliseconds: 600), () {
          Navigator.pop(context, true);
        });
      } else {
        error = 'Thêm phim thất bại!';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Thêm phim mới')),
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
              onPressed: isLoading ? null : addMovie,
              child: Text('Thêm phim'),
            ),
          ],
        ),
      ),
    );
  }
}
