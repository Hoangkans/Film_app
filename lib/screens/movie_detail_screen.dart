import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/api_service.dart';

/// Màn hình hiển thị chi tiết thông tin của một bộ phim.
///
/// Sử dụng [FutureBuilder] để tải và hiển thị dữ liệu từ API.
/// Giao diện bao gồm ảnh nền lớn của phim, thông tin chi tiết và các nút hành động.
class MovieDetailScreen extends StatefulWidget {
  /// ID của bộ phim cần hiển thị.
  final int id;

  /// Token xác thực của người dùng (nếu có).
  final String? token;
  final bool isAdmin;

  const MovieDetailScreen({
    required this.id,
    this.token,
    this.isAdmin = false,
    super.key,
  });

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  /// Một Future chứa thông tin chi tiết của bộ phim.
  ///
  /// Được khởi tạo trong `initState` và được sử dụng bởi `FutureBuilder`.
  late Future<Movie> movieFuture;

  // TODO: Cần một biến trạng thái để theo dõi phim này có được yêu thích hay không.
  // Ví dụ: bool isFavorite = false;
  // Và cần các hàm để load/save trạng thái này từ SharedPreferences.

  @override
  void initState() {
    super.initState();
    // Bắt đầu quá trình tải dữ liệu chi tiết phim từ API.
    movieFuture = ApiService.fetchMovieDetail(widget.id, widget.token ?? '');

    // TODO: Tại đây, nên tải trạng thái yêu thích của phim từ bộ nhớ cục bộ.
    // _loadFavoriteStatus();
  }

  // TODO: Implement _loadFavoriteStatus() and _toggleFavoriteStatus() methods.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // Sử dụng FutureBuilder để xử lý các trạng thái của Future (loading, error, success).
      body: FutureBuilder<Movie>(
        future: movieFuture,
        builder: (context, snapshot) {
          // Trạng thái đang tải
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: Colors.redAccent),
            );
          }
          // Trạng thái có lỗi
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Không thể tải chi tiết phim: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            );
          }
          // Trạng thái thành công
          final movie = snapshot.data!;
          // Dùng Stack để xếp chồng các lớp UI lên nhau (ảnh nền, gradient, nội dung).
          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(movie),
              SliverToBoxAdapter(child: _buildMovieInfo(movie)),
            ],
          );
        },
      ),
    );
  }

  /// Xây dựng AppBar tùy chỉnh co giãn (SliverAppBar).
  Widget _buildSliverAppBar(Movie movie) {
    return SliverAppBar(
      expandedHeight: 350.0, // Chiều cao tối đa của appbar khi mở rộng
      backgroundColor: Colors.black,
      pinned: true, // Ghim AppBar ở trên cùng khi cuộn
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.black54,
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      actions: [
        if (widget.isAdmin)
          IconButton(
            icon: Icon(Icons.delete, color: Colors.redAccent),
            tooltip: 'Xóa phim',
            onPressed: () => _showDeleteConfirmationDialog(),
          ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Ảnh nền của phim
            Image.network(
              movie.imageUrl ?? '',
              fit: BoxFit.cover,
              errorBuilder: (context, e, s) => Container(
                color: Colors.grey[800],
                child: Icon(Icons.movie, size: 100),
              ),
            ),
            // Lớp phủ gradient để làm mờ ảnh và nổi bật tiêu đề
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.5, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Hiển thị hộp thoại xác nhận xóa phim
  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text('Xác nhận xóa', style: TextStyle(color: Colors.white)),
          content: Text(
            'Bạn có chắc chắn muốn xóa phim này không? Hành động này không thể hoàn tác.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Hủy', style: TextStyle(color: Colors.white70)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(backgroundColor: Colors.redAccent),
              child: Text('Xóa', style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.of(context).pop(); // Đóng hộp thoại
                _deleteMovie(); // Gọi hàm xóa phim
              },
            ),
          ],
        );
      },
    );
  }

  /// Gọi API để xóa phim và xử lý kết quả
  Future<void> _deleteMovie() async {
    // Hiển thị loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Đang xóa...'),
          ],
        ),
      ),
    );

    try {
      final success = await ApiService.deleteMovie(
        id: widget.id,
        token: widget.token ?? '',
      );

      // Ẩn loading indicator
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Xóa phim thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        // Quay về màn hình trước đó và báo hiệu rằng đã có thay đổi (true)
        Navigator.of(context).pop(true);
      } else {
        _showErrorSnackBar('Xóa phim thất bại.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      _showErrorSnackBar('Đã xảy ra lỗi: $e');
    }
  }

  /// Hiển thị SnackBar báo lỗi
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  /// Xây dựng phần nội dung thông tin chi tiết của phim.
  Widget _buildMovieInfo(Movie movie) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thông tin thô để debug
          Container(
            width: double.infinity,
            color: Colors.black12,
            padding: EdgeInsets.all(8),
            margin: EdgeInsets.only(bottom: 8),
            child: Text(
              movieToDebugString(movie),
              style: TextStyle(color: Colors.yellowAccent, fontSize: 12),
            ),
          ),
          // Tên phim và nút yêu thích
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  movie.name ?? 'Không có tên',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  // TODO: Thay đổi icon dựa trên biến `isFavorite`
                  Icons.favorite_border,
                  color: Colors.redAccent,
                  size: 32,
                ),
                onPressed: () {
                  // TODO: Gọi hàm _toggleFavoriteStatus()
                },
              ),
            ],
          ),
          SizedBox(height: 12),
          // Hàng chứa rating và ngôn ngữ
          Row(
            children: [
              Icon(Icons.star, color: Colors.amber, size: 20),
              SizedBox(width: 4),
              Text(
                '${movie.rating}/5',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              SizedBox(width: 16),
              if (movie.language != null) ...[
                Icon(Icons.language, color: Colors.white70, size: 20),
                SizedBox(width: 4),
                Text(
                  movie.language!,
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ],
          ),
          SizedBox(height: 16),
          // Thể loại phim
          if (movie.genre != null)
            Text(
              'Thể loại: ${movie.genre}',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          SizedBox(height: 24),
          // Mô tả phim (không còn trường description)
          Text(
            'Thời lượng: 	${movie.duration ?? 'Không rõ'}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 15,
              height: 1.5,
            ),
          ),
          SizedBox(height: 32),
          // Nút xem phim/trailer
          Center(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                // TODO: Xử lý sự kiện xem trailer, ví dụ mở một URL video.
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Chức năng xem phim chưa được cài đặt!'),
                  ),
                );
              },
              icon: Icon(Icons.play_arrow, color: Colors.white),
              label: Text(
                'Xem Ngay',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper chuyển Movie thành chuỗi debug
  String movieToDebugString(Movie movie) {
    return '{id: 	${movie.id}, name: 	${movie.name ?? "null"}, duration: 	${movie.duration}, language: 	${movie.language}, rating: 	${movie.rating}, genre: 	${movie.genre}, imageUrl: 	${movie.imageUrl}}';
  }
}
