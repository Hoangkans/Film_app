import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';

/// Lớp `ApiService` cung cấp các phương thức để tương tác với API của backend.
///
/// Bao gồm các chức năng như đăng nhập, đăng ký, lấy danh sách phim,
/// xem chi tiết, thêm, sửa, và xóa phim.
class ApiService {
  /// URL cơ sở của API.
  /// Mọi request API sẽ được xây dựng dựa trên URL này.
  static const String baseUrl = 'http://exceit20122-001-site1.qtempurl.com/api';

  /// Gửi yêu cầu đăng nhập đến server.
  ///
  /// [email]: Email của người dùng.
  /// [password]: Mật khẩu của người dùng.
  /// Trả về một `Map` chứa `token` và `email` nếu đăng nhập thành công.
  /// Trả về `null` nếu đăng nhập thất bại.
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

  /// Đăng ký một tài khoản mới.
  ///
  /// [email]: Email cho tài khoản mới.
  /// [password]: Mật khẩu cho tài khoản mới.
  /// Hiện tại, hàm này chỉ giả lập việc đăng ký thành công sau một khoảng thời gian chờ.
  /// Trả về `true` để biểu thị đăng ký thành công.
  static Future<bool> register(String email, String password) async {
    // Giả lập một cuộc gọi mạng
    await Future.delayed(Duration(milliseconds: 800));
    return true; // Luôn giả lập thành công
  }

  /// Lấy danh sách tất cả các bộ phim từ server.
  ///
  /// Trả về một danh sách các đối tượng [Movie].
  /// Ném ra một [Exception] nếu không thể tải dữ liệu.
  static Future<List<Movie>> fetchMovies() async {
    final url = Uri.parse('$baseUrl/movies/AllMovies');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      // Chuyển đổi mỗi phần tử trong danh sách JSON thành một đối tượng Movie
      return data.map((e) => Movie.fromJson(e)).toList();
    }
    throw Exception('Không thể tải danh sách phim: ${response.statusCode}');
  }

  /// Lấy thông tin chi tiết của một bộ phim dựa vào ID.
  ///
  /// [id]: ID của bộ phim cần lấy chi tiết.
  /// [token]: Token xác thực của người dùng.
  /// Trả về một đối tượng [Movie] chứa thông tin chi tiết.
  /// Ném ra một [Exception] nếu không thể tải dữ liệu.
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

  /// Thêm một bộ phim mới vào cơ sở dữ liệu.
  ///
  /// Yêu cầu quyền admin (thông qua `token`).
  /// [name]: Tên của phim mới.
  /// [imageUrl]: URL hình ảnh của phim mới.
  /// [token]: Token xác thực của admin.
  /// Trả về `true` nếu thêm thành công.
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
      // Dữ liệu được gửi dưới dạng form-urlencoded
      body: {'name': name, 'imageUrl': imageUrl},
    );
    // API có thể trả về 200 (OK) hoặc 201 (Created)
    return response.statusCode == 200 || response.statusCode == 201;
  }

  /// Cập nhật thông tin của một bộ phim đã có.
  ///
  /// Yêu cầu quyền admin (thông qua `token`).
  /// [id]: ID của phim cần sửa.
  /// [name]: Tên mới của phim.
  /// [imageUrl]: URL hình ảnh mới của phim.
  /// [token]: Token xác thực của admin.
  /// Trả về `true` nếu cập nhật thành công.
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

  /// Xóa một bộ phim khỏi cơ sở dữ liệu.
  ///
  /// Yêu cầu quyền admin (thông qua `token`).
  /// [id]: ID của phim cần xóa.
  /// [token]: Token xác thực của admin.
  /// Trả về `true` nếu xóa thành công.
  static Future<bool> deleteMovie({
    required int id,
    required String token,
  }) async {
    final url = Uri.parse('$baseUrl/movies/$id');
    final response = await http.delete(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    // API có thể trả về 200 (OK) hoặc 204 (No Content)
    return response.statusCode == 200 || response.statusCode == 204;
  }
}
