import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

// Pastikan file api.dart kamu di-import dengan benar sesuai foldermu
import '../config/api.dart';

class HairstyleService {
  // Fungsi ini bertugas menembak API Laravel yang baru kita buat
  static Future<List<dynamic>> getHairstyles() async {
    try {
      // Menembak rute /popular-styles yang ada di routes/api.php Laravel
      var url = Uri.parse('${Api.baseUrl}/popular-styles');

      var response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        // Kalau sukses, ubah JSON dari Laravel jadi List yang bisa dibaca Flutter
        return jsonDecode(response.body);
      } else {
        debugPrint(
          "Gagal mengambil data layanan terpopuler: ${response.statusCode}",
        );
        return [];
      }
    } catch (e) {
      debugPrint("Error load popular services: $e");
      return [];
    }
  }
}
