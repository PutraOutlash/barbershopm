import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api.dart';
import '../models/user_model.dart'; // Import model milik Bos

class ProfileService {
  // 1. Ambil Data Profil
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

      // Simpan ke memori lokal
      await prefs.setString("user_name", user.name);
      await prefs.setString("user_email", user.email);

      // 🔥 FIX 1: Tambahkan pengaman "?? 'Belum diatur'" jika nilainya null
      await prefs.setString("user_phone", user.phone ?? "Belum diatur");
      await prefs.setString("user_address", user.address ?? "Belum diatur");

      // 🔥 FIX 2: Ubah photoUrl menjadi photo sesuai nama di user_model.dart
      if (user.photo != null && user.photo!.isNotEmpty) {
        await prefs.setString("user_photo", user.photo!);
      }

      return user;
    }
    return null;
  }

  // 2. Upload Foto Baru
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
      return result['photo_url']; // Ini tetap photo_url karena balasan dari Laravel
    }

    throw Exception(result['message'] ?? "Gagal upload foto");
  }

  // 3. Simpan Perubahan Teks
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
}
