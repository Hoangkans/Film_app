/// Model đại diện cho một bộ phim, dùng để ánh xạ dữ liệu từ API
class Movie {
  /// ID phim
  final int id;

  /// Tên phim
  final String name;

  /// Ngôn ngữ phim (có thể null)
  final String? language;

  /// Đánh giá (rating) từ 1-5
  final int rating;

  /// Thể loại phim (có thể null)
  final String? genre;

  /// Đường dẫn ảnh poster phim (có thể null)
  final String? imageUrl;

  Movie({
    required this.id,
    required this.name,
    this.language,
    required this.rating,
    this.genre,
    this.imageUrl,
  });

  /// Tạo đối tượng Movie từ dữ liệu JSON trả về từ API
  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      name: json['name'],
      language: json['language'],
      rating: json['rating'],
      genre: json['genre'],
      imageUrl: json['imageUrl'],
    );
  }
}
