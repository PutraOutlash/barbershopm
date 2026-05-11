import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api.dart';
import 'otp_verification_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;

  static const Color goldAccent = Color(0xFFD4AF67);
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkCard = Color(0xFF1C1C1E);
  static const Color subtleText = Color(0xFF8E8E93);

  Future<void> sendOtp() async {
    if (emailController.text.isEmpty) {
      _showSnackBar("Mohon masukkan alamat email Anda!", Colors.redAccent);
      return;
    }

    setState(() => isLoading = true);

    try {
      // Menembak API Laravel yang baru saja kita buat
      var response = await http.post(
        Uri.parse("${Api.baseUrl}/forgot-password"),
        headers: {"Accept": "application/json"},
        body: {"email": emailController.text},
      );

      var result = jsonDecode(response.body);
      setState(() => isLoading = false);

      if (response.statusCode == 200) {
        _showSnackBar(result['message'], Colors.green);

        // TODO: Arahkan ke halaman Input OTP (Layar 2)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                OtpVerificationPage(email: emailController.text),
          ),
        );
        // Kita akan buat halamannya setelah ini berhasil!
      } else {
        _showSnackBar(
          result['message'] ?? "Gagal mengirim OTP",
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
      appBar: AppBar(
        backgroundColor: darkBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: goldAccent),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              "Forgot Password?",
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Masukkan email yang terdaftar. Kami akan mengirimkan kode OTP untuk mereset kata sandi Anda.",
              style: TextStyle(color: subtleText, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 40),

            // Form Input Email
            Container(
              decoration: BoxDecoration(
                color: darkCard,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white12),
              ),
              child: TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Alamat Email",
                  hintStyle: TextStyle(color: subtleText, fontSize: 14),
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: subtleText,
                    size: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 18),
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Tombol Kirim OTP
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: isLoading ? null : sendOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: goldAccent,
                  foregroundColor: Colors.black,
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
                        "KIRIM KODE OTP",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
