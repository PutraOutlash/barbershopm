import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart'; // 🔥 Tambahkan ini

// 🔥 SESUAIKAN DENGAN STRUKTUR FOLDER KAMU
import '../config/api.dart';
import 'booking_page.dart';
import 'product_page.dart';
import 'explore_page.dart';
import '../services/hairstyle_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String userName = "Memuat...";
  String currentTime = "SISTEM AKTIF / --:--";

  Timer? _clockTimer;
  Timer? _popupTimer;
  bool _showWelcomePopup = true;

  File? _profileImage; // Foto dari memori lokal (fallback)
  String? profileImageUrl; // Foto asli dari Database Laravel

  List<Map<String, dynamic>> shopLocations = [];
  Map<String, dynamic>? selectedShop;
  bool isFindingNearest = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _updateTime();
    _fetchShops();

    _clockTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _updateTime();
    });

    _popupTimer = Timer(const Duration(milliseconds: 4500), () {
      if (mounted) setState(() => _showWelcomePopup = false);
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _popupTimer?.cancel();
    super.dispose();
  }

  // 🔥 FUNGSI API PETA YANG SUDAH DINAMIS (TIDAK ADA HARDCODE)
  Future<void> _fetchShops() async {
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

            // Mengambil status yang sudah dihitung oleh Laravel
            String opHours = item['operational_hours'] ?? "Tidak diketahui";
            String status = item['status'] ?? "TUTUP";
            String liveStatus = item['live_status'] ?? "KOSONG";

            parsedLocations.add({
              "user_id": item['user_id'],
              "shop_name": shopName,
              "latitude": lat,
              "longitude": lng,
              "status": status,
              "live_status": liveStatus,
              "operational_hours": opHours,
            });
          }
        }

        if (mounted) setState(() => shopLocations = parsedLocations);
      }
    } catch (e) {
      debugPrint("Koneksi API Peta Error: $e");
    }
  }

  // 🔥 FUNGSI MENCARI BARBERSHOP TERDEKAT (GPS)
  Future<void> _findNearestShop() async {
    if (shopLocations.isEmpty) return;

    setState(() => isFindingNearest = true);
    try {
      // 1. Minta izin GPS
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied)
          throw "Izin lokasi ditolak";
      }

      // 2. Ambil kordinat user saat ini
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      Map<String, dynamic>? nearestShop;
      double minDistance = double.infinity;

      // 3. Hitung jarak ke SEMUA toko pakai rumus cerdas
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

      // 4. Pilih toko terdekat secara otomatis
      if (nearestShop != null) {
        setState(() => selectedShop = nearestShop);
        String distanceKm = (minDistance / 1000).toStringAsFixed(1);
        _showSnackBar(
          "Toko terdekat ditemukan: ${nearestShop['shop_name']} (Jarak: $distanceKm km)",
          Colors.green,
        );
      }
    } catch (e) {
      _showSnackBar("Gagal melacak lokasi: $e", Colors.redAccent);
    } finally {
      setState(() => isFindingNearest = false);
    }
  }

  // 🔥 MENGAMBIL FOTO DARI DATABASE/MEMORI
  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String rawName = prefs.getString("user_name") ?? "Guest";
    if (rawName.isNotEmpty) {
      rawName = rawName[0].toUpperCase() + rawName.substring(1).toLowerCase();
    }

    String? dbPhotoUrl = prefs.getString("user_photo");
    String? localImagePath = prefs.getString("profile_image_path");
    File? savedImage;
    if (localImagePath != null && localImagePath.isNotEmpty)
      savedImage = File(localImagePath);

    if (mounted) {
      setState(() {
        userName = rawName;
        profileImageUrl = dbPhotoUrl;
        _profileImage = savedImage;
      });
    }
  }

  void _updateTime() {
    final now = DateTime.now();
    int hour = now.hour;
    int minute = now.minute;
    String ampm = hour >= 12 ? 'PM' : 'AM';
    hour = hour % 12;
    hour = hour == 0 ? 12 : hour;
    String hrStr = hour.toString().padLeft(2, '0');
    String minStr = minute.toString().padLeft(2, '0');
    if (mounted)
      setState(() => currentTime = "SISTEM AKTIF / $hrStr:$minStr $ampm");
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: 120,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Halo, $userName!",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Mau cukur di mana hari ini?",
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      // 🔥 FOTO PROFIL
                      Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2A2A),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white12),
                          image:
                              (profileImageUrl != null &&
                                  profileImageUrl!.isNotEmpty)
                              ? DecorationImage(
                                  image: NetworkImage(profileImageUrl!),
                                  fit: BoxFit.cover,
                                )
                              : _profileImage != null
                              ? DecorationImage(
                                  image: FileImage(_profileImage!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child:
                            (profileImageUrl == null ||
                                    profileImageUrl!.isEmpty) &&
                                _profileImage == null
                            ? const Icon(Icons.person, color: Colors.grey)
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // ================= PETA RADAR =================
                  Row(
                    // 🔥 Hapus kata 'const' di depan Row ini
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        "RADAR BARBERSHOP",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // 🔥 SULAP MENJADI TOMBOL PINTAR
                      GestureDetector(
                        onTap: isFindingNearest ? null : _findNearestShop,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE5C07B).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFFE5C07B).withOpacity(0.5),
                            ),
                          ),
                          child: Row(
                            children: [
                              isFindingNearest
                                  ? const SizedBox(
                                      width: 12,
                                      height: 12,
                                      child: CircularProgressIndicator(
                                        color: Color(0xFFE5C07B),
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.my_location,
                                      color: Color(0xFFE5C07B),
                                      size: 12,
                                    ),
                              const SizedBox(width: 5),
                              const Text(
                                "CARI TERDEKAT",
                                style: TextStyle(
                                  color: Color(0xFFE5C07B),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Container(
                    height: 220,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: FlutterMap(
                        options: const MapOptions(
                          initialCenter: LatLng(-8.1718, 113.7002),
                          initialZoom: 13.0,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.barber.app',
                          ),
                          MarkerLayer(
                            markers: shopLocations.map((shop) {
                              bool isSelected = selectedShop == shop;
                              Color pinColor = shop['status'] == 'BUKA'
                                  ? Colors.amber
                                  : Colors.grey;
                              if (isSelected) pinColor = Colors.red;

                              return Marker(
                                point: LatLng(
                                  shop['latitude'],
                                  shop['longitude'],
                                ),
                                width: 60,
                                height: 60,
                                child: GestureDetector(
                                  onTap: () => setState(
                                    () =>
                                        selectedShop = isSelected ? null : shop,
                                  ),
                                  child: Column(
                                    children: [
                                      if (isSelected)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.black87,
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Text(
                                            shop['shop_name'].toString(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 8,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      Icon(
                                        Icons.location_on,
                                        color: pinColor,
                                        size: isSelected ? 45 : 35,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ================= INFO TOKO YANG DIPILIH =================
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C1E),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: selectedShop == null
                        ? const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.radar, color: Colors.amber, size: 35),
                              SizedBox(height: 10),
                              Text(
                                "Pilih barbershop di peta",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Ketuk icon pin untuk melihat ketersediaan",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: selectedShop!['status'] == 'BUKA'
                                          ? Colors.greenAccent
                                          : Colors.redAccent,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    selectedShop!['status'],
                                    style: TextStyle(
                                      color: selectedShop!['status'] == 'BUKA'
                                          ? Colors.greenAccent
                                          : Colors.redAccent,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          selectedShop!['live_status'] ==
                                              'SEDANG MENCUKUR'
                                          ? Colors.orange.withOpacity(0.2)
                                          : Colors.blue.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      selectedShop!['live_status'],
                                      style: TextStyle(
                                        color:
                                            selectedShop!['live_status'] ==
                                                'SEDANG MENCUKUR'
                                            ? Colors.orange
                                            : Colors.blue,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                selectedShop!['shop_name']
                                    .toString()
                                    .toUpperCase(),
                                style: const TextStyle(
                                  color: Color(0xFFE5C07B),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.storefront,
                                    color: Colors.white54,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Status: ${selectedShop!['status']}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.access_time,
                                    color: Colors.white54,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Jam Operasional: ${selectedShop!['operational_hours']}",
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                height: 44,
                                child: ElevatedButton(
                                  onPressed: selectedShop!['status'] == 'BUKA'
                                      ? () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => BookingPage(
                                              shopData: selectedShop!,
                                            ),
                                          ),
                                        )
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFE5C07B),
                                    disabledBackgroundColor: Colors.white10,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Text(
                                    selectedShop!['status'] == 'BUKA'
                                        ? "PESAN JADWAL DI SINI"
                                        : "TOKO SEDANG TUTUP",
                                    style: TextStyle(
                                      color: selectedShop!['status'] == 'BUKA'
                                          ? Colors.black
                                          : Colors.white24,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 25),

                  // ================= MENU BUTTONS =================
                  Row(
                    children: [
                      Expanded(
                        child: _buildMenuCard(
                          title: "KATALOG GAYA",
                          subtitle: "PILIH KARAKTERMU",
                          icon: Icons.style,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ExplorePage(),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _buildMenuCard(
                          title: "TOKO PRODUK",
                          subtitle: "AMUNISI PERAWATAN",
                          icon: Icons.shopping_bag,
                          onTap: () {
                            if (selectedShop == null) {
                              _showSnackBar(
                                "⚠️ Pilih barbershop di peta terlebih dahulu!",
                                Colors.amber,
                              );
                              return;
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ProductPage(shopData: selectedShop!),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 35),

                  // ================= GAYA RAMBUT BAWAH =================
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "Layanan Populer",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "LIHAT SEMUA",
                        style: TextStyle(
                          color: Color(0xFFE5C07B),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  FutureBuilder<List<dynamic>>(
                    future: HairstyleService.getHairstyles(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting)
                        return const SizedBox(
                          height: 220,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Colors.amber,
                            ),
                          ),
                        );
                      if (snapshot.hasError ||
                          !snapshot.hasData ||
                          snapshot.data!.isEmpty)
                        return const SizedBox(
                          height: 220,
                          child: Center(
                            child: Text(
                              "Belum ada gaya rambut di database.",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        );
                      return SizedBox(
                        height: 220,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) =>
                              _buildHairstyleCard(snapshot.data![index]),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),

          // ================= POPUP SELAMAT DATANG =================
          AnimatedPositioned(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOutBack,
            top: _showWelcomePopup ? 20 : -150,
            left: 20,
            right: 20,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: _showWelcomePopup ? 1.0 : 0.0,
              child: SafeArea(
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1C1E).withOpacity(0.98),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                    border: Border.all(
                      color: const Color(0xFFE5C07B).withOpacity(0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.waving_hand,
                        color: Color(0xFFE5C07B),
                        size: 35,
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentTime,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 9,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Halo, $userName!",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Sistem sudah siap melayanimu.",
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFF222222),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 15),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 8,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHairstyleCard(Map<String, dynamic> data) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        color: const Color(0xFF222222),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // BAGIAN GAMBAR
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF333333),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(10),
                ),
                image:
                    (data['image_url'] != null &&
                        data['image_url'].toString().isNotEmpty)
                    ? DecorationImage(
                        image: NetworkImage(data['image_url']),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              // Munculkan icon jika gambar tidak ada (NULL)
              child:
                  (data['image_url'] == null ||
                      data['image_url'].toString().isEmpty)
                  ? const Center(
                      child: Icon(Icons.cut, color: Colors.grey, size: 40),
                    )
                  : null,
            ),
          ),

          // BAGIAN KETERANGAN DATA
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['name'] ?? "Layanan", // Nama layanan (Haircut, dll)
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  data['shop_name'] ?? "Barbershop", // Nama toko
                  style: const TextStyle(
                    color: Color(0xFFE5C07B),
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  "Rp ${data['price'] ?? '0'}", // Harga layanan
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
