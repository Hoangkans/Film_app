import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences
import '../models/movie.dart';
import '../services/api_service.dart';
import 'movie_detail_screen.dart';

/// Màn hình hiển thị danh sách các bộ phim mà người dùng đã đánh dấu là "yêu thích".
///
/// Giao diện được thiết kế theo phong cách tối, tương tự Netflix.
/// Dữ liệu yêu thích được lưu trữ cục bộ trên thiết bị.
class FavoritesScreen extends StatefulWidget {
  /// Token xác thực của người dùng (nếu có).
  final String? token;
  final bool isAdmin;

  const FavoritesScreen({this.token, this.isAdmin = false, super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  /// Danh sách tất cả các bộ phim có sẵn.
  /// LƯU Ý: Trong một ứng dụng thực tế, danh sách này nên được quản lý
  /// bởi một state management solution (Provider, BLoC,...) để tránh
  /// việc gọi API lặp lại ở nhiều màn hình.
  List<Movie> allMovies = [];

  /// Một Set chứa ID của các bộ phim yêu thích.
  /// Sử dụng Set giúp kiểm tra (contains) và thêm/xóa (add/remove) hiệu quả hơn List.
  Set<int> favoriteIds = {};

  /// Cờ báo hiệu trạng thái tải dữ liệu từ API.
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Tải danh sách phim và các ID yêu thích đã lưu khi màn hình được khởi tạo.
    _loadFavoritesAndFetchMovies();
  }

  /// Tải danh sách ID phim yêu thích từ SharedPreferences và sau đó tải danh sách phim từ API.
  Future<void> _loadFavoritesAndFetchMovies() async {
    await _loadFavoriteIds();
    await _fetchMovies();
  }

  /// Tải danh sách ID phim yêu thích từ bộ nhớ cục bộ (SharedPreferences).
  Future<void> _loadFavoriteIds() async {
    final prefs = await SharedPreferences.getInstance();
    // Lấy danh sách string từ key 'favoriteMovies', nếu không có thì trả về list rỗng.
    final favoriteIdStrings = prefs.getStringList('favoriteMovies') ?? [];
    // Chuyển đổi danh sách String thành Set<int>.
    setState(() {
      favoriteIds = favoriteIdStrings.map(int.parse).toSet();
    });
  }

  /// Lấy danh sách tất cả các phim từ [ApiService].
  Future<void> _fetchMovies() async {
    // Đảm bảo widget vẫn còn trong cây widget trước khi cập nhật state.
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });
    try {
      final movies = await ApiService.fetchMovies();
      if (mounted) {
        setState(() {
          allMovies = movies;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          // Có thể hiển thị một thông báo lỗi ở đây
          print('Lỗi khi tải phim: $e');
        });
      }
    }
  }

  /// Lưu danh sách ID phim yêu thích vào SharedPreferences.
  Future<void> _saveFavoriteIds() async {
    final prefs = await SharedPreferences.getInstance();
    // Chuyển đổi Set<int> thành List<String> để lưu.
    final favoriteIdStrings = favoriteIds.map((id) => id.toString()).toList();
    await prefs.setStringList('favoriteMovies', favoriteIdStrings);
  }

  /// Thêm hoặc xóa một phim khỏi danh sách yêu thích và lưu lại thay đổi.
  void _toggleFavorite(int id) {
    setState(() {
      if (favoriteIds.contains(id)) {
        favoriteIds.remove(id);
      } else {
        favoriteIds.add(id);
      }
      // Sau khi thay đổi, lưu lại danh sách ID vào SharedPreferences.
      _saveFavoriteIds();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Lọc ra danh sách các đối tượng Movie là phim yêu thích.
    final favoriteMovies = allMovies
        .where((m) => favoriteIds.contains(m.id))
        .toList();

    return Scaffold(
      backgroundColor: Colors.black, // Nền đen cho cảm giác như Netflix.
      appBar: AppBar(
        backgroundColor: Colors.transparent, // AppBar trong suốt.
        elevation: 0,
        title: Text(
          'Yêu Thích',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        // Tạo một dải màu gradient cho appbar.
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red[900]!, Colors.black],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        // Gradient cho nền của body.
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.grey[900]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: isLoading
            ? Center(child: CircularProgressIndicator(color: Colors.redAccent))
            : favoriteMovies.isEmpty
            ? _buildEmptyState()
            : _buildFavoritesGrid(favoriteMovies),
      ),
    );
  }

  /// Widget hiển thị khi không có phim yêu thích nào.
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.movie_filter_outlined, color: Colors.white54, size: 80),
          SizedBox(height: 16),
          Text(
            'Danh sách yêu thích trống',
            style: TextStyle(color: Colors.white70, fontSize: 18),
          ),
          Text(
            'Thêm phim bằng cách nhấn vào biểu tượng trái tim.',
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
        ],
      ),
    );
  }

  /// Widget hiển thị danh sách phim yêu thích dưới dạng lưới.
  Widget _buildFavoritesGrid(List<Movie> favoriteMovies) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // Hiển thị 3 cột.
          childAspectRatio: 0.6, // Tỷ lệ chiều rộng/cao của mỗi item.
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: favoriteMovies.length,
        itemBuilder: (context, index) {
          final movie = favoriteMovies[index];
          return _buildMovieCard(movie);
        },
      ),
    );
  }

  /// Widget xây dựng card cho mỗi bộ phim.
  Widget _buildMovieCard(Movie movie) {
    // Truyền token thật sự vào MovieDetailScreen nếu API yêu cầu.
    final String? userToken = widget.token;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MovieDetailScreen(
            id: movie.id,
            token: userToken,
            isAdmin: widget.isAdmin,
          ),
        ),
      ),
      child: Card(
        elevation: 8,
        clipBehavior: Clip.antiAlias, // Cắt các widget con theo bo góc.
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Ảnh nền của phim
            Image.network(
              movie.imageUrl ?? '',
              fit: BoxFit.cover,
              // Hiển thị placeholder khi ảnh lỗi hoặc đang tải.
              errorBuilder: (context, error, stackTrace) =>
                  Center(child: Icon(Icons.movie, color: Colors.grey)),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(child: CircularProgressIndicator());
              },
            ),
            // Lớp phủ gradient ở dưới để làm nổi bật tên phim.
            _buildGradientOverlay(),
            // Tên phim
            Positioned(
              bottom: 10,
              left: 10,
              right: 10,
              child: Text(
                movie.name ?? 'Không có tên',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  shadows: [Shadow(blurRadius: 2, color: Colors.black)],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Nút yêu thích
            Positioned(
              top: 4,
              right: 4,
              child: IconButton(
                icon: Icon(
                  favoriteIds.contains(movie.id)
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: Colors.redAccent,
                ),
                onPressed: () => _toggleFavorite(movie.id),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Lớp phủ gradient để làm nổi bật văn bản trên ảnh.
  Widget _buildGradientOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.5, 1.0],
        ),
      ),
    );
  }
}
