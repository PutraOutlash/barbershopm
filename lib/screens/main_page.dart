import 'package:flutter/material.dart';
import 'home_page.dart';
import 'explore_page.dart';
import 'history_page.dart';
import 'profile_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int index = 0;

  static const Color goldAccent = Color(0xFFD4AF67);
  static const Color darkCard = Color(0xFF1C1C1E);
  static const Color subtleText = Color(0xFF8E8E93);

  // 🔥 REMOTE CONTROL UNTUK HOME DAN HISTORY
  final GlobalKey<HomePageState> homeKey = GlobalKey<HomePageState>();
  final GlobalKey<HistoryPageState> historyKey =
      GlobalKey<HistoryPageState>(); // Tambahan baru

  late List<Widget> pages;

  @override
  void initState() {
    super.initState();
    // 🔥 PASANG KUNCINYA DI SINI
    pages = [
      HomePage(key: homeKey),
      const ExplorePage(),
      HistoryPage(key: historyKey), // Pasang remote history
      const ProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBody: true,
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: _buildFloatingNavBar(),
    );
  }

  Widget _buildFloatingNavBar() {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: darkCard,
          borderRadius: BorderRadius.circular(40),
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
            _buildNavItem(Icons.explore_outlined, Icons.explore, 1),
            _buildNavItem(Icons.history_outlined, Icons.history, 2),
            _buildNavItem(Icons.person_outline, Icons.person, 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData outlineIcon, IconData solidIcon, int i) {
    bool isSelected = index == i;

    return GestureDetector(
      onTap: () {
        setState(() => index = i);
        // 🔥 LOGIKA REFRESH OTOMATIS
        if (i == 0) homeKey.currentState?.loadUserData();
        if (i == 2)
          historyKey.currentState
              ?.refreshData(); // Panggil data riwayat terbaru!
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? goldAccent : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          isSelected ? solidIcon : outlineIcon,
          color: isSelected ? Colors.black : subtleText,
          size: 28,
        ),
      ),
    );
  }
}
