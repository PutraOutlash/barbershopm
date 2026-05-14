import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../config/api.dart';

class BarberService {
  // 1. Fungsi Map Shops (Sudah diperbaiki tipe datanya)
  static Future<List<Map<String, dynamic>>> getMapShops() async {
    try {
      var url = Uri.parse('${Api.baseUrl}/map-shops');
      var response = await http.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        List<Map<String, dynamic>> parsedLocations = [];
        Set<String> uniqueShopNames = {};

        for (var item in data) {
          String shopName = item['shop_name'] ?? 'Barbershop';
          double? lat = double.tryParse(item['latitude']?.toString() ?? '');
          double? lng = double.tryParse(item['longitude']?.toString() ?? '');

          if (lat != null &&
              lng != null &&
              !uniqueShopNames.contains(shopName.toLowerCase())) {
            uniqueShopNames.add(shopName.toLowerCase());

            parsedLocations.add({
              "user_id": item['user_id'],
              "shop_name": shopName,
              "latitude": lat,
              "longitude": lng,
              "status": item['status'] ?? "TUTUP",
              "live_status": item['live_status'] ?? "KOSONG",
              "operational_hours":
                  item['operational_hours'] ?? "Tidak diketahui",
            });
          }
        }
        return parsedLocations;
      }
    } catch (e) {
      debugPrint("Koneksi API Peta Error: $e");
    }
    return [];
  }

  // 2. Fungsi Produk Barber (Supaya halaman produk tidak error)
  static Future<List<dynamic>> getProducts(int barberId) async {
    final response = await http.get(
      Uri.parse("${Api.baseUrl}/products/$barberId"),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return [];
  }
}
