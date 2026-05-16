import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/config/api.dart';
import '../../../core/models/user_model.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // 🔥 TEMA WARNA PREMIUM
  static const Color goldAccent = Color(0xFFD4AF67);
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkCard = Color(0xFF1C1C1E);
  static const Color subtleText = Color(0xFF8E8E93);

  // --- CONTROLLER INPUT ---
  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool isLoading = false;

  // --- LOGIKA REGISTER KE LARAVEL ---
  Future<void> register() async {
    // 1. Validasi Input Kosong
    if (nameController.text.isEmpty ||
        usernameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      _showSnackBar("Semua kolom wajib diisi!", Colors.redAccent);
      return;
    }

    // 2. Validasi Konfirmasi Password (Wajib untuk Laravel)
    if (passwordController.text != confirmPasswordController.text) {
      _showSnackBar(
        "Password dan Konfirmasi Password tidak sama!",
        Colors.redAccent,
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // 3. Siapkan Data menggunakan Model
      UserModel newUser = UserModel(
        name: nameController.text,
        username: usernameController.text,
        email: emailController.text,
        password: passwordController.text,
      );

      // Konversi ke Map (Paket) lalu tambahkan password_confirmation
      Map<String, dynamic> dataKirim = newUser.toJson();
      dataKirim['password_confirmation'] = confirmPasswordController.text;
      dataKirim['role'] = 'customer';

      // 4. Tembak API Laravel (Perhatikan URL-nya pakai /register, bukan register.php)
      var response = await http.post(
        Uri.parse("${Api.baseUrl}/api/register"),
        headers: {
          "Accept":
              "application/json", // Wajib untuk Laravel agar membalas dengan JSON
        },
        body: dataKirim,
      );

      // 5. Cek Balasan dari Laravel
      var result = jsonDecode(response.body);

      setState(() => isLoading = false);

      // Status 'success' atau status code 200/201 tergantung kodingan API temanmu
      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          result['status'] == 'success') {
        _showSnackBar("Registrasi Berhasil! Silakan Login.", Colors.green);
        // Kembali ke halaman Login setelah sukses
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        // Tampilkan pesan error dari Laravel (misal: Email sudah terdaftar)
        _showSnackBar(
          result['message'] ?? "Gagal mendaftar. Periksa kembali datamu.",
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
      appBar: AppBar(
        backgroundColor: darkBackground,
        elevation: 0,
        iconTheme: const IconThemeData(color: goldAccent),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              const Text(
                "JOIN THE CLUB",
                style: TextStyle(
                  color: goldAccent,
                  fontSize: 12,
                  letterSpacing: 3,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Create Account",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                "Sign up to book your premium haircut.",
                style: TextStyle(color: subtleText, fontSize: 14),
              ),
              const SizedBox(height: 40),

              // FORM INPUT
              _buildTextField(
                controller: nameController,
                hintText: "Nama Lengkap",
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 20),

              _buildTextField(
                controller: usernameController,
                hintText: "Username",
                icon: Icons.alternate_email,
              ),
              const SizedBox(height: 20),

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
              const SizedBox(height: 20),

              _buildTextField(
                controller: confirmPasswordController,
                hintText: "Konfirmasi Password",
                icon: Icons.lock_reset,
                isPassword: true,
                isObscure: !isConfirmPasswordVisible,
                onVisibilityToggle: () => setState(
                  () => isConfirmPasswordVisible = !isConfirmPasswordVisible,
                ),
              ),
              const SizedBox(height: 40),

              // TOMBOL REGISTER
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: isLoading ? null : register,
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
                          "SIGN UP",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 30),

              // TOMBOL PINDAH KE LOGIN
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already a member? ",
                    style: TextStyle(color: subtleText),
                  ),
                  GestureDetector(
                    onTap: () =>
                        Navigator.pop(context), // Kembali ke halaman login
                    child: const Text(
                      "Login here",
                      style: TextStyle(
                        color: goldAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
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
