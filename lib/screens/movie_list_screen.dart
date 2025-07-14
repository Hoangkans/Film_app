import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/api_service.dart';
import 'movie_detail_screen.dart';
import 'add_movie_screen.dart';

class MovieListScreen extends StatefulWidget {
  final String token;
  final VoidCallback? onLogout;
  const MovieListScreen({required this.token, this.onLogout, super.key});

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  late Future<List<Movie>> movies;

  @override
  void initState() {
    super.initState();
    movies = ApiService.fetchMovies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Danh sách phim'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: widget.onLogout,
            tooltip: 'Đăng xuất',
          ),
        ],
      ),
      body: FutureBuilder<List<Movie>>(
        future: movies,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text('Lỗi: {snapshot.error}'));
          final movies = snapshot.data!;
          return ListView.builder(
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return ListTile(
                title: Text(movie.name),
                subtitle: Text('Ngôn ngữ: {movie.language ?? "Không rõ"} | Đánh giá: {movie.rating}'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MovieDetailScreen(id: movie.id, token: widget.token),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddMovieScreen(token: widget.token),
            ),
          );
        },
        tooltip: 'Thêm phim',
        child: Icon(Icons.add),
      ),
    );
  }
} 