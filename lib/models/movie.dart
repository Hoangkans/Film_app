/// Model đại diện cho một bộ phim, dùng để ánh xạ dữ liệu từ API.
class Movie {
  /// ID duy nhất của phim.
  final int id;

  /// Tên của bộ phim.
  final String? name; // Cho phép null

  /// Thời lượng phim (có thể null).
  final String? duration;

  /// Ngôn ngữ gốc của phim (có thể không có).
  final String? language;

  /// Điểm đánh giá của phim (thường từ 1 đến 10 hoặc 1 đến 5).
  final int rating;

  /// Thể loại chính của phim (ví dụ: Hành động, Hài, Kinh dị).
  final String? genre;

  /// URL đến ảnh bìa (poster) của phim.
  final String? imageUrl;

  /// Hàm khởi tạo một đối tượng [Movie].
  ///
  /// Tất cả các tham số được yêu cầu ngoại trừ [language], [genre], [imageUrl], và [description].
  Movie({
    required this.id,
    this.name, // Cho phép null
    this.duration,
    this.language,
    required this.rating,
    this.genre,
    this.imageUrl,
  });

  /// Hàm factory để tạo một đối tượng [Movie] từ một map JSON.
  ///
  /// Được sử dụng để phân tích dữ liệu nhận được từ API.
  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      name: json['name'], // Không cần `?? ''` vì `name` đã là `String?`
      duration: json['duration']?.toString(),
      language: json['language'],
      rating: json['rating'] ?? 0,
      genre: json['genre'],
      imageUrl: json['imageUrl'],
    );
  }
}
