import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../config/api.dart';

class ChangeEmailPage extends StatefulWidget {
  const ChangeEmailPage({super.key});

  @override
  State<ChangeEmailPage> createState() => _ChangeEmailPageState();
}

class _ChangeEmailPageState extends State<ChangeEmailPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  bool isObscure = true;

  // Warna Tema
  static const Color pureBlack = Color(0xFF0A0A0C);
  static const Color cardBlack = Color(0xFF141416);
  static const Color goldSolid = Color(0xFFE5C07B);
  static const Color textMuted = Color(0xFF7E7E84);
  static const Color borderDark = Color(0xFF262628);

  Future<void> saveNewEmail() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      _showSnackBar("Email baru dan Password wajib diisi!", Colors.redAccent);
      return;
    }

    setState(() => isLoading = true);

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      var response = await http.post(
        Uri.parse("${Api.baseUrl}/profile/update-email"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: {
          "new_email": emailController.text,
          "password": passwordController.text,
        },
      );

      setState(() => isLoading = false);
      var result = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Simpan email baru ke memori lokal HP
        await prefs.setString("user_email", emailController.text);

        _showSnackBar("Email berhasil diperbarui!", Colors.green);
        if (mounted)
          Navigator.pop(context, true); // Kembali & kirim sinyal sukses
      } else {
        _showSnackBar(
          result['message'] ?? "Gagal mengubah email.",
          Colors.redAccent,
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      _showSnackBar("Kesalahan jaringan: $e", Colors.redAccent);
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pureBlack,
      appBar: AppBar(
        backgroundColor: pureBlack,
        elevation: 0,
        // 🔥 TAMBAHKAN KODE 'leading' INI UNTUK TOMBOL BACK PREMIUM
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: goldSolid,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "UBAH EMAIL",
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Ganti Email Utama",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Untuk keamanan akun Anda, silakan masukkan alamat email baru beserta kata sandi Anda saat ini.",
              style: TextStyle(color: textMuted, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 35),

            // Form Email Baru
            _buildTextField(
              emailController,
              "Alamat Email Baru",
              Icons.alternate_email,
              false,
            ),
            const SizedBox(height: 20),

            // Form Password Saat Ini
            _buildTextField(
              passwordController,
              "Password Saat Ini",
              Icons.lock_outline,
              true,
            ),
            const SizedBox(height: 40),

            // Tombol Simpan
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: goldSolid,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: isLoading ? null : saveNewEmail,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text(
                        "SIMPAN EMAIL",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    IconData icon,
    bool isPass,
  ) {
    return TextField(
      controller: controller,
      obscureText: isPass ? isObscure : false,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: textMuted),
        prefixIcon: Icon(icon, color: textMuted, size: 20),
        suffixIcon: isPass
            ? IconButton(
                icon: Icon(
                  isObscure ? Icons.visibility_off : Icons.visibility,
                  color: textMuted,
                  size: 20,
                ),
                onPressed: () => setState(() => isObscure = !isObscure),
              )
            : null,
        filled: true,
        fillColor: cardBlack,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: goldSolid),
        ),
      ),
    );
  }
}
