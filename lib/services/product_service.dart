import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api.dart';

class ProductService {
  // Fungsi khusus untuk mengambil produk berdasarkan ID Barber
  static Future<List<dynamic>> fetchProductsByBarber(String barberId) async {
    try {
      var response = await http
          .get(Uri.parse('${Api.baseUrl}/products/$barberId'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return []; // Kembalikan list kosong jika data tidak ada
      }
    } catch (e) {
      debugPrint("Error Fetch Products: $e");
      throw Exception("Gagal terhubung ke server");
    }
  }
}
