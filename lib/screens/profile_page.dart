import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:lottie/lottie.dart';

// 🔥 IMPORT HALAMAN, MODEL, SERVICE, & WIDGET
import '../models/user_model.dart';
import '../services/profile_service.dart';
import '../services/prf_service.dart'; // Import service buatan kita

// Asumsi widget bawaan Anda
import '../widgets/profile_widgets.dart';
import '../widgets/prf_widgets.dart'; // Import widget buatan kita

import 'change_email_page.dart';
import 'otp_verification_page.dart';

// Asumsi warna
const Color pureBlack = Color(0xFF000000);
const Color cardBlack = Color(0xFF1C1C1E);
const Color goldSolid = Color(0xFFE5C07B);
const Color textMuted = Color(0xFF8E8E93);
const Color borderDark = Colors.white10;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserModel? currentUser;

  File? _localImage;
  bool isUploadingPhoto = false;

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

  // --- LOGIKA UPLOAD FOTO ---
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

  // --- LOGIKA MEMBUKA MODAL EDIT ---
  void _showEditProfileDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cardBlack,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => PrfEditProfileBottomSheet(
        currentUser: currentUser!,
        onSuccess: () {
          _fetchData();
          _showSnackBar("Data berhasil disimpan!", Colors.green);
        },
        // Helper untuk menggunakan CustomTextFieldWidget bawaan Anda di dalam modal modular
        customTextFieldBuilder:
            (controller, hint, icon, {isNumber = false, maxLines = 1}) {
              return CustomTextFieldWidget(
                controller: controller,
                hint: hint,
                icon: icon,
                isNumber: isNumber,
                maxLines: maxLines,
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
          // 1. VIP HEADER CARD (Modular)
          PrfHeaderCard(
            currentUser: currentUser!,
            localImage: _localImage,
            isUploadingPhoto: isUploadingPhoto,
            onUploadTap: _handleUploadPhoto,
          ),
          const SizedBox(height: 35),

          // 2. DATA PRIBADI
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

          // 3. KEAMANAN & AKSES
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
                onTap: () async {
                  // Munculkan loading dialog Lottie
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => Center(
                      child: SizedBox(
                        width: 200,
                        height: 200,
                        child: Lottie.asset(
                          'assets/amonus.json',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  );

                  try {
                    String targetEmail = await ProfileService.sendOtpOtomatis();
                    if (mounted) Navigator.pop(context); // Tutup Loading
                    if (mounted) {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              OtpVerificationPage(email: targetEmail),
                        ),
                      );
                      if (result == true) {
                        _fetchData();
                        _showSnackBar(
                          "Password Anda berhasil diperbarui! 🎉",
                          Colors.green,
                        );
                      }
                    }
                  } catch (e) {
                    if (mounted) Navigator.pop(context);
                    _showSnackBar(
                      e.toString().replaceAll("Exception: ", ""),
                      Colors.redAccent,
                    );
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 25),

          // 4. BANTUAN
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
                onTap: () =>
                    PrfService.launchExternalUrl("https://wa.me/6289639126464"),
              ),
              const CustomDividerWidget(),
              ProfileListTileWidget(
                customIcon: Image.network(
                  "https://cdn-icons-png.flaticon.com/512/2111/2111463.png",
                  width: 22,
                ),
                title: "Instagram",
                subtitle: "@bloombelly.app",
                onTap: () => PrfService.launchExternalUrl(
                  "https://instagram.com/bloombelly.app",
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),

          // 5. TOMBOL KELUAR
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
                  builder: (_) =>
                      const PrfLogoutBottomSheet(), // Menggunakan Widget Modular
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
