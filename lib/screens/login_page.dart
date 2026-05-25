import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:lottie/lottie.dart';

import '../config/api.dart';
import '../models/user_model.dart';
import 'register_page.dart';
import 'main_page.dart';
import 'forgot_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const Color goldAccent = Color(0xFFD4AF67);
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkCard = Color(0xFF1C1C1E);
  static const Color subtleText = Color(0xFF8E8E93);

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isPasswordVisible = false;
  bool isLoading = false;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      emailController.text = prefs.getString('saved_login') ?? '';
      passwordController.text = prefs.getString('saved_password') ?? '';
      _rememberMe = prefs.getBool('remember_me') ?? false;
    });
  }

  Future<void> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      _showSnackBar(
        "Username/Email dan Password wajib diisi!",
        Colors.redAccent,
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      var response = await http.post(
        Uri.parse("${Api.baseUrl}/login"),
        headers: {"Accept": "application/json"},
        body: {
          "login": emailController.text,
          "password": passwordController.text,
        },
      );

      var result = jsonDecode(response.body);
      setState(() => isLoading = false);

      if (response.statusCode == 200 && result['token'] != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();

        await prefs.setString("token", result['token']);

        UserModel userYangLogin = UserModel.fromJson(result['user']);

        await prefs.setString("user_name", userYangLogin.name);
        await prefs.setString("user_role", userYangLogin.role ?? 'customer');

        // 🔥 INI OBAT AMNESIANYA: Simpan URL foto ke memori lokal
        if (userYangLogin.photo != null) {
          await prefs.setString("user_photo", userYangLogin.photo!);
        } else {
          await prefs.remove(
            "user_photo",
          ); // Bersihkan jika user belum punya foto
        }

        await prefs.setBool("is_logged_in", true);

        if (_rememberMe) {
          await prefs.setString('saved_login', emailController.text);
          await prefs.setString('saved_password', passwordController.text);
          await prefs.setBool('remember_me', true);
        } else {
          await prefs.remove('saved_login');
          await prefs.remove('saved_password');
          await prefs.setBool('remember_me', false);
        }

        _showSnackBar("Welcome back, ${userYangLogin.name}!", Colors.green);

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainPage()),
          );
        }
      } else {
        _showSnackBar(
          result['message'] ?? "Email atau Password salah!",
          Colors.redAccent,
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      _showSnackBar("Terjadi kesalahan jaringan: $e", Colors.redAccent);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBackground,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "BarberOn",
                style: TextStyle(
                  color: goldAccent,
                  fontSize: 25,
                  letterSpacing: 3,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Welcome",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                "Sign in to continue your booking.",
                style: TextStyle(color: subtleText, fontSize: 14),
              ),
              const SizedBox(height: 50),

              _buildTextField(
                controller: emailController,
                hintText: "Username atau Email",
                icon: Icons.person_outline,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),

              _buildTextField(
                controller: passwordController,
                hintText: "Password",
                icon: Icons.lock_outline,
                isPassword: true,
                isObscure: !isPasswordVisible,
                onVisibilityToggle: () =>
                    setState(() => isPasswordVisible = !isPasswordVisible),
              ),
              const SizedBox(height: 15),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Theme(
                          data: ThemeData(unselectedWidgetColor: subtleText),
                          child: Checkbox(
                            value: _rememberMe,
                            checkColor: darkBackground,
                            activeColor: goldAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _rememberMe = value ?? false;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Remember Me",
                        style: TextStyle(color: subtleText, fontSize: 13),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ForgotPasswordPage(),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(50, 30),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      "Forgot Password?",
                      style: TextStyle(
                        color: goldAccent,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: isLoading ? null : login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: goldAccent,
                    foregroundColor: Colors.black,
                    elevation: 5,
                    shadowColor: goldAccent.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: isLoading
                      ? SizedBox(
                          width: 400,
                          height: 400,
                          child: Lottie.asset('assets/amonus.json'),
                        )
                      : const Text(
                          "SIGN IN",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "New to the club? ",
                    style: TextStyle(color: subtleText),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterPage(),
                        ),
                      );
                    },
                    child: const Text(
                      "Register here",
                      style: TextStyle(
                        color: goldAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    bool isObscure = false,
    TextInputType keyboardType = TextInputType.text,
    VoidCallback? onVisibilityToggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: darkCard,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white12),
      ),
      child: TextField(
        controller: controller,
        obscureText: isObscure,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: subtleText, fontSize: 14),
          prefixIcon: Icon(icon, color: subtleText, size: 20),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isObscure ? Icons.visibility_off : Icons.visibility,
                    color: subtleText,
                    size: 20,
                  ),
                  onPressed: onVisibilityToggle,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }
}
