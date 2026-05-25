import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api.dart';

class ProductService {
  // Fungsi khusus untuk mengambil produk berdasarkan ID Barber
  static Future<List<dynamic>> fetchProductsByBarber(String barberId) async {
    try {
      var response = await http
          .get(Uri.parse('${Api.baseUrl}/products/$barberId'))
          .timeout(const Duration(seconds: 10));

      // 🔥 KITA SADAP APA YANG SEBENARNYA DIKIRIM LARAVEL
      print("=======================================");
      print("MENCARI PRODUK UNTUK ID BARBER: $barberId");
      print("STATUS LARAVEL: ${response.statusCode}");
      print("BALASAN LARAVEL: ${response.body}");
      print("=======================================");

      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);

        // 🔥 LOGIKA ANTI GAGAL:
        // Cek apakah Laravel mengirim bentuk List [] atau Map (dibungkus 'data')
        if (json is List) {
          return json; // Jika langsung List
        } else if (json is Map && json['data'] != null) {
          return json['data']; // Jika dibungkus {"data": [...]}
        } else {
          return [];
        }
      } else {
        return [];
      }
    } catch (e) {
      print("=======================================");
      print("Error Fetch Products: $e");
      print("=======================================");
      return []; // Jangan di-throw agar tidak meledakkan layar merah, kembalikan kosong saja
    }
  }
}
