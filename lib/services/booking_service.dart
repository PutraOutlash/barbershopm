import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api.dart';

class BookingService {
  // 1. Fungsi Mengambil Semua Layanan
  static Future<List<dynamic>> getAllServices() async {
    final response = await http
        .get(Uri.parse("${Api.baseUrl}/services"))
        .timeout(const Duration(seconds: 5));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception("Gagal mengambil data layanan dari server.");
  }

  // 2. Fungsi Mengambil Slot Waktu
  static Future<List<dynamic>> getTimeSlots() async {
    final response = await http
        .get(Uri.parse("${Api.baseUrl}/slots"))
        .timeout(const Duration(seconds: 5));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return [];
  }

  // 3. Fungsi Mengirim Pesanan (Checkout)
  static Future<Map<String, dynamic>> submitBooking(
    Map<String, String> data,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    if (token == null) {
      throw Exception("Kamu belum login! Silakan login terlebih dahulu.");
    }

    var response = await http.post(
      Uri.parse("${Api.baseUrl}/book"),
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
      body: data,
    );

    var result = jsonDecode(response.body);

    // Jika sukses (Status 201 Created)
    if (response.statusCode == 201) {
      return result;
    } else {
      // Lempar error asli dari server
      throw Exception("Error: ${result['error'] ?? result['message']}");
    }
  }
}
