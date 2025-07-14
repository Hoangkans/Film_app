import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/movie_detail_screen.dart';
import 'screens/add_movie_screen.dart';
import 'screens/edit_movie_screen.dart';

/// Ứng dụng chính với BottomNavigationBar kiểu Netflix
void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;
  String? token;
  String? email;
  bool showLogin = false;
  bool showRegister = false;
  int? pendingMovieId; // Lưu id phim nếu cần chuyển hướng sau đăng nhập

  bool get isAdmin =>
      (email != null && email!.toLowerCase().contains('admin')) ||
      (token != null && token!.toLowerCase().contains('admin'));

  /// Xử lý chuyển tab
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  /// Xử lý đăng nhập thành công
  void _onLogin(String t, String e) {
    setState(() {
      token = t;
      email = e;
      showLogin = false;
      showRegister = false;
    });
    // Nếu có pendingMovieId, chuyển sang chi tiết phim đó
    if (pendingMovieId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                MovieDetailScreen(id: pendingMovieId!, token: token),
          ),
        );
        pendingMovieId = null;
      });
    }
  }

  /// Xử lý đăng xuất
  void _onLogout() {
    setState(() {
      token = null;
      email = null;
    });
  }

  /// Xử lý chuyển sang đăng ký
  void _onShowRegister() {
    setState(() {
      showRegister = true;
      showLogin = false;
    });
  }

  /// Xử lý chuyển sang đăng nhập
  void _onShowLogin() {
    setState(() {
      showLogin = true;
      showRegister = false;
    });
  }

  /// Xử lý đăng ký thành công (tự động đăng nhập)
  void _onRegisterSuccess(String email) {
    setState(() {
      showRegister = false;
      showLogin = true;
    });
    // Có thể tự động điền email vào login nếu muốn
  }

  /// Xử lý khi người dùng muốn xem chi tiết phim (nếu chưa đăng nhập thì chuyển sang login)
  void _onMovieTap(int movieId) {
    if (token == null) {
      setState(() {
        showLogin = true;
        pendingMovieId = movieId;
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MovieDetailScreen(id: movieId, token: token),
        ),
      );
    }
  }

  void _onExitToHome() {
    setState(() {
      showLogin = false;
      showRegister = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Nếu đang ở trang đăng nhập
    if (showLogin) {
      return MaterialApp(
        title: 'Cinema Hub',
        theme: ThemeData.dark(),
        home: LoginScreen(
          onLogin: _onLogin,
          onRegister: _onShowRegister,
          onExit: _onExitToHome,
        ),
      );
    }
    // Nếu đang ở trang đăng ký
    if (showRegister) {
      return MaterialApp(
        title: 'Cinema Hub',
        theme: ThemeData.dark(),
        home: RegisterScreen(
          onRegisterSuccess: _onRegisterSuccess,
          onExit: _onExitToHome,
        ),
      );
    }
    // Ứng dụng chính với bottom nav
    return MaterialApp(
      title: 'Cinema Hub',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Colors.redAccent,
        colorScheme: ColorScheme.dark(
          primary: Colors.redAccent,
          secondary: Colors.white,
        ),
      ),
      home: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            // Truyền callback _onMovieTap cho HomeScreen để xử lý khi bấm vào phim
            HomeScreen(
              onLogout: _onLogout,
              onMovieTap: _onMovieTap,
              isLoggedIn: token != null,
              isAdmin: isAdmin,
              token: token,
            ),
            SearchScreen(),
            FavoritesScreen(),
            ProfileScreen(onLogout: _onLogout),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.black,
          selectedItemColor: Colors.redAccent,
          unselectedItemColor: Colors.white70,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'Favorites',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
      onGenerateRoute: (settings) {
        if (settings.name == '/add_movie') {
          final token = settings.arguments as String?;
          return AddMovieScreen.routeWithToken(token);
        }
        if (settings.name == '/edit_movie') {
          final args = settings.arguments as Map;
          return EditMovieScreen.routeWithArgs(args);
        }
        return null;
      },
    );
  }
}
