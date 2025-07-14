import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/api_service.dart';
import 'movie_detail_screen.dart';

/// Màn hình hiển thị danh sách phim yêu thích, kiểu Netflix
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  /// Danh sách tất cả phim lấy từ API
  List<Movie> allMovies = [];

  /// Danh sách ID phim yêu thích (lưu local)
  Set<int> favoriteIds = {};

  /// Trạng thái loading khi lấy dữ liệu
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMovies();
  }

  /// Lấy danh sách phim từ API
  void _fetchMovies() async {
    final movies = await ApiService.fetchMovies();
    setState(() {
      allMovies = movies;
      isLoading = false;
    });
  }

  /// Thêm hoặc bỏ phim khỏi danh sách yêu thích
  void _toggleFavorite(int id) {
    setState(() {
      if (favoriteIds.contains(id)) {
        favoriteIds.remove(id);
      } else {
        favoriteIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Lọc danh sách phim yêu thích dựa trên favoriteIds
    final favoriteMovies = allMovies
        .where((m) => favoriteIds.contains(m.id))
        .toList();
    return Scaffold(
      backgroundColor: Colors.black, // Màu nền tối kiểu Netflix
      appBar: AppBar(
        backgroundColor: Colors.transparent, // AppBar trong suốt
        elevation: 0, // Bỏ bóng
        title: Text(
          'Yêu Thích',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.redAccent, Colors.deepPurple], // Gradient đỏ-tím
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.grey[900]!], // Gradient nền tối
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(color: Colors.redAccent),
              ) // Hiển thị loading
            : favoriteMovies.isEmpty
            ? Center(
                child: Text(
                  'Chưa có phim yêu thích',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ) // Thông báo khi không có phim yêu thích
            : Padding(
                padding: const EdgeInsets.all(12.0),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // 3 cột
                    childAspectRatio: 0.6, // Tỷ lệ khung hình
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: favoriteMovies.length,
                  itemBuilder: (context, index) {
                    final movie = favoriteMovies[index];
                    return AnimatedContainer(
                      duration: Duration(
                        milliseconds: 300,
                      ), // Hiệu ứng chuyển động
                      curve: Curves.easeInOut,
                      child: Card(
                        elevation: 8, // Bóng cho card
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16), // Bo góc
                        ),
                        child: Stack(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MovieDetailScreen(
                                    id: movie.id,
                                    token: '',
                                  ),
                                ),
                              ), // Chuyển đến màn hình chi tiết
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  image: DecorationImage(
                                    image:
                                        movie.imageUrl != null &&
                                            movie.imageUrl!.isNotEmpty
                                        ? NetworkImage(movie.imageUrl!)
                                        : AssetImage(
                                                'assets/movie_placeholder.jpg',
                                              )
                                              as ImageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                alignment: Alignment.bottomLeft,
                                child: Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(
                                      0.8,
                                    ), // Nền tối cho tiêu đề
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(16),
                                      bottomRight: Radius.circular(16),
                                    ),
                                  ),
                                  child: Text(
                                    movie.name,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () => _toggleFavorite(
                                  movie.id,
                                ), // Thêm/bỏ yêu thích
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.black54,
                                  child: Icon(
                                    favoriteIds.contains(movie.id)
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: Colors.redAccent,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
