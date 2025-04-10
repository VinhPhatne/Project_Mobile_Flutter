import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _phonenumber = '';
  String _password = '';
  String _phonenumberError = '';
  String _passwordError = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _resetForm();
  }

  void _resetForm() {
    setState(() {
      _phonenumber = '';
      _password = '';
      _phonenumberError = '';
      _passwordError = '';
    });
  }

  bool _validateForm() {
    final phoneRegex = RegExp(r'^[0-9]{10}$');
    String phonenumberError = '';
    String passwordError = '';

    if (_phonenumber.trim().isEmpty) {
      phonenumberError = 'Số điện thoại không được để trống.';
    } else if (!phoneRegex.hasMatch(_phonenumber)) {
      phonenumberError =
          'Số điện thoại không hợp lệ. Vui lòng nhập đúng định dạng.';
    }

    if (_password.trim().isEmpty) {
      passwordError = 'Mật khẩu không được để trống.';
    } else if (_password.length < 6) {
      passwordError = 'Mật khẩu phải có ít nhất 6 ký tự.';
    }

    setState(() {
      _phonenumberError = phonenumberError;
      _passwordError = passwordError;
    });

    return phonenumberError.isEmpty && passwordError.isEmpty;
  }

  Future<void> _handleLogin() async {
    if (!_validateForm()) return;

    bool isSuccess = false;
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/v1/account/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phonenumber': _phonenumber,
          'password': _password,
        }),
      );

      final data = jsonDecode(response.body);
      final token = data['accountLogin']['access_token'];

      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        isSuccess = true;
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (err) {
      String errorMessage =
          'Đã xảy ra lỗi không xác định. Vui lòng thử lại sau.';
      if (err is http.ClientException && err.toString().contains('response')) {
        final responseBody = jsonDecode(err.toString());
        errorMessage = responseBody['message'] ?? 'Đăng nhập thất bại.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });

      if (isSuccess) {
        Fluttertoast.showToast(
          msg: 'Đăng nhập thành công. Chào mừng bạn đến với ứng dụng.',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFe8ecf4),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 36.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/logo1.png',
                        width: 80,
                        height: 80,
                      ),
                      SizedBox(height: 36),
                      Text(
                        'Đăng nhập vào FastFood Online',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1D2A32),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Truy cập danh mục của bạn và nhiều hơn nữa',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF929292),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildInputField(
                          label: 'Số điện thoại',
                          onChanged: (value) => _phonenumber = value,
                          keyboardType: TextInputType.phone,
                          errorText: _phonenumberError.isNotEmpty
                              ? _phonenumberError
                              : null,
                        ),
                        SizedBox(height: 16),
                        _buildInputField(
                          label: 'Mật khẩu',
                          onChanged: (value) => _password = value,
                          obscureText: true,
                          errorText:
                              _passwordError.isNotEmpty ? _passwordError : null,
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF075eec),
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            minimumSize: Size(double.infinity, 50),
                          ),
                          child: Text(
                            _isLoading ? 'Đang đăng nhập...' : 'Đăng nhập',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/forgot-password');
                          },
                          child: Text(
                            'Quên mật khẩu?',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF075eec),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Bạn chưa có tài khoản? ',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF222),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, '/register');
                                },
                                child: Text(
                                  'Đăng ký',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF075eec),
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/home');
                          },
                          icon: Icon(
                            Icons.home,
                            size: 30,
                            color: Color(0xFF075eec),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.all(10),
                            shape: CircleBorder(),
                            elevation: 3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required Function(String) onChanged,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Color(0xFF222),
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          keyboardType: keyboardType,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: 'Nhập $label.toLowerCase()',
            hintStyle: TextStyle(color: Color(0xFF6b7280)),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: errorText != null ? Colors.red : Color(0xFFC9D3DB),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: errorText != null ? Colors.red : Color(0xFFC9D3DB),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: errorText != null ? Colors.red : Color(0xFFC9D3DB),
                width: 1,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          onChanged: onChanged,
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              errorText,
              style: TextStyle(
                color: Colors.red,
                fontSize: 13,
              ),
            ),
          ),
      ],
    );
  }
}
