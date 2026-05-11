import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:async'; // 🔥 Diperlukan untuk Timer Jam Live
//import 'package:barber_app/features/auth/services/auth_service.dart';
import 'package:barber_app/features/auth/pages/login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // --- STATE VARIABLES ---
  File? _profileImage;

  // Nilai default
  String userName = "Memuat...";
  String userEmail = "Memuat...";
  String userPhone = "-";
  String userAddress = "-";
  String memberSince = "Mei 2026"; // 🔥 Pengganti Total Kunjungan

  // Variabel untuk Jam Live & Status Aktif
  String currentTime = "--:--";
  String activeSince = "--:--";
  Timer? _clockTimer;

  bool isDarkMode = true;

  static const Color goldAccent = Color(0xFFE5C07B);
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkCard = Color(0xFF1A1A1A);

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _initLiveClock();
  }

  @override
  void dispose() {
    _clockTimer
        ?.cancel(); // Matikan timer saat pindah halaman agar tidak bocor memori
    super.dispose();
  }

  // --- MESIN JAM LIVE & WAKTU AKTIF ---
  void _initLiveClock() {
    final now = DateTime.now();
    // Set waktu pertama kali halaman dibuka
    activeSince =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
    _updateTime();

    // Jalankan timer setiap detik untuk mengupdate jam
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTime();
    });
  }

  void _updateTime() {
    if (mounted) {
      final now = DateTime.now();
      setState(() {
        currentTime =
            "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
      });
    }
  }

  // --- FUNGSI LOAD DATA (Termasuk Foto Profil) ---
  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString("user_name") ?? "Aladdin";
      userEmail = prefs.getString("user_email") ?? "aladdin@gmail.com";
      userPhone = prefs.getString("user_phone") ?? "08123456789";
      userAddress = prefs.getString("user_address") ?? "Jl. Trunojoyo, Jember";

      // Load path foto profil jika sebelumnya sudah pernah upload
      String? imagePath = prefs.getString("profile_image_path");
      if (imagePath != null && imagePath.isNotEmpty) {
        _profileImage = File(imagePath);
      }
    });
  }

  // --- FUNGSI UPLOAD & SIMPAN FOTO PROFIL ---
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });

      // Simpan path gambar ke memori lokal (Bisa dibaca oleh Home Page nanti)
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("profile_image_path", image.path);

      // TODO: Tembak API backend (misal: upload_photo.php) untuk simpan ke MySQL Database di sini
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Foto Profil berhasil diperbarui!"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // --- FUNGSI LOGOUT AKTIF ---
  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? darkBackground : Colors.white,
      appBar: AppBar(
        title: Text(
          "AKUN SAYA",
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            fontSize: 16,
          ),
        ),
        backgroundColor: isDarkMode ? darkBackground : Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.only(
          left: 20,
          right: 20,
          top: 10,
          bottom: 120,
        ),
        children: [
          // ==========================================
          // 1. KARTU MEMBER DIGITAL (VIP CARD)
          // ==========================================
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2C2C2E), Color(0xFF1A1A1A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: goldAccent.withOpacity(0.5)),
              boxShadow: [
                BoxShadow(
                  color: goldAccent.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Foto Profil Kiri Atas
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 35,
                          backgroundColor: goldAccent.withOpacity(0.2),
                          backgroundImage: _profileImage != null
                              ? FileImage(_profileImage!)
                              : null,
                          child: _profileImage == null
                              ? const Icon(
                                  Icons.person,
                                  size: 35,
                                  color: goldAccent,
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: goldAccent,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF2C2C2E),
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 12,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // 🔥 JAM LIVE (Kanan Atas)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          "WAKTU LOKAL",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 8,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: goldAccent,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                size: 12,
                                color: Colors.black,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                currentTime,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  userEmail,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 25),
                // 🔥 STATISTIK BARU (Aktif Sejak & Member Sejak)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "AKTIF SEJAK",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 8,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.online_prediction,
                              color: Colors.greenAccent,
                              size: 16,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              "$activeSince WIB",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          "MEMBER SEJAK",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 8,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          memberSince,
                          style: const TextStyle(
                            color: goldAccent,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // ==========================================
          // 2. DATA DIRI (CONTACT INFO)
          // ==========================================
          const Text(
            "INFORMASI KONTAK",
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: _boxDecoration(),
            child: Column(
              children: [
                _profileItem(Icons.phone_android, "Nomor HP", userPhone),
                _divider(),
                _profileItem(Icons.location_on_outlined, "Alamat", userAddress),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // ==========================================
          // 3. PENGATURAN & KEAMANAN
          // ==========================================
          const Text(
            "PENGATURAN",
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: _boxDecoration(),
            child: Column(
              children: [
                _menuItem(
                  Icons.edit_outlined,
                  "Edit Data Diri",
                  onTap: _showEditProfileDialog,
                ),
                _divider(),
                _menuItem(
                  Icons.lock_outline,
                  "Keamanan & Password",
                  onTap: _showOTPPasswordDialog,
                ),
                _divider(),
                _menuItem(
                  Icons.headset_mic_outlined,
                  "Pusat Bantuan",
                  onTap: _showHelpDialog,
                ),
              ],
            ),
          ),

          const SizedBox(height: 35),

          // ==========================================
          // 4. TOMBOL LOGOUT
          // ==========================================
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent.withOpacity(0.1),
              foregroundColor: Colors.redAccent,
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Colors.redAccent, width: 1.5),
              ),
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: darkCard,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  title: const Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.redAccent,
                      ),
                      SizedBox(width: 10),
                      Text(
                        "Logout",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  content: const Text(
                    "Apakah Anda yakin ingin keluar dari akun?",
                    style: TextStyle(color: Colors.grey),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Batal",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _logout();
                      },
                      child: const Text("Ya, Keluar"),
                    ),
                  ],
                ),
              );
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout),
                SizedBox(width: 10),
                Text(
                  "LOGOUT",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPER ---
  Widget _profileItem(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey, size: 20),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuItem(IconData icon, String title, {required VoidCallback onTap}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2E),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: goldAccent, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 14,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Divider(
        color: isDarkMode ? Colors.white10 : Colors.black12,
        thickness: 1,
      ),
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: isDarkMode ? darkCard : Colors.grey[100],
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: isDarkMode ? Colors.white10 : Colors.transparent,
      ),
    );
  }

  // --- DIALOG MODALS ---
  void _showEditProfileDialog() {
    TextEditingController nameController = TextEditingController(
      text: userName,
    );
    TextEditingController phoneController = TextEditingController(
      text: userPhone,
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: darkCard,
        title: const Text(
          "Edit Data Diri",
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Nama",
                labelStyle: TextStyle(color: goldAccent),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
            ),
            TextField(
              controller: phoneController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Nomor Telepon",
                labelStyle: TextStyle(color: goldAccent),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: goldAccent,
              foregroundColor: Colors.black,
            ),
            onPressed: () async {
              setState(() {
                userName = nameController.text;
                userPhone = phoneController.text;
              });
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setString("user_name", nameController.text);
              prefs.setString("user_phone", phoneController.text);
              Navigator.pop(context);
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  void _showOTPPasswordDialog() {
    Navigator.pop(context);
  }

  // 🔥 UPDATE: PUSAT BANTUAN DENGAN LOGO WA & IG
  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: darkCard,
        title: const Text(
          "Pusat Bantuan",
          style: TextStyle(color: goldAccent, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Ada kendala dengan booking Anda? Hubungi kami melalui:",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 20),

            // Item WhatsApp
            Row(
              children: [
                Image.network(
                  "https://cdn-icons-png.flaticon.com/512/733/733585.png", // Logo WhatsApp Asli
                  width: 24,
                  height: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  "089639126464",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            // Item Instagram
            Row(
              children: [
                Image.network(
                  "https://cdn-icons-png.flaticon.com/512/2111/2111463.png", // Logo Instagram Asli
                  width: 24,
                  height: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  "@bloombelly.app",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: goldAccent,
              foregroundColor: Colors.black,
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup"),
          ),
        ],
      ),
    );
  }
}