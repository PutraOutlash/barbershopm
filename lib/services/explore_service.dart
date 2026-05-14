import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api.dart';
import '../models/explore_model.dart';

class ExploreService {
  static Future<Map<String, dynamic>> getExploreData() async {
    final response = await http.get(Uri.parse("${Api.baseUrl}/explore"));

    if (response.statusCode == 200) {
      Map<String, dynamic> body = jsonDecode(response.body);

      // Ubah JSON List menjadi List of Objects
      List<FaceShape> shapes = (body['data']['face_shapes'] as List)
          .map((item) => FaceShape.fromJson(item))
          .toList();

      List<Hairstyle> styles = (body['data']['hairstyles'] as List)
          .map((item) => Hairstyle.fromJson(item))
          .toList();

      return {'face_shapes': shapes, 'hairstyles': styles};
    } else {
      throw Exception("Gagal mengambil data eksplor");
    }
  }
}
