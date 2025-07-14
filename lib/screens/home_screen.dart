import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onLogout;
  final void Function(int movieId)? onMovieTap;
  final bool isLoggedIn;
  final bool isAdmin;
  final String? token;
  const HomeScreen({
    required this.onLogout,
    this.onMovieTap,
    this.isLoggedIn = false,
    this.isAdmin = false,
    this.token,
    super.key,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Movie> movies = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchMovies();
  }

  Future<void> _fetchMovies() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final data = await ApiService.fetchMovies();
      setState(() {
        movies = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Cinema Hub',
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
        child: isLoading
            ? ListView(
                children: [
                  SizedBox(height: 120),
                  Center(child: CircularProgressIndicator()),
                ],
              )
            : error != null
            ? ListView(
                children: [
                  SizedBox(height: 120),
                  Center(
                    child: Text(
                      'Lỗi: ' + error!,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              )
            : movies.isEmpty
            ? ListView(
                children: [
                  SizedBox(height: 120),
                  Center(
                    child: Text(
                      'Không có phim',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              )
            : ListView(
                children: [
                  _buildBannerCarousel(movies.take(3).toList()),
                  SizedBox(height: 20),
                  _buildMovieRow(
                    'Phim nổi bật',
                    movies.where((m) => m.rating >= 4).toList(),
                  ),
                  _buildMovieRow(
                    'Phim tiếng Anh',
                    movies.where((m) => m.language == 'English').toList(),
                  ),
                  _buildMovieRow(
                    'Phim tiếng Pháp',
                    movies.where((m) => m.language == 'France').toList(),
                  ),
                ],
              ),
      ),
      floatingActionButton: widget.isAdmin
          ? FloatingActionButton(
              backgroundColor: Colors.redAccent,
              onPressed: () async {
                // Mở màn thêm phim
                final result = await Navigator.pushNamed(
                  context,
                  '/add_movie',
                  arguments: widget.token,
                );
                if (result == true) _fetchMovies();
              },
              child: Icon(Icons.add),
              tooltip: 'Thêm phim',
            )
          : null,
    );
  }

  /// Banner lớn dạng carousel với animation
  Widget _buildBannerCarousel(List<Movie> banners) {
    return SizedBox(
      height: 220,
      child: PageView.builder(
        itemCount: banners.length,
        controller: PageController(viewportFraction: 0.9),
        itemBuilder: (context, index) {
          final movie = banners[index];
          return AnimatedContainer(
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            child: GestureDetector(
              onTap: () {
                if (widget.onMovieTap != null) widget.onMovieTap!(movie.id);
              },
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
                alignment: Alignment.bottomLeft,
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Text(
                    movie.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Một hàng phim cuộn ngang với animation
  Widget _buildMovieRow(String title, List<Movie> movies) {
    if (movies.isEmpty) return SizedBox();
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
          height: 170,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 12),
            itemCount: movies.length,
            separatorBuilder: (_, __) => SizedBox(width: 12),
            itemBuilder: (context, index) {
              final movie = movies[index];
              return AnimatedContainer(
                duration: Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                child: GestureDetector(
                  onTap: () async {
                    if (widget.isAdmin) {
                      // Hiện dialog chọn Sửa/Xóa
                      final action = await showDialog<String>(
                        context: context,
                        builder: (context) => SimpleDialog(
                          title: Text('Quản lý phim'),
                          children: [
                            SimpleDialogOption(
                              onPressed: () => Navigator.pop(context, 'edit'),
                              child: Text('Sửa phim'),
                            ),
                            SimpleDialogOption(
                              onPressed: () => Navigator.pop(context, 'delete'),
                              child: Text('Xóa phim'),
                            ),
                            SimpleDialogOption(
                              onPressed: () => Navigator.pop(context),
                              child: Text('Đóng'),
                            ),
                          ],
                        ),
                      );
                      if (action == 'edit') {
                        final result = await Navigator.pushNamed(
                          context,
                          '/edit_movie',
                          arguments: {
                            'id': movie.id,
                            'name': movie.name,
                            'imageUrl': movie.imageUrl ?? '',
                            'token': widget.token,
                          },
                        );
                        if (result == true) _fetchMovies();
                      } else if (action == 'delete') {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Xác nhận xóa'),
                            content: Text('Bạn có chắc muốn xóa phim này?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text('Hủy'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: Text(
                                  'Xóa',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          final ok = await ApiService.deleteMovie(
                            id: movie.id,
                            token: widget.token ?? '',
                          );
                          if (ok) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Đã xóa phim!')),
                            );
                            _fetchMovies();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Xóa phim thất bại!')),
                            );
                          }
                        }
                      }
                    } else {
                      if (widget.onMovieTap != null)
                        widget.onMovieTap!(movie.id);
                    }
                  },
                  child: Container(
                    width: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      image: DecorationImage(
                        image:
                            movie.imageUrl != null && movie.imageUrl!.isNotEmpty
                            ? NetworkImage(movie.imageUrl!)
                            : AssetImage('assets/movie_placeholder.jpg')
                                  as ImageProvider,
                        fit: BoxFit.cover,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    alignment: Alignment.bottomLeft,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(14),
                          bottomRight: Radius.circular(14),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            movie.name,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.amber, size: 15),
                              SizedBox(width: 2),
                              Text(
                                '${movie.rating}',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
