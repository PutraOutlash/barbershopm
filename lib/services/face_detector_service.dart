import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceDetectionService {
  static Future<String?> detectFaceShape(File imageFile) async {
    // 1. Ubah foto jadi format yang bisa dibaca AI Google
    final InputImage inputImage = InputImage.fromFile(imageFile);

    // 2. Seting AI untuk fokus ke bentuk luar wajah (Contours)
    final options = FaceDetectorOptions(
      enableContours: true,
      performanceMode: FaceDetectorMode.fast,
    );
    final faceDetector = FaceDetector(options: options);

    try {
      // 3. AI mulai memproses foto
      final List<Face> faces = await faceDetector.processImage(inputImage);

      if (faces.isEmpty) {
        return "Tidak terdeteksi ada wajah. Coba foto ulang!";
      }

      // Ambil wajah pertama yang terdeteksi (asumsi selfie 1 orang)
      final face = faces.first;

      // Ambil ukuran kotak batas wajah (Bounding Box)
      final boundingBox = face.boundingBox;
      double width = boundingBox.width;
      double height = boundingBox.height;

      // Rumus Logika AI Sederhana
      double ratio = height / width;
      debugPrint("Lebar Wajah: $width, Tinggi: $height, Rasio: $ratio");

      // Menentukan bentuk wajah berdasarkan rasio tulang pipi ke dagu
      // Angka rasio ini bisa Bos kalibrasi lagi nanti kalau kurang akurat
      if (ratio > 1.35) {
        return "Wajah Oval";
      } else if (ratio < 1.20) {
        return "Wajah Kotak";
      } else {
        return "Wajah Bulat";
      }
    } catch (e) {
      debugPrint("Error AI Face Detection: $e");
      return "Gagal memproses wajah.";
    } finally {
      // Wajib ditutup biar RAM HP tidak jebol
      faceDetector.close();
    }
  }
}
