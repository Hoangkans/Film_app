import 'dart:async';
import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/api_service.dart';
import 'movie_detail_screen.dart';

/// Màn hình tìm kiếm phim với giao diện và tính năng tương tự Netflix.
///
/// Người dùng có thể nhập từ khóa để tìm kiếm. Kết quả sẽ được cập nhật
/// sau một khoảng trễ ngắn (debounce) để tối ưu hiệu suất.
/// Màn hình hiển thị hiệu ứng shimmer trong khi tải dữ liệu.
class SearchScreen extends StatefulWidget {
  /// Token xác thực của người dùng (nếu có).
  final String? token;
  final bool isAdmin;

  const SearchScreen({this.token, this.isAdmin = false, super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  /// Danh sách tất cả các bộ phim được lấy từ API.
  /// LƯU Ý: Việc tìm kiếm phía client chỉ phù hợp với lượng dữ liệu nhỏ.
  /// Với dữ liệu lớn, nên sử dụng API tìm kiếm của backend.
  List<Movie> _allMovies = [];

  /// Danh sách phim đã được lọc dựa trên từ khóa tìm kiếm.
  List<Movie> _filteredMovies = [];

  /// Cờ báo hiệu trạng thái tải dữ liệu ban đầu.
  bool _isLoading = true;

  /// Controller cho trường tìm kiếm.
  final _searchController = TextEditingController();

  /// Timer dùng cho kỹ thuật "debounce" để tránh việc tìm kiếm liên tục.
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _fetchMovies();
    // Lắng nghe sự thay đổi của controller để bật/tắt nút clear
    _searchController.addListener(() => setState(() {}));
  }

  /// Lấy danh sách tất cả các phim từ API.
  Future<void> _fetchMovies() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final movies = await ApiService.fetchMovies();
      if (!mounted) return;
      setState(() {
        _allMovies = movies;
        // Nếu có query cũ thì lọc luôn, không thì hiển thị tất cả
        if (_searchController.text.isNotEmpty) {
          _onSearchChanged(_searchController.text);
        } else {
          _filteredMovies = movies;
        }
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        // Có thể hiển thị SnackBar hoặc một widget lỗi ở đây.
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi tải phim: $e')));
      });
    }
  }

  /// Xử lý sự kiện khi người dùng thay đổi nội dung trong ô tìm kiếm.
  ///
  /// Sử dụng kỹ thuật debounce: chỉ thực hiện tìm kiếm sau khi người dùng
  /// đã ngừng gõ trong một khoảng thời gian ngắn (300ms).
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() {
        _filteredMovies = _allMovies
            .where(
              (movie) => (movie.name ?? '').toLowerCase().contains(
                query.toLowerCase(),
              ),
            )
            .toList();
      });
    });
  }

  @override
  void dispose() {
    // Hủy bỏ các controller và timer để tránh rò rỉ bộ nhớ.
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Thanh tìm kiếm được đặt ngay trên AppBar.
        title: TextField(
          controller: _searchController,
          style: TextStyle(color: Colors.white, fontSize: 18),
          autofocus: true, // Tự động focus vào ô tìm kiếm khi mở màn hình.
          decoration: InputDecoration(
            hintText: 'Tìm kiếm theo tên phim...',
            hintStyle: TextStyle(color: Colors.white54),
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search, color: Colors.white54),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, color: Colors.white54),
                    onPressed: () {
                      _searchController.clear();
                      _onSearchChanged('');
                    },
                  )
                : null,
          ),
          onChanged: _onSearchChanged,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchMovies,
        color: Colors.redAccent,
        backgroundColor: Colors.black,
        child: _buildBody(),
      ),
    );
  }

  /// Xây dựng phần thân của màn hình, xử lý các trạng thái khác nhau.
  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingGrid(); // Hiển thị hiệu ứng shimmer khi tải.
    }

    if (_allMovies.isNotEmpty && _filteredMovies.isEmpty) {
      return _buildEmptyState(
        'Không tìm thấy phim nào cho "${_searchController.text}"',
      );
    }

    if (_allMovies.isEmpty && !_isLoading) {
      return _buildEmptyState('Không có phim nào để tìm kiếm.');
    }

    return _buildResultsGrid(); // Hiển thị kết quả tìm kiếm.
  }

  /// Xây dựng lưới hiển thị kết quả tìm kiếm.
  Widget _buildResultsGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.65, // Tăng chiều cao một chút
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _filteredMovies.length,
      itemBuilder: (context, index) {
        final movie = _filteredMovies[index];
        return _buildMovieCard(movie);
      },
    );
  }

  /// Xây dựng card cho một bộ phim.
  Widget _buildMovieCard(Movie movie) {
    return GestureDetector(
      onTap: () {
        final String? token = widget.token;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MovieDetailScreen(
              id: movie.id,
              token: token,
              isAdmin: widget.isAdmin,
            ),
          ),
        );
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 4,
        color: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Image.network(
                movie.imageUrl ?? '',
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, e, s) =>
                    Center(child: Icon(Icons.movie, color: Colors.grey)),
                loadingBuilder: (context, child, progress) => progress == null
                    ? child
                    : Center(child: CircularProgressIndicator()),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.name ?? 'Không có tên',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 14),
                      SizedBox(width: 2),
                      Text(
                        '${movie.rating}',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      SizedBox(width: 8),
                      if (movie.language != null)
                        Row(
                          children: [
                            Icon(
                              Icons.language,
                              color: Colors.white54,
                              size: 13,
                            ),
                            SizedBox(width: 2),
                            Text(
                              movie.language!,
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  if (movie.duration != null)
                    Text(
                      'Thời lượng: ${movie.duration}',
                      style: TextStyle(color: Colors.white54, fontSize: 11),
                    ),
                  if (movie.genre != null)
                    Text(
                      'Thể loại: ${movie.genre}',
                      style: TextStyle(color: Colors.white54, fontSize: 11),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Xây dựng lưới các card shimmer để làm hiệu ứng tải.
  Widget _buildLoadingGrid() {
    return GridView.builder(
      padding: EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.65,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 12, // Hiển thị 12 card shimmer
      itemBuilder: (context, index) => _buildShimmerCard(),
    );
  }

  /// Widget hiển thị trạng thái không có kết quả hoặc không có dữ liệu.
  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, color: Colors.white54, size: 80),
          SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 18),
          ),
        ],
      ),
    );
  }

  /// Widget xây dựng một card shimmer đơn.
  Widget _buildShimmerCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
