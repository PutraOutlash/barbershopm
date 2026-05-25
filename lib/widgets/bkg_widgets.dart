import 'package:flutter/material.dart';

// ==========================================
// 1. WIDGET KARTU TANGGAL KALENDER
// ==========================================
class BkgDateCard extends StatelessWidget {
  final DateTime date;
  final bool isSelected;
  final String namaHari;
  final String namaBulan;
  final VoidCallback onTap;

  const BkgDateCard({
    super.key,
    required this.date,
    required this.isSelected,
    required this.namaHari,
    required this.namaBulan,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          border: Border.all(
            color: isSelected ? Colors.amber : Colors.transparent,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              namaHari,
              style: TextStyle(
                color: isSelected ? Colors.amber : Colors.grey,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "${date.day}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              namaBulan,
              style: const TextStyle(color: Colors.grey, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 2. WIDGET KOTAK PEMILIH JAM (TIME PICKER)
// ==========================================
class BkgTimeSelector extends StatelessWidget {
  final String? selectedTime;
  final VoidCallback onTap;

  const BkgTimeSelector({
    super.key,
    required this.selectedTime,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selectedTime != null ? Colors.amber : Colors.white10,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.access_time_rounded,
              color: selectedTime != null ? Colors.amber : Colors.white54,
            ),
            const SizedBox(width: 15),
            Text(
              selectedTime ?? "Ketuk untuk tentukan jam...",
              style: TextStyle(
                color: selectedTime != null ? Colors.amber : Colors.white54,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            if (selectedTime != null)
              const Icon(Icons.check_circle, color: Colors.amber, size: 20),
          ],
        ),
      ),
    );
  }
}
