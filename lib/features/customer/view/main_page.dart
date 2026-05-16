import 'package:flutter/material.dart';
import 'home_page.dart';
import 'explore_page.dart'; // 🔥 Import halaman baru (Eksplor)
import 'history_page.dart';
import 'profile_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int index = 0;

  // Tema Warna (Sesuaikan dengan warna aplikasimu)
  static const Color goldAccent = Color(0xFFD4AF67);
  static const Color darkCard = Color(0xFF1C1C1E);
  static const Color subtleText = Color(0xFF8E8E93);

  // 🔥 BookingPage DIHAPUS, diganti dengan ExplorePage
  final List<Widget> pages = [
    HomePage(),
    ExplorePage(),
    HistoryPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Warna latar belakang dasar
      // extendBody SANGAT PENTING agar halaman bisa memanjang ke bawah (di balik nav bar yang mengambang)
      extendBody: true,
      body: IndexedStack(index: index, children: pages),

      // Mengganti BottomNavigationBar bawaan dengan Custom Widget
      bottomNavigationBar: _buildFloatingNavBar(),
    );
  }

  // --- WIDGET CUSTOM UNTUK NAVBAR MENGAMBANG ---
  Widget _buildFloatingNavBar() {
    return Padding(
      // Mengatur jarak agar mengambang dari bawah dan samping
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
      child: Container(
        height: 70, // Ketinggian kapsul
        decoration: BoxDecoration(
          color: darkCard, // Warna kapsul gelap
          borderRadius: BorderRadius.circular(40), // Bentuk kapsul (Pill)
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(Icons.home_outlined, Icons.home, 0),
            // 🔥 ICON DIUBAH jadi Kompas untuk fitur Eksplor
            _buildNavItem(Icons.explore_outlined, Icons.explore, 1),
            _buildNavItem(Icons.history_outlined, Icons.history, 2),
            _buildNavItem(Icons.person_outline, Icons.person, 3),
          ],
        ),
      ),
    );
  }

  // --- WIDGET UNTUK MASING-MASING TOMBOL ---
  Widget _buildNavItem(IconData outlineIcon, IconData solidIcon, int i) {
    bool isSelected = index == i;

    return GestureDetector(
      onTap: () => setState(() => index = i),
      behavior: HitTestBehavior.opaque, // Memperluas area klik
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300), // Kecepatan animasi
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          // Jika dipilih, munculkan lingkaran Gold. Jika tidak, transparan.
          color: isSelected ? goldAccent : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          // Gunakan icon tebal (solid) saat dipilih, icon garis (outline) saat tidak
          isSelected ? solidIcon : outlineIcon,
          // Warna icon: Hitam saat di dalam lingkaran Gold, Abu-abu saat di luar
          color: isSelected ? Colors.black : subtleText,
          size: 28, // Ukuran icon
        ),
      ),
    );
  }
}