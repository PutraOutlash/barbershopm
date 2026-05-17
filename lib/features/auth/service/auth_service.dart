import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:barber_app/core/config/api.dart';

class AuthService {
  // 🔥 FUNGSI LOGIN (Bisa pakai Username atau Email)
  static Future<Map<String, dynamic>> login(
    String
    email, // Variabel ini sekarang menangkap input Username/Email dari halaman login
    String password,
  ) async {
    try {
      var res = await http.post(
        Uri.parse("${Api.baseUrl}/api/login"),
        headers: {
          "Accept": "application/json", // 🔥 WAJIB
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: {
          "login": email, // karena kamu pakai login (email/username)
          "password": password,
        },
      );

      print("STATUS: ${res.statusCode}"); // 🔥 DEBUG
      print("RESPONSE: ${res.body}"); // 🔥 DEBUG

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      } else {
        return {
          "status": "failed",
          "message": "Terjadi kesalahan server: ${res.statusCode}",
        };
      }
    } catch (e) {
      print("ERROR: $e");
      return {
        "status": "failed",
        "message": "Gagal terhubung ke server. Pastikan XAMPP menyala.",
      };
    }
  }

  // 🔥 FUNGSI REGISTER (Dengan tambahan Username)
  static Future<Map<String, dynamic>> register(
    String name,
    String username,
    String email,
    String password,
  ) async {
    try {
      var res = await http.post(
        Uri.parse("${Api.baseUrl}/api/register"),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: {
          "name": name,
          "username": username,
          "email": email,
          "password": password,
          "role": "customer",
        },
      );

      print(res.statusCode);
      print(res.body);

      return jsonDecode(res.body);
    } catch (e) {
      return {"status": "error", "message": e.toString()};
    }
  }

  // 🔥 FUNGSI KIRIM OTP
  static Future<Map<String, dynamic>> sendOtp(String email) async {
    try {
      var res = await http.post(
        Uri.parse('${Api.baseUrl}/api/send_otp'),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {'email': email},
      );
      return jsonDecode(res.body);
    } catch (e) {
      return {"status": "error", "message": "Gagal terhubung ke server"};
    }
  }

  // 🔥 FUNGSI VERIFIKASI & UBAH PASSWORD
  static Future<Map<String, dynamic>> verifyAndChangePassword(
    String email,
    String otp,
    String newPassword,
  ) async {
    try {
      var res = await http.post(
        Uri.parse('${Api.baseUrl}/api/verify_password'),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {'email': email, 'otp': otp, 'new_password': newPassword},
      );
      return jsonDecode(res.body);
    } catch (e) {
      return {"status": "error", "message": "Gagal terhubung ke server"};
    }
  }
}
