import 'package:barber_app/core/services/hairstyle_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:io'; // 🔥 INI YANG BIKIN ERROR 'File', SEKARANG SUDAH ADA!
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'booking_page.dart';
import 'product_page.dart';
import 'explore_page.dart'; // 🔥 Import halaman Eksplor

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // --- STATE VARIABLES ---
  String userName = "Memuat...";
  String currentTime = "SISTEM AKTIF / --:--";

  Timer? _clockTimer;
  Timer? _popupTimer;
  bool _showWelcomePopup = true;

  // Variabel untuk fitur LIVE STATUS BARBER
  String? selectedBarberName;

  // 🔥 Variabel untuk menampung Foto Profil
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _updateTime();

    // Mesin Jam
    _clockTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _updateTime();
    });

    // Mesin Pop-up (Hilang setelah 4.5 detik)
    _popupTimer = Timer(const Duration(milliseconds: 4500), () {
      if (mounted) {
        setState(() {
          _showWelcomePopup = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _popupTimer?.cancel();
    super.dispose();
  }

  // --- FUNGSI AMBIL DATA & FOTO ---
  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String rawName = prefs.getString("user_name") ?? "Guest";

    if (rawName.isNotEmpty) {
      rawName = rawName[0].toUpperCase() + rawName.substring(1).toLowerCase();
    }

    // Mengambil path foto dari memori lokal
    String? imagePath = prefs.getString("profile_image_path");
    File? savedImage;
    if (imagePath != null && imagePath.isNotEmpty) {
      savedImage = File(imagePath);
    }

    if (mounted) {
      setState(() {
        userName = rawName;
        _profileImage = savedImage; // Menyimpan foto ke UI
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

    if (mounted) {
      setState(() {
        currentTime = "SISTEM AKTIF / $hrStr:$minStr $ampm";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Stack(
        children: [
          // ==========================================
          // LAPISAN BAWAH: KONTEN UTAMA APLIKASI
          // ==========================================
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
                  // --- HEADER KECIL ---
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
                      // 🔥 Avatar Kecil di Kanan (Sudah Terhubung dengan Foto)
                      Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2A2A),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white12),
                          image: _profileImage != null
                              ? DecorationImage(
                                  image: FileImage(_profileImage!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _profileImage == null
                            ? const Icon(Icons.person, color: Colors.grey)
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // --- 🗺️ RADAR BARBERSHOP (PETA) ---
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "RADAR BARBERSHOP",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "DI SEKITARMU",
                        style: TextStyle(
                          color: Color(0xFFE5C07B),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
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
                          initialCenter: LatLng(-8.1724, 113.6995),
                          initialZoom: 14.0,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.barber.app',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: const LatLng(-8.1724, 113.6995),
                                width: 50,
                                height: 50,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (selectedBarberName == null) {
                                        selectedBarberName =
                                            "Gentleman's Club Barbershop";
                                      } else {
                                        selectedBarberName = null;
                                      }
                                    });
                                  },
                                  child: Icon(
                                    Icons.location_on,
                                    color: selectedBarberName == null
                                        ? Colors.amber
                                        : Colors.red,
                                    size: 40,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- 🔥 KOTAK LIVE STATUS & TOMBOL EMAS ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C1E),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: selectedBarberName == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.radar,
                                color: Colors.amber.withOpacity(0.4),
                                size: 35,
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                "Pilih barbershop di peta",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                "Untuk melihat pantauan antrean secara live",
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
                                    decoration: const BoxDecoration(
                                      color: Colors.redAccent,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    "LIVE STATUS",
                                    style: TextStyle(
                                      color: Colors.redAccent,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                selectedBarberName!,
                                style: const TextStyle(
                                  color: Color(0xFFE5C07B),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Row(
                                children: [
                                  Icon(
                                    Icons.content_cut,
                                    color: Colors.white54,
                                    size: 16,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "Proses cukur: #ORD-092",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              const Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    color: Colors.white54,
                                    size: 16,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "10:00 AM - 10:45 AM (Berlangsung)",
                                    style: TextStyle(
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
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const BookingPage(),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFE5C07B),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text(
                                    "PESAN JADWAL DI SINI",
                                    style: TextStyle(
                                      color: Colors.black,
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

                  // --- MENU BUTTONS ---
                  Row(
                    children: [
                      Expanded(
                        child: _buildMenuCard(
                          title: "KATALOG GAYA",
                          subtitle: "PILIH KARAKTERMU",
                          icon: Icons.style,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ExplorePage(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _buildMenuCard(
                          title: "TOKO PRODUK",
                          subtitle: "AMUNISI PERAWATAN",
                          icon: Icons.shopping_bag,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ProductPage(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 35),

                  // --- GAYA RAMBUT POPULER ---
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "GAYA RAMBUT POPULER",
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

                  // --- FUTURE BUILDER GAYA RAMBUT ---
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
                        List<Map<String, String>> dummyData = [
                          {
                            "name": "Buzz Cut",
                            "image":
                                "https://images.unsplash.com/photo-1622286342621-4bd786c2447c?w=500&q=80",
                          },
                          {
                            "name": "Pompadour",
                            "image":
                                "https://images.unsplash.com/photo-1599351431202-1e0f0137899a?w=500&q=80",
                          },
                          {
                            "name": "French Crop",
                            "image":
                                "https://images.unsplash.com/photo-1502823403499-6ccfcf4fb453?w=500&q=80",
                          },
                        ];

                        return SizedBox(
                          height: 220,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: dummyData.length,
                            itemBuilder: (context, index) {
                              return _buildHairstyleCard(dummyData[index]);
                            },
                          ),
                        );
                      }

                      return SizedBox(
                        height: 220,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            return _buildHairstyleCard(snapshot.data![index]);
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 35),

                  // --- LAYANAN REKOMENDASI ---
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "LAYANAN\nREKOMENDASI",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      Text(
                        "BERDASARKAN\nRIWAYAT",
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.content_cut,
                            color: Colors.amber,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 15),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Premium Haircut",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Sesuai dengan riwayat bulan lalu",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const BookingPage(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            minimumSize: const Size(60, 30),
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                          ),
                          child: const Text(
                            "BOOKING",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ==========================================
          // LAPISAN ATAS: POP-UP WELCOME ANIMASI
          // ==========================================
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

  // --- WIDGET MENU KOTAK ---
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

  // --- WIDGET FOTO GAYA RAMBUT ---
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
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF333333),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(10),
                ),
                image: data['image'] != null
                    ? DecorationImage(
                        image: NetworkImage(data['image']),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: data['image'] == null
                  ? const Center(
                      child: Icon(Icons.image, color: Colors.grey, size: 40),
                    )
                  : null,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['name'] ?? "Style",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        "Premium Cut",
                        style: TextStyle(color: Colors.grey, fontSize: 8),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.bookmark_border, color: Colors.grey, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}