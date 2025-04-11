import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/admin_home.dart';
import 'screens/order_detail_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FastFood Online',
      // theme: ThemeData(
      //   primarySwatch: Colors.blue,
      // ),
      theme: ThemeData(
        fontFamily: 'NotoSans',
        textTheme: TextTheme(
          bodyLarge: TextStyle(fontSize: 16),
          bodyMedium: TextStyle(fontSize: 14),
          bodySmall: TextStyle(fontSize: 12),
        ),
      ),
      home: SplashScreen(),
      routes: {
        '/login': (context) => LoginScreen(),
        '/home': (context) => AdminDashboard(),
        '/notification': (context) => HomeScreen(),
        '/forgot-password': (context) => Scaffold(
              appBar: AppBar(title: Text('Quên mật khẩu')),
              body: Center(child: Text('Màn hình quên mật khẩu')),
            ),
        '/register': (context) => Scaffold(
              appBar: AppBar(title: Text('Đăng ký')),
              body: Center(child: Text('Màn hình đăng ký')),
            ),
        '/order-detail': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return OrderDetailScreen(orderId: args['orderId']);
        },
      },
    );
  }
}

// Màn hình khởi động để kiểm tra trạng thái đăng nhập
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    // Nếu token tồn tại, chuyển đến HomeScreen
    // Nếu không, chuyển đến LoginScreen
    if (token != null && token.isNotEmpty) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
