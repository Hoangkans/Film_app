import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';

/// Lớp này chứa các hàm gọi API backend (đăng nhập, lấy phim, thêm/sửa/xóa phim)
class ApiService {
  // Đổi sang http thay vì https để thử gọi API
  static const String baseUrl = 'http://exceit20122-001-site1.qtempurl.com/api';

  /// Đăng nhập, trả về access_token và email nếu thành công
  static Future<Map<String, String>?> login(
    String email,
    String password,
  ) async {
    final url = Uri.parse('$baseUrl/users/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'Password': password}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {'token': data['access_token'], 'email': email};
    }
    return null;
  }

  /// Đăng ký tài khoản mới (nếu API có, nếu không thì giả lập thành công)
  static Future<bool> register(String email, String password) async {
    await Future.delayed(Duration(milliseconds: 800));
    return true; // Giả lập thành công
  }

  /// Luôn trả về danh sách phim mẫu (không gọi API thật)
  static Future<List<Movie>> fetchMovies() async {
    final url = Uri.parse('$baseUrl/movies/AllMovies');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Movie.fromJson(e)).toList();
    }
    throw Exception('Failed to load movies: ${response.statusCode}');
  }

  /// Lấy chi tiết một phim theo id (cần token)
  static Future<Movie> fetchMovieDetail(int id, String token) async {
    final url = Uri.parse('$baseUrl/movies/MovieDetail/$id');
    final response = await http.get(
      url,
      headers: token.isNotEmpty ? {'Authorization': 'Bearer $token'} : {},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Movie.fromJson(data);
    }
    throw Exception('Không lấy được chi tiết phim: ${response.statusCode}');
  }

  /// Thêm phim mới (chỉ cho admin)
  static Future<bool> addMovie({
    required String name,
    required String imageUrl,
    required String token,
  }) async {
    final url = Uri.parse('$baseUrl/movies/');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {'name': name, 'imageUrl': imageUrl},
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  /// Sửa thông tin phim (chỉ cho admin)
  static Future<bool> editMovie({
    required int id,
    required String name,
    required String imageUrl,
    required String token,
  }) async {
    final url = Uri.parse('$baseUrl/movies/$id');
    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {'name': name, 'imageUrl': imageUrl},
    );
    return response.statusCode == 200;
  }

  /// Xóa phim (nếu API hỗ trợ)
  static Future<bool> deleteMovie({
    required int id,
    required String token,
  }) async {
    final url = Uri.parse('$baseUrl/movies/$id');
    final response = await http.delete(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    return response.statusCode == 200 || response.statusCode == 204;
  }
}
