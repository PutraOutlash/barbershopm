import 'package:flutter/material.dart';

class ExploHasilScanDialog extends StatelessWidget {
  final String resultText;

  const ExploHasilScanDialog({super.key, required this.resultText});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF121212), // Hitam pekat
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
        side: const BorderSide(
          color: Color(0xFFE5C07B),
          width: 1.5,
        ), // Bingkai Gold
      ),
      child: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ikon Mahkota / Bintang (Gold)
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
            const SizedBox(height: 20),

            // Judul
            const Text(
              "HASIL ANALISIS AI",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 15),

            // HASIL UTAMA (Besar & Gold)
            Text(
              resultText.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFE5C07B),
                fontSize: 26,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),

            const Divider(color: Colors.white10, height: 40, thickness: 1),

            const Text(
              "Silakan cek panduan di halaman utama untuk melihat inspirasi gaya rambut yang cocok dengan bentuk wajah ini.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 30),

            // Tombol Tutup (Gold)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE5C07B),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 0,
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "SAYA MENGERTI",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
