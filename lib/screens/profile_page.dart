import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:io';
import 'dart:convert';
import '../config/api.dart';
import 'login_page.dart';
import 'forgot_password_page.dart';
import 'change_email_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String userName = "Memuat...";
  String userEmail = "Memuat...";
  String userPhone = "Belum diatur";
  String userAddress = "Belum diatur";

  String? profileImageUrl;
  File? _localImage;
  bool isUploadingPhoto = false;
  bool isUpdatingProfile = false;
  bool isGettingLocation = false;

  // 🔥 PALET WARNA ULTRA-PREMIUM
  static const Color pureBlack = Color(0xFF0A0A0C);
  static const Color cardBlack = Color(0xFF141416);
  static const Color goldSolid = Color(0xFFE5C07B);
  static const Color goldDim = Color(0x22E5C07B);
  static const Color textMuted = Color(0xFF7E7E84);
  static const Color borderDark = Color(0xFF262628);

  @override
  void initState() {
    super.initState();
    _fetchProfileFromAPI();
  }

  // ==========================================
  // AMBIL DATA PROFIL TERBARU DARI DATABASE
  // ==========================================
  Future<void> _fetchProfileFromAPI() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      var response = await http.get(
        Uri.parse("${Api.baseUrl}/profile"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          userName = data['name'] ?? "Gentleman";
          userEmail = data['email'] ?? "gentleman@vip.com";
          userPhone = (data['phone'] != null && data['phone'].isNotEmpty)
              ? data['phone']
              : "Belum diatur";
          userAddress = (data['address'] != null && data['address'].isNotEmpty)
              ? data['address']
              : "Belum diatur";
          profileImageUrl = data['photo_url'];
        });

        await prefs.setString("user_name", userName);
        await prefs.setString("user_email", userEmail);
        await prefs.setString("user_phone", userPhone);
        await prefs.setString("user_address", userAddress);
        if (profileImageUrl != null)
          await prefs.setString("user_photo", profileImageUrl!);
      }
    } catch (e) {
      debugPrint("Gagal load profil: $e");
    }
  }

  // ==========================================
  // FUNGSI AUTO-DETECT LOKASI (GPS)
  // ==========================================
  Future<void> _getCurrentLocation(
    TextEditingController addressController,
  ) async {
    setState(() => isGettingLocation = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied)
          throw "Izin lokasi ditolak";
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address =
            "${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}";
        addressController.text = address;
        _showSnackBar("Lokasi berhasil ditemukan!", Colors.green);
      }
    } catch (e) {
      _showSnackBar("Gagal mendapat lokasi: $e", Colors.redAccent);
    } finally {
      setState(() => isGettingLocation = false);
    }
  }

  // ==========================================
  // FUNGSI UPLOAD FOTO KE DATABASE
  // ==========================================
  Future<void> _uploadPhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() {
      _localImage = File(image.path);
      isUploadingPhoto = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${Api.baseUrl}/profile/update-photo'),
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';
      request.files.add(await http.MultipartFile.fromPath('photo', image.path));

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var result = jsonDecode(responseData);

      if (response.statusCode == 200) {
        setState(
          () => profileImageUrl = result['photo_url'] ?? profileImageUrl,
        );
        _showSnackBar("Foto profil berhasil diperbarui!", Colors.green);
      } else {
        _showSnackBar(
          result['message'] ?? "Gagal upload foto.",
          Colors.redAccent,
        );
        setState(() => _localImage = null);
      }
    } catch (e) {
      _showSnackBar("Kesalahan jaringan.", Colors.redAccent);
      setState(() => _localImage = null);
    } finally {
      setState(() => isUploadingPhoto = false);
    }
  }

  // 🔥 FUNGSI BUKA LINK YANG SUDAH KEBAL BLOKIR ANDROID
  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      // Langsung paksa buka tanpa perlu 'canLaunchUrl'
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      _showSnackBar("Gagal membuka tautan.", Colors.redAccent);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted)
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pureBlack,
      appBar: AppBar(
        backgroundColor: pureBlack,
        elevation: 0,
        title: const Text(
          "AKUN",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        physics: const BouncingScrollPhysics(),
        children: [
          // ==========================================
          // 1. VIP HEADER CARD (Foto, Nama, Email)
          // ==========================================
          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: cardBlack,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: borderDark),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black45,
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                GestureDetector(
                  onTap: isUploadingPhoto ? null : _uploadPhoto,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: goldSolid, width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: pureBlack,
                          backgroundImage: _localImage != null
                              ? FileImage(_localImage!) as ImageProvider
                              : (profileImageUrl != null &&
                                    profileImageUrl!.isNotEmpty)
                              ? NetworkImage(profileImageUrl!)
                              : null,
                          child:
                              (_localImage == null &&
                                  (profileImageUrl == null ||
                                      profileImageUrl!.isEmpty))
                              ? const Icon(
                                  Icons.person,
                                  size: 40,
                                  color: textMuted,
                                )
                              : null,
                        ),
                      ),
                      if (isUploadingPhoto)
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(color: goldSolid),
                          ),
                        ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: goldSolid,
                            shape: BoxShape.circle,
                            border: Border.all(color: cardBlack, width: 3),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 14,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  userName.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: goldDim,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    userEmail,
                    style: const TextStyle(
                      color: goldSolid,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 35),

          // ==========================================
          // 2. DATA PRIBADI
          // ==========================================
          const Padding(
            padding: EdgeInsets.only(left: 10, bottom: 10),
            child: Text(
              "DATA PRIBADI",
              style: TextStyle(
                color: textMuted,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
          _buildGroupedCard(
            children: [
              _buildListTile(
                icon: Icons.badge_outlined,
                title: "Nama Lengkap",
                subtitle: userName,
                trailing: const Icon(Icons.edit, size: 14, color: textMuted),
                onTap: _showEditProfileDialog,
              ),
              _buildDivider(),
              _buildListTile(
                icon: Icons.phone_iphone,
                title: "Nomor Handphone",
                subtitle: userPhone,
                trailing: const Icon(Icons.edit, size: 14, color: textMuted),
                onTap: _showEditProfileDialog,
              ),
              _buildDivider(),
              _buildListTile(
                icon: Icons.location_on_outlined,
                title: "Alamat",
                subtitle: userAddress,
                trailing: const Icon(Icons.edit, size: 14, color: textMuted),
                onTap: _showEditProfileDialog,
              ),
            ],
          ),
          const SizedBox(height: 25),

          // ==========================================
          // 3. KEAMANAN & AKSES
          // ==========================================
          const Padding(
            padding: EdgeInsets.only(left: 10, bottom: 10),
            child: Text(
              "KEAMANAN",
              style: TextStyle(
                color: textMuted,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
          _buildGroupedCard(
            children: [
              _buildListTile(
                icon: Icons.alternate_email,
                title: "Ubah Email",
                subtitle: "Ganti email utama",
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ChangeEmailPage()),
                  );
                  if (result == true)
                    _fetchProfileFromAPI(); // Refresh data jika email diganti
                },
              ),
              _buildDivider(),
              _buildListTile(
                icon: Icons.lock_outline,
                title: "Ubah Kata Sandi",
                subtitle: "Reset via verifikasi OTP Email",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ForgotPasswordPage()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),

          // ==========================================
          // 4. BANTUAN
          // ==========================================
          const Padding(
            padding: EdgeInsets.only(left: 10, bottom: 10),
            child: Text(
              "BANTUAN & DUKUNGAN",
              style: TextStyle(
                color: textMuted,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
          _buildGroupedCard(
            children: [
              _buildListTile(
                customIcon: Image.network(
                  "https://cdn-icons-png.flaticon.com/512/733/733585.png",
                  width: 22,
                ),
                title: "Chat WhatsApp",
                subtitle: "089639126464",
                onTap: () => _launchURL("https://wa.me/6289639126464"),
              ),
              _buildDivider(),
              _buildListTile(
                customIcon: Image.network(
                  "https://cdn-icons-png.flaticon.com/512/2111/2111463.png",
                  width: 22,
                ),
                title: "Instagram",
                subtitle: "@bloombelly.app",
                onTap: () => _launchURL("https://instagram.com/bloombelly.app"),
              ),
            ],
          ),
          const SizedBox(height: 40),

          // ==========================================
          // 5. TOMBOL KELUAR
          // ==========================================
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: cardBlack,
                foregroundColor: Colors.redAccent,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: const BorderSide(color: borderDark),
                ),
              ),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: cardBlack,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(25),
                    ),
                  ),
                  builder: (_) => Padding(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.logout,
                            color: Colors.redAccent,
                            size: 30,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Keluar dari Akun?",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 30),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  side: const BorderSide(color: borderDark),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  "Batal",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _logout();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  "Ya, Keluar",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
              child: const Text(
                "KELUAR AKUN",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  // --- KOMPONEN BANTUAN UI ---
  Widget _buildGroupedCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: cardBlack,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderDark),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildListTile({
    IconData? icon,
    Widget? customIcon,
    required String title,
    String? subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: pureBlack,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderDark),
        ),
        child: customIcon ?? Icon(icon, color: goldSolid, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(color: textMuted, fontSize: 12),
            )
          : null,
      trailing:
          trailing ??
          const Icon(Icons.arrow_forward_ios, size: 14, color: borderDark),
      onTap: onTap,
    );
  }

  Widget _buildDivider() =>
      const Divider(color: borderDark, height: 1, indent: 20, endIndent: 20);

  // ==========================================
  // DIALOG EDIT PROFIL (NAMA, HP, ALAMAT)
  // ==========================================
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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cardBlack,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setStateModal) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 25,
              right: 25,
              top: 30,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Edit Data Pribadi",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 25),
                _buildTextField(
                  nameController,
                  "Nama Lengkap",
                  Icons.person_outline,
                ),
                const SizedBox(height: 15),
                _buildTextField(
                  phoneController,
                  "Nomor Handphone",
                  Icons.phone_iphone,
                  isNumber: true,
                ),
                const SizedBox(height: 15),

                // Form Alamat + Tombol GPS
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildTextField(
                      addressController,
                      "Alamat Tinggal",
                      Icons.location_on_outlined,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 5),
                    TextButton.icon(
                      onPressed: isGettingLocation
                          ? null
                          : () async {
                              setStateModal(() => isGettingLocation = true);
                              await _getCurrentLocation(addressController);
                              setStateModal(() => isGettingLocation = false);
                            },
                      icon: isGettingLocation
                          ? const SizedBox(
                              width: 15,
                              height: 15,
                              child: CircularProgressIndicator(
                                color: goldSolid,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(
                              Icons.my_location,
                              color: goldSolid,
                              size: 16,
                            ),
                      label: const Text(
                        "Gunakan Lokasi Saat Ini",
                        style: TextStyle(color: goldSolid, fontSize: 12),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: goldSolid,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: isUpdatingProfile
                        ? null
                        : () async {
                            setStateModal(() => isUpdatingProfile = true);
                            try {
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              String? token = prefs.getString("token");

                              var response = await http.post(
                                Uri.parse("${Api.baseUrl}/profile/update"),
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
                                _fetchProfileFromAPI(); // Langsung sinkron ke DB setelah simpan
                                if (mounted) Navigator.pop(context);
                                _showSnackBar(
                                  "Data berhasil disimpan!",
                                  Colors.green,
                                );
                              } else {
                                _showSnackBar(
                                  "Gagal menyimpan data.",
                                  Colors.redAccent,
                                );
                              }
                            } catch (e) {
                              _showSnackBar(
                                "Kesalahan jaringan.",
                                Colors.redAccent,
                              );
                            } finally {
                              setStateModal(() => isUpdatingProfile = false);
                            }
                          },
                    child: isUpdatingProfile
                        ? const CircularProgressIndicator(color: Colors.black)
                        : const Text(
                            "SIMPAN PERUBAHAN",
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: textMuted),
        prefixIcon: Padding(
          padding: EdgeInsets.only(bottom: maxLines > 1 ? 20.0 : 0.0),
          child: Icon(icon, color: textMuted, size: 20),
        ),
        filled: true,
        fillColor: pureBlack,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: goldSolid),
        ),
      ),
    );
  }
}
