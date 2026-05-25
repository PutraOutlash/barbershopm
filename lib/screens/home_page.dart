import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'product_page.dart';
import 'explore_page.dart';

// 🔥 IMPORTS SERVICE DAN WIDGET
import '../services/auth_service.dart';
import '../services/barber_service.dart';
import '../services/hairstyle_service.dart';
import '../services/hme_service.dart';
import '../widgets/hme_widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  String userName = "Memuat...";
  String currentTime = "SISTEM AKTIF / --:--";

  Timer? _clockTimer;
  Timer? _popupTimer;

  File? _profileImage;
  String? profileImageUrl;

  List<Map<String, dynamic>> shopLocations = [];
  Map<String, dynamic>? selectedShop;
  bool isFindingNearest = false;

  @override
  void initState() {
    super.initState();
    loadUserData();
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

  // --- LOGIKA PENGGUNAAN SERVICE ---
  void _updateTime() {
    if (mounted) {
      setState(() => currentTime = HmeService.formatCurrentTime());
    }
  }

  Future<void> _fetchShops() async {
    var shops = List<Map<String, dynamic>>.from(
      await BarberService.getMapShops(),
    );
    if (mounted) setState(() => shopLocations = shops);
  }

  Future<void> loadUserData() async {
    var userData = await AuthService.getLocalUserData();
    File? savedImage;
    if (userData['localImagePath'] != null &&
        userData['localImagePath'].isNotEmpty) {
      savedImage = File(userData['localImagePath']);
    }

    if (mounted) {
      setState(() {
        userName = userData['userName'];
        profileImageUrl = userData['dbPhotoUrl'];
        _profileImage = savedImage;
      });
    }
  }

  Future<void> _handleFindNearestShop() async {
    if (shopLocations.isEmpty) return;
    setState(() => isFindingNearest = true);

    try {
      final result = await HmeService.findNearestShop(shopLocations);
      setState(() => selectedShop = result['shop']);
      _showSnackBar(
        "Toko terdekat: ${result['shop']['shop_name']} (${result['distanceKm']} km)",
        Colors.green,
      );
    } catch (e) {
      _showSnackBar("Gagal melacak lokasi: $e", Colors.redAccent);
    } finally {
      setState(() => isFindingNearest = false);
    }
  }

  void _handleOpenRoute() {
    String lat = selectedShop!['latitude'].toString();
    String lng = selectedShop!['longitude'].toString();

    if (lat != 'null' && lng != 'null') {
      HmeService.openRouteMaps(lat, lng);
    } else {
      _showSnackBar("Koordinat Barbershop belum tersedia!", Colors.redAccent);
    }
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
                  // HEADER PROFILE
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

                  // SUB-HEADER BARBERSHOP MAP
                  Row(
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
                      GestureDetector(
                        onTap: isFindingNearest ? null : _handleFindNearestShop,
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

                  // WIDGET FLUTTER MAP
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

                  // WIDGET INFORMASI TOKO
                  HmeShopInfoWidget(
                    selectedShop: selectedShop,
                    onRouteTap: _handleOpenRoute,
                  ),
                  const SizedBox(height: 25),

                  // MENU KARTU NAVIGASI
                  Row(
                    children: [
                      Expanded(
                        child: HmeMenuCardWidget(
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
                        child: HmeMenuCardWidget(
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

                  // LAYANAN POPULER HEADER
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

                  // LIST LAYANAN POPULER
                  FutureBuilder<List<dynamic>>(
                    future: HairstyleService.getHairstyles(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox(
                          height: 220,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Colors.amber,
                            ),
                          ),
                        );
                      }
                      if (snapshot.hasError ||
                          !snapshot.hasData ||
                          snapshot.data!.isEmpty) {
                        return const SizedBox(
                          height: 220,
                          child: Center(
                            child: Text(
                              "Belum ada layanan di database.",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        );
                      }
                      return SizedBox(
                        height: 220,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) =>
                              HmePopularServiceCard(
                                data: snapshot.data![index],
                              ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
