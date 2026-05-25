import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api.dart';
import 'login_page.dart'; // Untuk kembali ke login

class ResetPasswordPage extends StatefulWidget {
  final String email;
  const ResetPasswordPage({super.key, required this.email});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController passController = TextEditingController();
  final TextEditingController confirmPassController = TextEditingController();
  bool isLoading = false;
  bool isObscure1 = true;
  bool isObscure2 = true;

  static const Color goldAccent = Color(0xFFD4AF67);
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkCard = Color(0xFF1C1C1E);

  Future<void> saveNewPassword() async {
    if (passController.text.length < 6) {
      _showSnackBar("Password minimal 6 karakter!", Colors.redAccent);
      return;
    }
    if (passController.text != confirmPassController.text) {
      _showSnackBar("Password tidak cocok!", Colors.redAccent);
      return;
    }

    setState(() => isLoading = true);

    try {
      var response = await http.post(
        Uri.parse("${Api.baseUrl}/reset-password"),
        headers: {"Accept": "application/json"},
        body: {"email": widget.email, "password": passController.text},
      );

      setState(() => isLoading = false);

      if (response.statusCode == 200) {
        _showSnackBar("Password berhasil diubah! Silakan Login.", Colors.green);
        // Tendang kembali ke halaman Login dengan me-reset semua rute
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (Route<dynamic> route) => false,
        );
      } else {
        _showSnackBar("Gagal mengubah password.", Colors.redAccent);
      }
    } catch (e) {
      setState(() => isLoading = false);
      _showSnackBar("Error jaringan: $e", Colors.redAccent);
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
              "Buat Password Baru",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 30),

            _buildPassField(
              passController,
              "Password Baru",
              isObscure1,
              () => setState(() => isObscure1 = !isObscure1),
            ),
            const SizedBox(height: 20),
            _buildPassField(
              confirmPassController,
              "Konfirmasi Password",
              isObscure2,
              () => setState(() => isObscure2 = !isObscure2),
            ),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: isLoading ? null : saveNewPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: goldAccent,
                  foregroundColor: Colors.black,
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text(
                        "SIMPAN PASSWORD",
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

  Widget _buildPassField(
    TextEditingController controller,
    String hint,
    bool isObscure,
    VoidCallback toggle,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: darkCard,
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        controller: controller,
        obscureText: isObscure,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
          prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
          suffixIcon: IconButton(
            icon: Icon(
              isObscure ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey,
            ),
            onPressed: toggle,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }
}
