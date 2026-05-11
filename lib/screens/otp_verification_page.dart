import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api.dart';
import 'reset_password_page.dart'; // Nanti kita buat file ini

class OtpVerificationPage extends StatefulWidget {
  final String email; // Menerima email dari halaman sebelumnya
  const OtpVerificationPage({super.key, required this.email});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final TextEditingController otpController = TextEditingController();
  bool isLoading = false;

  static const Color goldAccent = Color(0xFFD4AF67);
  static const Color darkBackground = Color(0xFF121212);
  static const Color subtleText = Color(0xFF8E8E93);

  Future<void> verifyOtp() async {
    if (otpController.text.length != 6) {
      _showSnackBar("Masukkan 6 digit OTP!", Colors.redAccent);
      return;
    }

    setState(() => isLoading = true);

    try {
      var response = await http.post(
        Uri.parse("${Api.baseUrl}/verify-otp"),
        headers: {"Accept": "application/json"},
        body: {"email": widget.email, "otp": otpController.text},
      );

      var result = jsonDecode(response.body);
      setState(() => isLoading = false);

      if (response.statusCode == 200) {
        _showSnackBar("OTP Benar!", Colors.green);
        // Lanjut ke halaman Ganti Password
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResetPasswordPage(email: widget.email),
          ),
        );
      } else {
        _showSnackBar(result['message'] ?? "OTP Salah", Colors.redAccent);
      }
    } catch (e) {
      setState(() => isLoading = false);
      _showSnackBar("Kesalahan jaringan: $e", Colors.redAccent);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBackground,
      appBar: AppBar(backgroundColor: darkBackground, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Masukkan OTP",
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Kode 6 digit telah dikirim ke ${widget.email}",
              style: const TextStyle(color: subtleText, fontSize: 14),
            ),
            const SizedBox(height: 40),

            // Form OTP Aesthetic
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: goldAccent,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 15,
              ),
              decoration: const InputDecoration(
                counterText: "",
                hintText: "••••••",
                hintStyle: TextStyle(color: subtleText, letterSpacing: 15),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24, width: 2),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: goldAccent, width: 3),
                ),
              ),
            ),
            const SizedBox(height: 50),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: isLoading ? null : verifyOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: goldAccent,
                  foregroundColor: Colors.black,
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text(
                        "VERIFIKASI OTP",
                        style: TextStyle(
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
