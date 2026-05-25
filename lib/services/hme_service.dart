import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class HmeService {
  // 🔥 1. Hitung dan Format Waktu
  static String formatCurrentTime() {
    final now = DateTime.now();
    int hour = now.hour;
    int minute = now.minute;
    String ampm = hour >= 12 ? 'PM' : 'AM';
    hour = hour % 12;
    hour = hour == 0 ? 12 : hour;
    String hrStr = hour.toString().padLeft(2, '0');
    String minStr = minute.toString().padLeft(2, '0');
    return "SISTEM AKTIF / $hrStr:$minStr $ampm";
  }

  // 🔥 2. Lacak Toko Terdekat via GPS
  static Future<Map<String, dynamic>> findNearestShop(
    List<Map<String, dynamic>> shopLocations,
  ) async {
    if (shopLocations.isEmpty) throw "Data toko kosong";

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw "Izin lokasi ditolak";
      }
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    Map<String, dynamic>? nearestShop;
    double minDistance = double.infinity;

    for (var shop in shopLocations) {
      double distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        shop['latitude'],
        shop['longitude'],
      );

      if (distance < minDistance) {
        minDistance = distance;
        nearestShop = shop;
      }
    }

    if (nearestShop == null) throw "Toko terdekat tidak ditemukan";

    return {
      'shop': nearestShop,
      'distanceKm': (minDistance / 1000).toStringAsFixed(1),
    };
  }

  // 🔥 3. Buka Navigasi Maps
  static Future<void> openRouteMaps(String lat, String lng) async {
    final Uri googleMapsUrl = Uri.parse("google.navigation:q=$lat,$lng");
    final Uri browserUrl = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=$lat,$lng?q=$lat,$lng",
    );

    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl);
    } else {
      await launchUrl(browserUrl, mode: LaunchMode.externalApplication);
    }
  }
}
