import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart'; // 🔥 Untuk buka WA & IG
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import '../config/api.dart';
import 'login_page.dart';
import 'forgot_password_page.dart'; // 🔥 Untuk fitur OTP Keamanan

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _profileImage;

  String userName = "Memuat...";
  String userEmail = "Memuat...";
  String userPhone = "Belum diatur";
  String userAddress = "Belum diatur";
  String memberSince = "Mei 2026";

  String currentTime = "--:--";
  String activeSince = "--:--";
  Timer? _clockTimer;

  bool isDarkMode = true;
  bool isUpdating = false; // Loading state untuk update profil

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
    _clockTimer?.cancel();
    super.dispose();
  }

  void _initLiveClock() {
    final now = DateTime.now();
    activeSince =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
    _updateTime();
    _clockTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) => _updateTime(),
    );
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

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString("user_name") ?? "User Barber";
      userEmail = prefs.getString("user_email") ?? "user@gmail.com";

      // Jika kosong, tampilkan "Belum diatur"
      String? phone = prefs.getString("user_phone");
      userPhone = (phone != null && phone.isNotEmpty) ? phone : "Belum diatur";

      String? address = prefs.getString("user_address");
      userAddress = (address != null && address.isNotEmpty)
          ? address
          : "Belum diatur";

      String? imagePath = prefs.getString("profile_image_path");
      if (imagePath != null && imagePath.isNotEmpty)
        _profileImage = File(imagePath);
    });
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() => _profileImage = File(image.path));
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("profile_image_path", image.path);
      _showSnackBar("Foto Profil berhasil diperbarui!", Colors.green);
    }
  }

  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  // 🔥 FUNGSI MEMBUKA WHATSAPP & INSTAGRAM
  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      _showSnackBar("Gagal membuka tautan aplikasi.", Colors.redAccent);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: color,
      ),
    );
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
          // 1. VIP CARD DIGITAL
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

          // 2. INFORMASI KONTAK (HP & Alamat)
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

          // 3. PENGATURAN
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
                  "Keamanan & Akses",
                  onTap: _showSecurityDialog,
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

          // 4. LOGOUT
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

  Widget _profileItem(IconData icon, String title, String value) {
    bool isNotSet = value == "Belum diatur";
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
                    color: isNotSet
                        ? Colors.grey[600]
                        : (isDarkMode ? Colors.white : Colors.black),
                    fontSize: 14,
                    fontWeight: isNotSet ? FontWeight.normal : FontWeight.w600,
                    fontStyle: isNotSet ? FontStyle.italic : FontStyle.normal,
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

  Widget _divider() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Divider(
      color: isDarkMode ? Colors.white10 : Colors.black12,
      thickness: 1,
    ),
  );
  BoxDecoration _boxDecoration() => BoxDecoration(
    color: isDarkMode ? darkCard : Colors.grey[100],
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: isDarkMode ? Colors.white10 : Colors.transparent),
  );

  // 🔥 FUNGSI EDIT DATA DIRI (NAMA, HP, ALAMAT)
  void _showEditProfileDialog() {
    TextEditingController nameController = TextEditingController(
      text: userName,
    );
    TextEditingController phoneController = TextEditingController(
      text: userPhone == "Belum diatur" ? "" : userPhone,
    );
    TextEditingController addressController = TextEditingController(
      text: userAddress == "Belum diatur" ? "" : userAddress,
    );

    showDialog(
      context: context,
      barrierDismissible: !isUpdating,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            backgroundColor: darkCard,
            title: const Text(
              "Edit Data Diri",
              style: TextStyle(color: Colors.white),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildEditField(nameController, "Nama Lengkap"),
                  _buildEditField(phoneController, "Nomor HP", isNumber: true),
                  _buildEditField(
                    addressController,
                    "Alamat Lengkap",
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isUpdating ? null : () => Navigator.pop(context),
                child: const Text(
                  "Batal",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: goldAccent,
                  foregroundColor: Colors.black,
                ),
                onPressed: isUpdating
                    ? null
                    : () async {
                        setStateDialog(() => isUpdating = true);

                        try {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          String? token = prefs.getString("token");

                          // 🔥 TEMBAK API LARAVEL UNTUK UPDATE DATABASE
                          var response = await http.post(
                            Uri.parse(
                              "${Api.baseUrl}/profile/update",
                            ), // Rute API Laravel
                            headers: {
                              "Accept": "application/json",
                              "Authorization": "Bearer $token",
                            },
                            body: {
                              "name": nameController.text,
                              "phone": phoneController.text,
                              "address": addressController.text,
                            },
                          );

                          if (response.statusCode == 200) {
                            // Jika sukses, simpan juga ke memori HP
                            await prefs.setString(
                              "user_name",
                              nameController.text,
                            );
                            await prefs.setString(
                              "user_phone",
                              phoneController.text,
                            );
                            await prefs.setString(
                              "user_address",
                              addressController.text,
                            );

                            // Update tampilan UI Profile
                            setState(() {
                              userName = nameController.text;
                              userPhone = phoneController.text.isEmpty
                                  ? "Belum diatur"
                                  : phoneController.text;
                              userAddress = addressController.text.isEmpty
                                  ? "Belum diatur"
                                  : addressController.text;
                            });

                            if (mounted) Navigator.pop(context);
                            _showSnackBar(
                              "Profil berhasil diperbarui!",
                              Colors.green,
                            );
                          } else {
                            _showSnackBar(
                              "Gagal memperbarui profil di server.",
                              Colors.redAccent,
                            );
                          }
                        } catch (e) {
                          _showSnackBar(
                            "Terjadi kesalahan jaringan.",
                            Colors.redAccent,
                          );
                        } finally {
                          setStateDialog(() => isUpdating = false);
                        }
                      },
                child: isUpdating
                    ? const SizedBox(
                        width: 15,
                        height: 15,
                        child: CircularProgressIndicator(
                          color: Colors.black,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "Simpan",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEditField(
    TextEditingController controller,
    String label, {
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: goldAccent, fontSize: 12),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: goldAccent),
          ),
        ),
      ),
    );
  }

  // 🔥 MENU KEAMANAN: UBAH EMAIL & PASSWORD
  void _showSecurityDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: darkCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Keamanan & Akses",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Opsi Ubah Password (Lompat ke fitur Lupa Password OTP yang sudah kita buat)
              ListTile(
                leading: const Icon(Icons.password_rounded, color: goldAccent),
                title: const Text(
                  "Ubah Password",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Text(
                  "Reset sandi menggunakan OTP via Email",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.grey,
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ForgotPasswordPage(),
                    ),
                  );
                },
              ),
              const Divider(color: Colors.white10),

              // Opsi Ubah Email (Nanti Backendnya menyusul)
              ListTile(
                leading: const Icon(Icons.alternate_email, color: goldAccent),
                title: const Text(
                  "Ubah Email",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Text(
                  "Ganti email utama akun Anda",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.grey,
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showSnackBar(
                    "Fitur ubah Email sedang dalam pengembangan Backend!",
                    Colors.amber,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // 🔥 PUSAT BANTUAN YANG BISA DI-KLIK
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

            // Tombol Klik WhatsApp
            InkWell(
              onTap: () => _launchURL("https://wa.me/6289639126464"),
              child: Row(
                children: [
                  Image.network(
                    "https://cdn-icons-png.flaticon.com/512/733/733585.png",
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
            ),
            const SizedBox(height: 20),

            // Tombol Klik Instagram
            InkWell(
              onTap: () => _launchURL("https://instagram.com/bloombelly.app"),
              child: Row(
                children: [
                  Image.network(
                    "https://cdn-icons-png.flaticon.com/512/2111/2111463.png",
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
