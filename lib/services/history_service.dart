import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api.dart';

class HistoryService {
  // Fungsi utama mengambil dan merapikan data riwayat
  static Future<Map<String, dynamic>> fetchHistories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    if (token == null) throw Exception("Belum login");

    var response = await http.get(
      Uri.parse("${Api.baseUrl}/orders"),
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);

      Map<String, dynamic>? tempActive;
      List<Map<String, dynamic>> tempPast = [];

      for (var item in data) {
        String status = item['status'].toString().toLowerCase();

        // Ambil nama layanan dari relasi items (jika ada)
        String serviceName = "Layanan Barber";
        if (item['items'] != null && item['items'].length > 0) {
          serviceName = item['items'][0]['name_snapshot'] ?? "Layanan Barber";
        }

        // Ambil nama kapster dari relasi barber
        String barberName = item['barber'] != null
            ? item['barber']['name']
            : 'Kapster';

        // Format data
        Map<String, dynamic> formattedOrder = {
          "order_id": item['order_code'] ?? "ORD-${item['id']}",
          "shop_name": barberName,
          "address": "Lokasi Barbershop",
          "date": item['booking_date'].toString(),
          "time": item['booking_time'].toString().substring(
            0,
            5,
          ), // Ambil HH:mm
          "barber": barberName,
          "service": serviceName,
          "total": item['total_amount'].toString(),
          "status": status.toUpperCase(),
          "color": _getStatusColor(status),
        };

        // Pisahkan Tiket Aktif & Riwayat
        if ((status == 'pending' || status == 'waiting_approval') &&
            tempActive == null) {
          tempActive = formattedOrder;
        } else {
          tempPast.add(formattedOrder);
        }
      }

      // Kembalikan 2 data sekaligus dalam bentuk Map
      return {"activeTicket": tempActive, "pastHistories": tempPast};
    } else {
      throw Exception("Gagal mengambil data dari server");
    }
  }

  // Fungsi penentu warna status
  static Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
      case 'selesai':
        return Colors.green;
      case 'cancelled':
      case 'batal':
        return Colors.red;
      case 'pending':
      case 'waiting_approval':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }
}
