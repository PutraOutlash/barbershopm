import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api.dart';

class AuthService {
  // 1. Fungsi Login
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse("${Api.baseUrl}/login"),
      body: {'login': email, 'password': password},
    );
    return jsonDecode(response.body);
  }

  // 2. Fungsi Ambil Profil dari Backend API
  static Future<Map<String, dynamic>?> getProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    final response = await http.get(
      Uri.parse("${Api.baseUrl}/profile"),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  // 3. Fungsi Ambil Data User dari Memori Lokal (YANG BIKIN ERROR TADI)
  static Future<Map<String, dynamic>> getLocalUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String rawName = prefs.getString("user_name") ?? "Guest";
    if (rawName.isNotEmpty) {
      rawName = rawName[0].toUpperCase() + rawName.substring(1).toLowerCase();
    }

    String? dbPhotoUrl = prefs.getString("user_photo");
    String? localImagePath = prefs.getString("profile_image_path");

    return {
      "userName": rawName,
      "dbPhotoUrl": dbPhotoUrl,
      "localImagePath": localImagePath,
    };
  }
}
