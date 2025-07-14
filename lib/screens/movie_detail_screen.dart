import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/api_service.dart';

class MovieDetailScreen extends StatefulWidget {
  final int id;
  final String? token;
  const MovieDetailScreen({required this.id, this.token, super.key});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  late Future<Movie> movieFuture;

  @override
  void initState() {
    super.initState();
    movieFuture = ApiService.fetchMovieDetail(widget.id, widget.token ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<Movie>(
        future: movieFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Lỗi: ${snapshot.error}',
                style: TextStyle(color: Colors.white),
              ),
            );
          }
          final movie = snapshot.data!;
          return Stack(
            children: [
              // Ảnh nền lớn
              movie.imageUrl != null && movie.imageUrl!.isNotEmpty
                  ? Image.network(
                      movie.imageUrl!,
                      width: double.infinity,
                      height: 350,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: double.infinity,
                      height: 350,
                      color: Colors.grey[800],
                      child: Icon(Icons.movie, color: Colors.white, size: 100),
                    ),
              // Overlay gradient
              Container(
                width: double.infinity,
                height: 350,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                      Colors.black.withOpacity(0.9),
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
              // Nút back
              Positioned(
                top: 40,
                left: 16,
                child: CircleAvatar(
                  backgroundColor: Colors.black54,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              // Nội dung phim
              Positioned(
                top: 260,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              movie.name,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.favorite_border,
                              color: Colors.redAccent,
                              size: 28,
                            ),
                            onPressed: () {}, // TODO: Thêm vào yêu thích
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 20),
                          SizedBox(width: 4),
                          Text(
                            '${movie.rating}/5',
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(width: 16),
                          if (movie.language != null)
                            Text(
                              movie.language!,
                              style: TextStyle(color: Colors.white70),
                            ),
                        ],
                      ),
                      SizedBox(height: 16),
                      if (movie.genre != null)
                        Text(
                          'Thể loại: ${movie.genre}',
                          style: TextStyle(color: Colors.white70),
                        ),
                      SizedBox(height: 16),
                      if (movie is Movie &&
                          (movie as dynamic).description != null)
                        Text(
                          (movie as dynamic).description ?? '',
                          style: TextStyle(color: Colors.white),
                        ),
                      SizedBox(height: 24),
                      Center(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            padding: EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: () {}, // TODO: Xem trailer hoặc play
                          icon: Icon(Icons.play_arrow, color: Colors.white),
                          label: Text(
                            'Xem ngay',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
