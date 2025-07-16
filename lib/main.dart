import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import for saving login state
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/login_screen.dart';
import 'screens/movie_detail_screen.dart';
import 'screens/add_movie_screen.dart';
import 'screens/edit_movie_screen.dart';

/// Điểm khởi đầu của ứng dụng.
void main() {
  // Đảm bảo Flutter binding đã được khởi tạo trước khi chạy app.
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

/// Widget gốc của ứng dụng, là một [StatefulWidget] để quản lý trạng thái
/// toàn cục như thông tin đăng nhập và điều hướng chính.
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  // TRẠNG THÁI TOÀN CỤC CỦA ỨNG DỤNG
  // LƯU Ý: Đây là một cách quản lý state đơn giản. Với ứng dụng lớn hơn,
  // bạn nên cân nhắc sử dụng các giải pháp như Provider, Riverpod, hoặc BLoC.

  /// Index của tab đang được chọn trong BottomNavigationBar.
  int _selectedIndex = 0;

  /// Token xác thực của người dùng sau khi đăng nhập. `null` nếu chưa đăng nhập.
  String? _token;

  /// Email của người dùng sau khi đăng nhập.
  String? _email;

  /// Cờ quyết định hiển thị màn hình đăng nhập thay vì màn hình chính.
  bool _showLogin = true; // Bắt đầu với màn hình đăng nhập
  /// Cờ quyết định hiển thị màn hình đăng ký.
  bool _showRegister = false;

  /// Lưu ID phim người dùng muốn xem trước khi bị chuyển hướng tới trang đăng nhập.
  int? _pendingMovieId;

  @override
  void initState() {
    super.initState();
    // Thử tải thông tin đăng nhập đã lưu từ lần trước.
    _loadLoginInfo();
  }

  /// Kiểm tra xem người dùng có phải là admin hay không.
  /// CẢNH BÁO: Logic này chỉ dành cho mục đích demo và KHÔNG AN TOÀN.
  /// Trong thực tế, vai trò của người dùng phải được xác định bởi server.
  bool get _isAdmin => _email == 'mei@email.com';

  //------------------------------------------------------------------
  // CÁC HÀM XỬ LÝ TRẠNG THÁI VÀ ĐIỀU HƯỚNG
  //------------------------------------------------------------------

  /// Tải thông tin token và email từ SharedPreferences.
  Future<void> _loadLoginInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final email = prefs.getString('email');
    if (token != null && email != null) {
      setState(() {
        _token = token;
        _email = email;
        _showLogin = false; // Nếu có thông tin, vào thẳng app.
      });
    }
  }

  /// Lưu thông tin đăng nhập vào SharedPreferences.
  Future<void> _saveLoginInfo(String token, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('email', email);
  }

  /// Xóa thông tin đăng nhập khỏi SharedPreferences.
  Future<void> _clearLoginInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('email');
  }

  /// Xử lý khi người dùng chọn một tab trên BottomNavigationBar.
  void _onItemTapped(int index) {
    // Nếu chưa đăng nhập mà chọn tab "Yêu thích" hoặc "Tài khoản",
    // thì chuyển hướng đến trang đăng nhập.
    if (_token == null && (index == 2 || index == 3)) {
      setState(() {
        _showLogin = true;
      });
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  /// Xử lý sau khi đăng nhập thành công.
  void _onLogin(String token, String email) {
    setState(() {
      _token = token;
      _email = email;
      _showLogin = false;
      _showRegister = false;
      _selectedIndex = 0; // Quay về trang chủ
    });
    _saveLoginInfo(token, email); // Lưu lại trạng thái đăng nhập.

    // Nếu trước đó người dùng đã bấm vào một phim, giờ sẽ chuyển hướng họ đến đó.
    if (_pendingMovieId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Cần GlobalKey<NavigatorState> để push từ đây.
        // Đây là một cách đơn giản hơn, nhưng không lý tưởng.
        // Một cấu trúc Navigator lồng nhau sẽ tốt hơn.
        print("Redirecting to movie: $_pendingMovieId");
        // For a real implementation, you would use a Navigator key to push the route.
        // Example: navigatorKey.currentState?.push(...);
        _pendingMovieId = null; // Xóa id sau khi xử lý
      });
    }
  }

  /// Xử lý khi người dùng đăng xuất.
  void _onLogout() {
    setState(() {
      _token = null;
      _email = null;
      _showLogin = true; // Hiện lại màn hình đăng nhập.
      _selectedIndex = 0;
    });
    _clearLoginInfo(); // Xóa thông tin đã lưu.
  }

  /// Hiển thị màn hình đăng ký.
  void _onShowRegister() {
    setState(() {
      _showRegister = true;
      _showLogin = false;
    });
  }

  /// Hiển thị màn hình đăng nhập (từ màn hình đăng ký).
  void _onShowLogin() {
    setState(() {
      _showLogin = true;
      _showRegister = false;
    });
  }

  /// Xử lý sau khi đăng ký thành công.
  void _onRegisterSuccess(String email) {
    // Tự động chuyển người dùng về màn hình đăng nhập.
    setState(() {
      _showRegister = false;
      _showLogin = true;
    });
    // Có thể tự động điền email vào form đăng nhập nếu muốn.
  }

  /// Xử lý khi người dùng nhấn vào một phim ở trang chủ.
  void _onMovieTap(int movieId) {
    if (_token == null) {
      setState(() {
        _showLogin = true;
        _pendingMovieId = movieId;
      });
    } else {
      _navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) =>
              MovieDetailScreen(id: movieId, token: _token, isAdmin: _isAdmin),
        ),
      );
    }
  }

  /// Xử lý khi người dùng thoát khỏi màn hình login/register mà không đăng nhập/đăng ký.
  void _onExitAuth() {
    setState(() {
      _showLogin = false;
      _showRegister = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // LƯU Ý: Việc trả về các MaterialApp khác nhau như thế này sẽ reset toàn bộ
    // cây widget, làm mất trạng thái của các màn hình. Một cấu trúc điều hướng
    // tốt hơn (sử dụng Navigator 2.0 hoặc các package như go_router) sẽ
    // quản lý các trang này mà không cần build lại MaterialApp.

    // Hiển thị màn hình đăng nhập nếu cần.
    if (_showLogin) {
      return MaterialApp(
        title: 'Cinema Hub Auth',
        theme: _buildTheme(),
        home: LoginScreen(onLogin: _onLogin, onExit: _onExitAuth),
      );
    }

    // Ứng dụng chính sau khi đã đăng nhập (hoặc ở chế độ khách).
    return MaterialApp(
      title: 'Cinema Hub',
      theme: _buildTheme(),
      navigatorKey: _navigatorKey,
      onGenerateRoute: _onGenerateRoute,
      home: Scaffold(
        body: IndexedStack(index: _selectedIndex, children: _buildScreens()),
        bottomNavigationBar: _buildBottomNavBar(),
      ),
    );
  }

  /// Xây dựng theme cho ứng dụng.
  ThemeData _buildTheme() {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: Colors.black,
      primaryColor: Colors.redAccent,
      colorScheme: ColorScheme.dark(
        primary: Colors.redAccent,
        secondary: Colors.white,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.redAccent,
        unselectedItemColor: Colors.grey[600],
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  /// Xây dựng danh sách các màn hình cho IndexedStack.
  List<Widget> _buildScreens() {
    return [
      HomeScreen(
        onLogout: _onLogout,
        onMovieTap: _onMovieTap,
        isLoggedIn: _token != null,
        isAdmin: _isAdmin,
        token: _token,
        userEmail: _email,
      ),
      SearchScreen(token: _token, isAdmin: _isAdmin),
      FavoritesScreen(token: _token, isAdmin: _isAdmin),
      ProfileScreen(onLogout: _onLogout, userEmail: _email),
    ];
  }

  /// Xây dựng BottomNavigationBar.
  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Tìm kiếm'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Yêu thích'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Tài khoản'),
      ],
    );
  }

  /// Xử lý việc tạo route khi Navigator.pushNamed được gọi.
  Route? _onGenerateRoute(RouteSettings settings) {
    // Chuyển hướng đến màn hình Thêm phim
    if (settings.name == '/add_movie') {
      final token = settings.arguments as String?;
      return MaterialPageRoute(
        builder: (_) => AddMovieScreen(token: token ?? '', isAdmin: _isAdmin),
      );
    }
    // Chuyển hướng đến màn hình Sửa phim
    if (settings.name == '/edit_movie') {
      // Đảm bảo arguments là một Map
      if (settings.arguments is Map) {
        final args = settings.arguments as Map;
        return MaterialPageRoute(
          builder: (_) => EditMovieScreen(
            id: args['id'],
            token: args['token'] ?? '',
            name: args['name'] ?? '',
            imageUrl: args['imageUrl'] ?? '',
            isAdmin: _isAdmin,
          ),
        );
      }
    }
    // Trả về null nếu không có route nào khớp
    return null;
  }
}
