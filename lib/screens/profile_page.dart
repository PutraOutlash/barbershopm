import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

// 🔥 IMPORT HALAMAN, MODEL, SERVICE, & WIDGET
import '../models/user_model.dart'; // Model bawaan Bos
import '../services/profile_service.dart';
import '../services/location_service.dart';
import '../widgets/profile_widgets.dart';

import 'login_page.dart';
import 'forgot_password_page.dart';
import 'change_email_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserModel? currentUser;

  File? _localImage;
  bool isUploadingPhoto = false;
  bool isUpdatingProfile = false;
  bool isGettingLocation = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    UserModel? data = await ProfileService.getProfile();
    if (mounted && data != null) {
      setState(() => currentUser = data);
    }
  }

  Future<void> _handleUploadPhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() {
      _localImage = File(image.path);
      isUploadingPhoto = true;
    });

    try {
      await ProfileService.uploadPhoto(_localImage!);
      _showSnackBar("Foto profil berhasil diperbarui!", Colors.green);
      _fetchData();
    } catch (e) {
      _showSnackBar(
        e.toString().replaceAll("Exception: ", ""),
        Colors.redAccent,
      );
      setState(() => _localImage = null);
    } finally {
      setState(() => isUploadingPhoto = false);
    }
  }

  Future<void> _handleSaveProfile(
    String name,
    String phone,
    String address,
    BuildContext modalContext,
  ) async {
    try {
      await ProfileService.updateProfile(name, phone, address);
      _fetchData();
      if (mounted) Navigator.pop(modalContext);
      _showSnackBar("Data berhasil disimpan!", Colors.green);
    } catch (e) {
      _showSnackBar(
        e.toString().replaceAll("Exception: ", ""),
        Colors.redAccent,
      );
    }
  }

  Future<void> _handleGetLocation(TextEditingController controller) async {
    try {
      String address = await LocationService.getCurrentAddress();
      controller.text = address;
      _showSnackBar("Lokasi berhasil ditemukan!", Colors.green);
    } catch (e) {
      _showSnackBar(e.toString(), Colors.redAccent);
    }
  }

  Future<void> _launchURL(String urlString) async {
    try {
      await launchUrl(
        Uri.parse(urlString),
        mode: LaunchMode.externalApplication,
      );
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
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  void _showEditProfileDialog() {
    TextEditingController nameController = TextEditingController(
      text: currentUser?.name ?? "",
    );
    TextEditingController phoneController = TextEditingController(
      text: (currentUser?.phone == "Belum diatur" || currentUser?.phone == null)
          ? ""
          : currentUser?.phone,
    );
    TextEditingController addressController = TextEditingController(
      text:
          (currentUser?.address == "Belum diatur" ||
              currentUser?.address == null)
          ? ""
          : currentUser?.address,
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
                CustomTextFieldWidget(
                  controller: nameController,
                  hint: "Nama Lengkap",
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 15),
                CustomTextFieldWidget(
                  controller: phoneController,
                  hint: "Nomor Handphone",
                  icon: Icons.phone_iphone,
                  isNumber: true,
                ),
                const SizedBox(height: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    CustomTextFieldWidget(
                      controller: addressController,
                      hint: "Alamat Tinggal",
                      icon: Icons.location_on_outlined,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 5),
                    TextButton.icon(
                      onPressed: isGettingLocation
                          ? null
                          : () async {
                              setStateModal(() => isGettingLocation = true);
                              await _handleGetLocation(addressController);
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
                            await _handleSaveProfile(
                              nameController.text,
                              phoneController.text,
                              addressController.text,
                              context,
                            );
                            setStateModal(() => isUpdatingProfile = false);
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

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Scaffold(
        backgroundColor: pureBlack,
        body: Center(child: CircularProgressIndicator(color: goldSolid)),
      );
    }

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
          // ==============================
          // 1. VIP HEADER CARD
          // ==============================
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
                  onTap: isUploadingPhoto ? null : _handleUploadPhoto,
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
                              : (currentUser!.photo != null)
                              ? NetworkImage(currentUser!.photo!)
                              : null,
                          child:
                              (_localImage == null &&
                                  currentUser!.photo == null)
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
                  currentUser!.name.toUpperCase(),
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
                    color: const Color(0x22E5C07B),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    currentUser!.email,
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

          // ==============================
          // 2. DATA PRIBADI
          // ==============================
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
          GroupedCardWidget(
            children: [
              ProfileListTileWidget(
                icon: Icons.badge_outlined,
                title: "Nama Lengkap",
                subtitle: currentUser!.name,
                trailing: const Icon(Icons.edit, size: 14, color: textMuted),
                onTap: _showEditProfileDialog,
              ),
              const CustomDividerWidget(),
              ProfileListTileWidget(
                icon: Icons.phone_iphone,
                title: "Nomor Handphone",
                subtitle: currentUser!.phone ?? "Belum diatur",
                trailing: const Icon(Icons.edit, size: 14, color: textMuted),
                onTap: _showEditProfileDialog,
              ),
              const CustomDividerWidget(),
              ProfileListTileWidget(
                icon: Icons.location_on_outlined,
                title: "Alamat",
                subtitle: currentUser!.address ?? "Belum diatur",
                trailing: const Icon(Icons.edit, size: 14, color: textMuted),
                onTap: _showEditProfileDialog,
              ),
            ],
          ),
          const SizedBox(height: 25),

          // ==============================
          // 3. KEAMANAN & AKSES
          // ==============================
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
          GroupedCardWidget(
            children: [
              ProfileListTileWidget(
                icon: Icons.alternate_email,
                title: "Ubah Email",
                subtitle: "Ganti email utama",
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ChangeEmailPage()),
                  );
                  if (result == true) _fetchData();
                },
              ),
              const CustomDividerWidget(),
              ProfileListTileWidget(
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

          // ==============================
          // 4. BANTUAN
          // ==============================
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
          GroupedCardWidget(
            children: [
              ProfileListTileWidget(
                customIcon: Image.network(
                  "https://cdn-icons-png.flaticon.com/512/733/733585.png",
                  width: 22,
                ),
                title: "Chat WhatsApp",
                subtitle: "089639126464",
                onTap: () => _launchURL("https://wa.me/6289639126464"),
              ),
              const CustomDividerWidget(),
              ProfileListTileWidget(
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

          // ==============================
          // 5. TOMBOL KELUAR
          // ==============================
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
}
