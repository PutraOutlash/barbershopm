import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../config/api.dart';
import '../models/user_model.dart';
import 'register_page.dart'; // Sesuaikan path ini dengan letak file register_page.dart kamu
import 'main_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // 🔥 TEMA WARNA PREMIUM
  static const Color goldAccent = Color(0xFFD4AF67);
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkCard = Color(0xFF1C1C1E);
  static const Color subtleText = Color(0xFF8E8E93);

  // --- CONTROLLER INPUT ---
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isPasswordVisible = false;
  bool isLoading = false;

  // --- LOGIKA LOGIN KE LARAVEL ---
  Future<void> login() async {
    // 1. Validasi input kosong
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      _showSnackBar("Email dan Password wajib diisi!", Colors.redAccent);
      return;
    }

    setState(() => isLoading = true);

    try {
      // 2. Tembak API Login Laravel
      var response = await http.post(
        Uri.parse("${Api.baseUrl}/login"),
        headers: {
          "Accept":
              "application/json", // Wajib agar Laravel merespons dengan JSON
        },
        body: {
          "login": emailController.text,
          "password": passwordController.text,
        },
      );

      var result = jsonDecode(response.body);
      setState(() => isLoading = false);

      // 3. Cek apakah Login Berhasil (Laravel biasanya mengirimkan 'token')
      if (response.statusCode == 200 && result['token'] != null) {
        // 4. TANGKAP DAN SIMPAN TOKEN & DATA USER KE MEMORI HP
        SharedPreferences prefs = await SharedPreferences.getInstance();

        // Simpan Token Sanctum (SANGAT PENTING untuk akses fitur lain)
        await prefs.setString("token", result['token']);

        // Mengubah JSON User dari Laravel menjadi Objek Dart
        UserModel userYangLogin = UserModel.fromJson(result['user']);

        // Simpan data profil penting untuk Beranda/Profile
        await prefs.setString("user_name", userYangLogin.name);
        await prefs.setString("user_role", userYangLogin.role ?? 'customer');

        // Ganti status login (Fitur Remember Me)
        await prefs.setBool("is_logged_in", true);

        _showSnackBar("Welcome back, ${userYangLogin.name}!", Colors.green);

        // 5. Pindah ke MainPage secara langsung
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const MainPage(),
            ), // 🔥 Ubah jadi ini
          );
        }
      } else {
        // Jika password salah atau user tidak ditemukan
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
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // --- UI BUILDER ---
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
              // HEADER
              const Text(
                "GENTLEMAN'S CLUB",
                style: TextStyle(
                  color: goldAccent,
                  fontSize: 12,
                  letterSpacing: 3,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Welcome Back",
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

              // FORM INPUT
              _buildTextField(
                controller: emailController,
                hintText: "Email Address",
                icon: Icons.email_outlined,
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

              // LUPA PASSWORD (Opsional/Bisa diklik jika nanti ada fiturnya)
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "Forgot Password?",
                  style: TextStyle(
                    color: subtleText.withOpacity(0.8),
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // TOMBOL LOGIN
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
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 2,
                          ),
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

              // TOMBOL PINDAH KE REGISTER
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

  // --- WIDGET BANTUAN UNTUK TEXTFIELD (BIAR RAPI & AESTHETIC) ---
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
