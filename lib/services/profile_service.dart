import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api.dart';
import '../models/user_model.dart';

class ProfileService {
  static Future<UserModel?> getProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    final response = await http.get(
      Uri.parse("${Api.baseUrl}/profile"),
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      UserModel user = UserModel.fromJson(data);

      await prefs.setString("user_name", user.name);
      await prefs.setString("user_email", user.email);
      await prefs.setString("user_phone", user.phone ?? "Belum diatur");
      await prefs.setString("user_address", user.address ?? "Belum diatur");

      if (user.photo != null && user.photo!.isNotEmpty) {
        await prefs.setString("user_photo", user.photo!);
      }

      return user;
    }
    return null;
  }

  static Future<String?> uploadPhoto(File image) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${Api.baseUrl}/profile/update-photo'),
    );

    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';
    request.files.add(await http.MultipartFile.fromPath('photo', image.path));

    var response = await request.send();
    var result = jsonDecode(await response.stream.bytesToString());

    if (response.statusCode == 200) {
      // 🔥 FIX DATA BASI: Simpan URL terbaru ke memori sesaat setelah diupload
      String newPhotoUrl = result['photo_url'];
      if (!newPhotoUrl.startsWith('http')) {
        String storageBaseUrl = Api.baseUrl.replaceAll('/api', '/storage/');
        newPhotoUrl = "$storageBaseUrl$newPhotoUrl";
      }
      await prefs.setString("user_photo", newPhotoUrl);

      return newPhotoUrl;
    }

    throw Exception(result['message'] ?? "Gagal upload foto");
  }

  static Future<void> updateProfile(
    String name,
    String phone,
    String address,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    var response = await http.post(
      Uri.parse("${Api.baseUrl}/profile/update"),
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
      body: {"name": name, "phone": phone, "address": address},
    );

    if (response.statusCode != 200) {
      throw Exception("Gagal menyimpan data.");
    }
  }

  // =========================================================================
  // 🔥 FITUR BARU: KIRIM OTP OTOMATIS TANPA MINTA EMAIL LAGI
  // =========================================================================
  static Future<String> sendOtpOtomatis() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // 1. Ambil email diam-diam dari memori HP
    String? email = prefs.getString("user_email");

    if (email == null || email.isEmpty) {
      throw Exception("Data email tidak ditemukan. Silakan login ulang.");
    }

    // 2. Tembak API Laravel (Pastikan endpoint '/forgot-password' sesuai rute API Bos)
    var response = await http.post(
      Uri.parse("${Api.baseUrl}/forgot-password"),
      headers: {"Accept": "application/json"},
      body: {"email": email},
    );

    if (response.statusCode == 200) {
      // 3. Kembalikan email tersebut agar UI bisa meneruskannya ke halaman OTP
      return email;
    } else {
      var errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? "Gagal mengirim kode OTP.");
    }
  }
}
