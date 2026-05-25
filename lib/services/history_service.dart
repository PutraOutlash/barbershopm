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

      List<Map<String, dynamic>> tempProcess = [];
      List<Map<String, dynamic>> tempActive = [];
      List<Map<String, dynamic>> tempPast = [];

      for (var item in data) {
        // Baca status persetujuan & status pembayaran dari database
        String status = item['status'].toString().toLowerCase();
        String paymentStatus =
            item['payment_status']?.toString().toLowerCase() ?? 'pending';

        String serviceName = "Layanan Barber";
        if (item['items'] != null && item['items'].length > 0) {
          serviceName = item['items'][0]['name_snapshot'] ?? "Layanan Barber";
        }

        String barberName = item['barber'] != null
            ? item['barber']['name']
            : 'Kapster';

        Map<String, dynamic> formattedOrder = {
          "order_id": item['order_code'] ?? "ORD-${item['id']}",
          "snap_token": item['snap_token'],
          "shop_name": barberName,
          "address": "Lokasi Barbershop",
          "date": item['booking_date'].toString(),
          "time": item['booking_time'].toString().substring(0, 5),
          "barber": barberName,
          "service": serviceName,
          "total": item['total_amount'].toString(),
          "status": status.toUpperCase(),
          "color": _getStatusColor(status),
        };

        // 🔥 LOGIKA PENYORTIRAN SANGAT KETAT SESUAI ENUM DATABASE
        if (status == 'pending') {
          // 1. Murni Baru Pesan -> NUNGGU ACC BARBER
          formattedOrder['payment_state'] = 'WAITING_ACC';
          tempProcess.add(formattedOrder);
        } else if (status == 'confirmed' && paymentStatus == 'pending') {
          // 2. Sudah di-ACC Barber, TAPI belum dibayar -> MUNCUL TOMBOL BAYAR
          formattedOrder['payment_state'] = 'READY_TO_PAY';
          tempProcess.add(formattedOrder);
        } else if (status == 'confirmed' &&
            (paymentStatus == 'paid' || paymentStatus == 'settlement')) {
          // 3. Sudah di-ACC Barber, DAN Lunas -> PINDAH KE TIKET AKTIF (QR CODE)
          tempActive.add(formattedOrder);
        } else {
          // 4. Kalau statusnya 'completed' atau 'cancelled' -> MASUK RIWAYAT
          tempPast.add(formattedOrder);
        }
      }

      return {
        "processTickets": tempProcess,
        "activeTickets": tempActive,
        "pastHistories": tempPast,
      };
    } else {
      throw Exception("Gagal mengambil data dari server");
    }
  }

  // Fungsi penentu warna status
  static Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'confirmed':
        return Colors.blueAccent;
      case 'pending':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }
}
