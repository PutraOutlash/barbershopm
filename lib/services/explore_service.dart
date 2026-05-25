import 'dart:convert';
import 'package:flutter/foundation.dart'; // 🔥 Tambahan import untuk debugPrint
import 'package:http/http.dart' as http;
import '../config/api.dart';
import '../models/explore_model.dart';

class ExploreService {
  static Future<Map<String, dynamic>> getExploreData() async {
    try {
      // 🔥 TAMBAHKAN HEADER AGAR LARAVEL TIDAK NGIRIM HTML!
      final response = await http.get(
        Uri.parse("${Api.baseUrl}/explore"),
        headers: {"Accept": "application/json"},
      );

      // 🔥 SADAP SEKARANG JUGA SEBELUM MELEDAK
      debugPrint("=======================================");
      debugPrint("STATUS LARAVEL: ${response.statusCode}");
      debugPrint("ISI ERROR LARAVEL: ${response.body}");
      debugPrint("=======================================");

      final json = jsonDecode(response.body);

      if (response.statusCode == 200 && json['data'] != null) {
        final data = json['data'];

        List<dynamic> rawFaceShapes = data['face_shapes'] ?? [];
        List<dynamic> rawHairstyles = data['hairstyles'] ?? [];

        return {
          'face_shapes': rawFaceShapes
              .map((e) => FaceShape.fromJson(e as Map<String, dynamic>))
              .toList(),
          'hairstyles': rawHairstyles
              .map((e) => Hairstyle.fromJson(e as Map<String, dynamic>))
              .toList(),
        };
      }

      return {'face_shapes': <FaceShape>[], 'hairstyles': <Hairstyle>[]};
    } catch (e) {
      debugPrint("Gagal memproses data: $e");
      return {'face_shapes': <FaceShape>[], 'hairstyles': <Hairstyle>[]};
    }
  }
}
