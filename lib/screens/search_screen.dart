import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/api_service.dart';
import 'movie_detail_screen.dart';
import 'dart:async';

/// Màn hình tìm kiếm phim kiểu Netflix
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  /// Danh sách tất cả phim lấy từ API
  List<Movie> allMovies = [];

  /// Danh sách phim sau khi lọc theo từ khóa tìm kiếm
  List<Movie> filteredMovies = [];

  /// Trạng thái loading khi lấy dữ liệu
  bool isLoading = true;

  /// Từ khóa tìm kiếm hiện tại
  String query = '';

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _fetchMovies();
  }

  /// Lấy danh sách phim từ API
  Future<void> _fetchMovies() async {
    setState(() {
      isLoading = true;
    });
    final movies = await ApiService.fetchMovies();
    setState(() {
      allMovies = movies;
      filteredMovies = movies;
      isLoading = false;
    });
  }

  /// Lọc phim theo từ khóa tìm kiếm
  void _onSearch(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        query = value;
        filteredMovies = allMovies
            .where((m) => m.name.toLowerCase().contains(value.toLowerCase()))
            .toList();
      });
    });
  }

  @override
  void dispose() {
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
        title: TextField(
          style: TextStyle(color: Colors.white, fontSize: 18),
          decoration: InputDecoration(
            hintText: 'Tìm kiếm phim...',
            hintStyle: TextStyle(color: Colors.white54),
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search, color: Colors.white54),
            filled: true,
            fillColor: Colors.white10,
            contentPadding: EdgeInsets.symmetric(vertical: 8),
          ),
          onChanged: _onSearch,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchMovies,
        color: Colors.redAccent,
        child: isLoading
            ? GridView.builder(
                padding: EdgeInsets.all(8),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.6,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: 9,
                itemBuilder: (context, index) => _buildShimmerCard(),
              )
            : filteredMovies.isEmpty
            ? Center(
                child: Text(
                  'Không tìm thấy phim nào',
                  style: TextStyle(color: Colors.white),
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.6,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: filteredMovies.length,
                  itemBuilder: (context, index) {
                    final movie = filteredMovies[index];
                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              MovieDetailScreen(id: movie.id, token: ''),
                        ),
                      ),
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
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
                            ),
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
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
                                        Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 15,
                                        ),
                                        SizedBox(width: 2),
                                        Text(
                                          '${movie.rating}',
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 13,
                                          ),
                                        ),
                                        if (movie.language != null) ...[
                                          SizedBox(width: 8),
                                          Text(
                                            movie.language!,
                                            style: TextStyle(
                                              color: Colors.white54,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
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

  Widget _buildShimmerCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(14),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  colors: [Colors.grey[800]!, Colors.grey[700]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(14),
                  bottomRight: Radius.circular(14),
                ),
              ),
              child: Container(height: 16, color: Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }
}
