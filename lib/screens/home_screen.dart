import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'add_movie_screen.dart';
import 'edit_movie_screen.dart';

/// Màn hình chính của ứng dụng, hiển thị các danh sách phim.
///
/// Bao gồm một carousel banner cho các phim nổi bật và các hàng (rows)
/// cho những danh mục phim khác nhau.
/// Hỗ trợ chức năng kéo để làm mới (pull-to-refresh).
/// Cung cấp các chức năng quản trị (thêm/sửa/xóa phim) nếu người dùng là admin.
class HomeScreen extends StatefulWidget {
  /// Callback được gọi khi người dùng nhấn nút đăng xuất.
  final VoidCallback onLogout;

  /// Callback được gọi khi người dùng nhấn vào một bộ phim.
  final void Function(int movieId)? onMovieTap;

  /// Cờ cho biết người dùng đã đăng nhập hay chưa.
  final bool isLoggedIn;

  /// Cờ cho biết người dùng có phải là admin hay không.
  final bool isAdmin;

  /// Token xác thực của người dùng.
  final String? token;

  final String? userEmail;

  const HomeScreen({
    required this.onLogout,
    this.onMovieTap,
    this.isLoggedIn = false,
    this.isAdmin = false,
    this.token,
    this.userEmail,
    super.key,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Danh sách các bộ phim được hiển thị trên màn hình.
  List<Movie> movies = [];

  /// Cờ cho biết có đang tải dữ liệu từ API hay không.
  bool isLoading = true;

  /// Chuỗi chứa thông báo lỗi nếu có.
  String? error;

  Set<int> favoriteIds = {}; // Thêm state lưu id phim yêu thích

  @override
  void initState() {
    super.initState();
    // Bắt đầu tải danh sách phim khi widget được khởi tạo.
    _fetchMovies();
    _loadFavoriteIds();
  }

  /// Tải danh sách phim từ [ApiService].
  ///
  /// Cập nhật trạng thái [isLoading] và [error] tương ứng.
  Future<void> _fetchMovies() async {
    // Chỉ cập nhật state nếu widget vẫn còn trong cây widget.
    if (!mounted) return;
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final data = await ApiService.fetchMovies();
      if (!mounted) return;
      setState(() {
        movies = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _loadFavoriteIds() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteIdStrings = prefs.getStringList('favoriteMovies') ?? [];
    setState(() {
      favoriteIds = favoriteIdStrings.map(int.parse).toSet();
    });
  }

  Future<void> _toggleFavorite(int id) async {
    setState(() {
      if (favoriteIds.contains(id)) {
        favoriteIds.remove(id);
      } else {
        favoriteIds.add(id);
      }
    });
    final prefs = await SharedPreferences.getInstance();
    final favoriteIdStrings = favoriteIds.map((id) => id.toString()).toList();
    await prefs.setStringList('favoriteMovies', favoriteIdStrings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'hẹ hẹ hẹ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: widget.onLogout,
            tooltip: 'Đăng xuất',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchMovies,
        color: Colors.redAccent,
        backgroundColor: Colors.black,
        child: _buildBody(),
      ),
    );
  }

  /// Xây dựng phần thân (body) của Scaffold, xử lý các trạng thái
  /// loading, error, empty, và success.
  Widget _buildBody() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator(color: Colors.redAccent));
    }
    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 50),
            SizedBox(height: 10),
            Text('Lỗi: ' + error!, style: TextStyle(color: Colors.white)),
            SizedBox(height: 10),
            ElevatedButton(onPressed: _fetchMovies, child: Text('Thử lại')),
          ],
        ),
      );
    }
    if (movies.isEmpty) {
      return Center(
        child: Text('Không có phim nào', style: TextStyle(color: Colors.white)),
      );
    }
    return ListView(
      children: [
        _buildMovieRow('Tất cả phim', movies),
        SizedBox(height: 20),
        _buildMovieRow(
          'Phim nổi bật',
          movies.where((m) => m.rating >= 4).toList(),
        ),
        _buildMovieRow(
          'Phim tiếng Anh',
          movies.where((m) => m.language == 'tiếng anh').toList(),
        ),
        _buildMovieRow(
          'Phim tiếng Pháp',
          movies.where((m) => m.language == 'eng').toList(),
        ),
        SizedBox(height: 20),
        _buildAdminAddButton(),
      ],
    );
  }

  /// Xây dựng một carousel hiển thị các banner phim.
  ///
  /// [banners]: Danh sách các phim sẽ được hiển thị trong carousel.
  Widget _buildBannerCarousel(List<Movie> banners) {
    if (banners.isEmpty) return SizedBox.shrink();

    return SizedBox(
      height: 220,
      child: PageView.builder(
        itemCount: banners.length,
        // viewportFraction cho phép nhìn thấy một phần của banner tiếp theo.
        controller: PageController(viewportFraction: 0.9, initialPage: 0),
        itemBuilder: (context, index) {
          final movie = banners[index];
          return GestureDetector(
            onTap: () => widget.onMovieTap?.call(movie.id),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: movie.imageUrl != null && movie.imageUrl!.isNotEmpty
                      ? NetworkImage(movie.imageUrl!)
                      : AssetImage('assets/banner_placeholder.jpg')
                            as ImageProvider,
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              // Lớp phủ ở dưới cùng để hiển thị tên phim.
              alignment: Alignment.bottomLeft,
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Text(
                  movie.name ?? 'Không có tên', // Xử lý null ở đây
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Xây dựng một hàng các poster phim cuộn theo chiều ngang.
  ///
  /// [title]: Tiêu đề của hàng (ví dụ: "Phim nổi bật").
  /// [movies]: Danh sách các phim trong hàng này.
  Widget _buildMovieRow(String title, List<Movie> movies) {
    if (movies.isEmpty) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 230, // Tăng chiều cao để chứa thêm thông tin (rating)
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 12),
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return _buildMovieCard(
                movie,
              ); // Sử dụng một hàm riêng để build card
            },
          ),
        ),
      ],
    );
  }

  /// Xây dựng card cho một bộ phim trong hàng cuộn ngang.
  ///
  /// [movie]: Đối tượng phim để hiển thị.
  Widget _buildMovieCard(Movie movie) {
    final isFavorite = favoriteIds.contains(movie.id);
    return GestureDetector(
      onTap: () async {
        widget.onMovieTap?.call(movie.id);
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Card(
                elevation: 4,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      movie.imageUrl ?? '',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, e, s) =>
                          Center(child: Icon(Icons.movie, color: Colors.grey)),
                      loadingBuilder: (context, child, progress) =>
                          progress == null
                          ? child
                          : Center(child: CircularProgressIndicator()),
                    ),
                    // Nút favorite
                    Positioned(
                      top: 4,
                      right: 4,
                      child: IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: Colors.redAccent,
                        ),
                        onPressed: () => _toggleFavorite(movie.id),
                      ),
                    ),
                    // Nút edit cho admin
                    if (widget.isAdmin)
                      Positioned(
                        top: 4,
                        left: 4,
                        child: IconButton(
                          icon: Icon(Icons.edit, color: Colors.blueAccent),
                          tooltip: 'Sửa phim',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditMovieScreen(
                                  id: movie.id,
                                  token: widget.token ?? '',
                                  name: movie.name ?? '',
                                  imageUrl: movie.imageUrl ?? '',
                                  isAdmin: widget.isAdmin,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 8),
            Text(
              movie.name ?? 'Không có tên',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber, size: 16),
                SizedBox(width: 4),
                Text(
                  '${movie.rating}',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Hàm helper để chuyển Movie thành chuỗi debug
  String movieToDebugString(Movie movie) {
    return '{id: ${movie.id}, name: ${movie.name ?? "null"}, duration: ${movie.duration}, language: ${movie.language}, rating: ${movie.rating}, genre: ${movie.genre}, imageUrl: ${movie.imageUrl}}';
  }

  // Thêm nút thêm phim cho admin ở cuối danh sách
  Widget _buildAdminAddButton() {
    if (!widget.isAdmin) return SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddMovieScreen(
                token: widget.token ?? '',
                isAdmin: widget.isAdmin,
              ),
            ),
          );
        },
        icon: Icon(Icons.add),
        label: Text('Thêm phim'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}
