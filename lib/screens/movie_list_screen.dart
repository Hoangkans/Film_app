import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/api_service.dart';
import 'movie_detail_screen.dart';
import 'add_movie_screen.dart';

/// Màn hình hiển thị danh sách tất cả các phim dưới dạng một list đơn giản.
///
/// Màn hình này có thể được dùng cho mục đích quản trị, vì nó cho phép
/// thêm phim mới thông qua một nút FloatingActionButton.
/// Sử dụng [FutureBuilder] để tải và hiển thị danh sách phim.
class MovieListScreen extends StatefulWidget {
  /// Token xác thực của người dùng (thường là admin).
  final String token;
  final bool isAdmin;

  /// Callback được gọi khi người dùng nhấn nút đăng xuất.
  final VoidCallback? onLogout;

  const MovieListScreen({
    required this.token,
    required this.isAdmin,
    this.onLogout,
    super.key,
  });

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  /// Future chứa danh sách các bộ phim.
  late Future<List<Movie>> moviesFuture;

  @override
  void initState() {
    super.initState();
    // Bắt đầu tải dữ liệu khi widget được khởi tạo.
    _fetchData();
  }

  /// Gán Future lấy dữ liệu phim cho biến [moviesFuture].
  void _fetchData() {
    setState(() {
      moviesFuture = ApiService.fetchMovies();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quản lý phim'),
        actions: [
          if (widget.onLogout != null)
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: widget.onLogout,
              tooltip: 'Đăng xuất',
            ),
        ],
      ),
      // Sử dụng FutureBuilder để hiển thị UI dựa trên trạng thái của `moviesFuture`.
      body: FutureBuilder<List<Movie>>(
        future: moviesFuture,
        builder: (context, snapshot) {
          // Trạng thái đang chờ
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          // Trạng thái có lỗi
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Lỗi: ${snapshot.error}',
                    style: TextStyle(color: Colors.red),
                  ),
                  SizedBox(height: 8),
                  ElevatedButton(onPressed: _fetchData, child: Text('Thử lại')),
                ],
              ),
            );
          }
          // Trạng thái thành công
          final movies = snapshot.data!;
          if (movies.isEmpty) {
            return Center(child: Text('Không có phim nào trong danh sách.'));
          }
          // Hiển thị danh sách phim bằng ListView.builder
          return RefreshIndicator(
            onRefresh: () async => _fetchData(),
            child: ListView.builder(
              itemCount: movies.length,
              itemBuilder: (context, index) {
                final movie = movies[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    // Ảnh thumbnail của phim
                    leading: CircleAvatar(
                      backgroundImage:
                          (movie.imageUrl != null && movie.imageUrl!.isNotEmpty)
                          ? NetworkImage(movie.imageUrl!)
                          : null,
                      child: (movie.imageUrl == null || movie.imageUrl!.isEmpty)
                          ? Icon(Icons.movie)
                          : null,
                    ),
                    title: Text(
                      movie.name ?? 'Không có tên',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Ngôn ngữ: ${movie.language ?? "Không rõ"} | Đánh giá: ${movie.rating}',
                    ),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () async {
                      // Điều hướng đến màn hình chi tiết và chờ kết quả
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MovieDetailScreen(
                            id: movie.id,
                            token: widget.token,
                            isAdmin: widget.isAdmin,
                          ),
                        ),
                      );
                      // Nếu màn hình chi tiết có thể thay đổi dữ liệu (ví dụ: xóa),
                      // ta có thể kiểm tra kết quả và làm mới danh sách.
                      if (result == true) {
                        _fetchData();
                      }
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
      // Nút để thêm phim mới
      floatingActionButton: (widget.isAdmin)
          ? FloatingActionButton(
              onPressed: () async {
                // Điều hướng đến màn hình thêm phim
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddMovieScreen(
                      token: widget.token,
                      isAdmin: widget.isAdmin,
                    ),
                  ),
                );
                // Nếu việc thêm phim thành công (trả về true), làm mới lại danh sách
                if (result == true) {
                  _fetchData();
                }
              },
              tooltip: 'Thêm phim',
              child: Icon(Icons.add),
            )
          : null,
    );
  }
}
