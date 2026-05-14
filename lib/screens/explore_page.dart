import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/explore_service.dart';
import '../models/explore_model.dart';
import '../services/face_detector_service.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  late Future<Map<String, dynamic>> _exploreData;

  @override
  void initState() {
    super.initState();
    _exploreData = ExploreService.getExploreData();
  }

  // ==========================================
  // 🔥 FUNGSI BARU: MENJALANKAN AI SCAN WAJAH (UPDATED)
  // ==========================================
  Future<void> _startFaceScan() async {
    final ImagePicker picker = ImagePicker();

    // 1. Buka Kamera Depan
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
    );

    if (image == null) return;

    // 2. Munculkan Loading Modal
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            color: Color(0xFFE5C07B),
          ), // Pakai warna Gold
        ),
      );
    }

    // 3. Proses Foto ke AI Google
    File imgFile = File(image.path);
    String? result = await FaceDetectionService.detectFaceShape(imgFile);

    // 4. Tutup Loading
    if (mounted) Navigator.pop(context);

    // 5. Tampilkan Hasil Analisis AI (DESIGN OVERHAUL - PREMIUM BOTTOM SHEET)
    if (mounted && result != null) {
      showModalBottomSheet(
        context: context,
        backgroundColor: const Color(0xFF1C1C1E), // Latar gelap pekat
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        builder: (context) => Container(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Sesuai konten
            children: [
              // Ikon Atas (Gold)
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5C07B).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Color(0xFFE5C07B),
                  size: 35,
                ),
              ),
              const SizedBox(height: 25),

              // Judul (Putih Tebal)
              const Text(
                "HASIL ANALISIS AI",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 20),

              // Konten Teks (Abu-abu)
              const Text(
                "Berdasarkan pemindaian pintar kami, bentuk wajah kamu paling mendekati:",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 15),

              // 🔥 HASIL UTAMA (GOLD PREMIUM - BESAR & TEBAL)
              Text(
                result.toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFE5C07B),
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(height: 15),
              const Text(
                "Silakan cek panduan di atas untuk melihat inspirasi gaya rambut terbaik untukmu!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                  height: 1.5,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 35),

              // Tombol Mengerti (Gold)
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                      0xFFE5C07B,
                    ), // Warna Gold Premium
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "MENGERTI",
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10), // Gap bawah
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "EKSPLOR GAYA",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
      ),

      // 🔥 PERBAIKAN: Tombol Kamera Diangkat Lebih Tinggi & Teks Diganti
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 120.0), // 🔥 Dinaikkan jadi 120
        child: FloatingActionButton.extended(
          onPressed: _startFaceScan,
          backgroundColor: const Color(0xFFE5C07B), // Pakai Gold Premium
          icon: const Icon(Icons.face_retouching_natural, color: Colors.black),
          label: const Text(
            "Scan Muka", // 🔥 Teks diganti
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),

      body: FutureBuilder<Map<String, dynamic>>(
        future: _exploreData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFE5C07B)),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: const TextStyle(color: Colors.white),
              ),
            );
          } else if (!snapshot.hasData) {
            return const Center(
              child: Text("Data Kosong", style: TextStyle(color: Colors.white)),
            );
          }

          final faceShapes = snapshot.data!['face_shapes'] as List<FaceShape>;
          final hairstyles = snapshot.data!['hairstyles'] as List<Hairstyle>;

          return SingleChildScrollView(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: 160,
            ), // Dilebihkan biar grid gak ketutup tombol
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle("PANDUAN BENTUK WAJAH"),
                const SizedBox(height: 15),
                _buildFaceShapeList(faceShapes),
                const SizedBox(height: 30),
                _buildSectionTitle("INSPIRASI GAYA TERBARU"),
                const SizedBox(height: 15),
                _buildHairstyleGrid(hairstyles),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: const Color(0xFFE5C07B),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildFaceShapeList(List<FaceShape> shapes) {
    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: shapes.length,
        itemBuilder: (context, index) {
          final shape = shapes[index];
          return Container(
            width: 280,
            margin: const EdgeInsets.only(right: 15),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1E),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.network(shape.icon, width: 30, height: 30),
                    const SizedBox(width: 10),
                    Text(
                      shape.name.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  shape.description,
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                  maxLines: 2,
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5C07B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "✔ ${shape.suggestions}",
                    style: const TextStyle(
                      color: const Color(0xFFE5C07B),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHairstyleGrid(List<Hairstyle> styles) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio:
            0.70, // 🔥 Sedikit diperpanjang ke bawah biar deskripsi muat
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemCount: styles.length,
      itemBuilder: (context, index) {
        final style = styles[index];
        return ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Gambar Background
              Image.network(style.image, fit: BoxFit.cover),

              // Gradien Hitam (Dipertinggi biar tulisan bawah jelas)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withOpacity(0.9), Colors.transparent],
                    stops: const [0.0, 0.6], // Gradien lebih pekat di bawah
                  ),
                ),
              ),

              // Teks Konten
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Kategori (Badge)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5C07B),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        style.category,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Nama Gaya Rambut
                    Text(
                      style.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // 🔥 INI BARU: Menampilkan Deskripsi (Kecocokan Wajah)
                    Text(
                      style.description ?? "Cocok untuk semua wajah",
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                        fontStyle: FontStyle.italic,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
