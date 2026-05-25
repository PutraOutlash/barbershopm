import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// 🔥 IMPORTS SERVICE DAN MODELS
import '../services/explore_service.dart';
import '../models/explore_model.dart';
import '../services/face_detector_service.dart';

// 🔥 IMPORTS WIDGETS
import '../widgets/explo_loading_dialog.dart';
import '../widgets/explo_hasil_scan_dialog.dart';
import '../widgets/exp_widgets.dart';

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

  // --- LOGIKA KAMERA DAN DETEKSI WAJAH AI ---
  Future<void> _startFaceScan() async {
    final ImagePicker picker = ImagePicker();

    // 1. Buka Kamera Depan
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
    );

    if (image == null) return;

    // 2. Munculkan Loading Modal Modular
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const ExploLoadingDialog(),
      );
    }

    // 3. Proses Foto ke AI Google
    File imgFile = File(image.path);
    String? result = await FaceDetectionService.detectFaceShape(imgFile);

    // 4. Tutup Loading
    if (mounted) Navigator.pop(context);

    // 5. Tampilkan Hasil Analisis AI Modular (Pop-Up)
    if (mounted && result != null) {
      showDialog(
        context: context,
        builder: (context) => ExploHasilScanDialog(resultText: result),
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

      // TOMBOL FLOATING UNTUK AI KAMERA
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 120.0),
        child: FloatingActionButton.extended(
          onPressed: _startFaceScan,
          backgroundColor: const Color(0xFFE5C07B),
          icon: const Icon(Icons.face_retouching_natural, color: Colors.black),
          label: const Text(
            "Scan Muka",
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
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // MEMANGGIL WIDGET EKSTERNAL DARI exp_widgets.dart
                const ExpSectionTitle(title: "PANDUAN BENTUK WAJAH"),
                const SizedBox(height: 15),
                ExpFaceShapeList(shapes: faceShapes),

                const SizedBox(height: 30),

                const ExpSectionTitle(title: "INSPIRASI GAYA TERBARU"),
                const SizedBox(height: 15),
                ExpHairstyleGrid(styles: hairstyles),
              ],
            ),
          );
        },
      ),
    );
  }
}
