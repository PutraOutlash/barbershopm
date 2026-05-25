import 'dart:io';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/profile_service.dart';
import '../services/location_service.dart';
import '../services/prf_service.dart';

// Asumsi warna dari file sebelumnya
const Color pureBlack = Color(0xFF000000);
const Color cardBlack = Color(0xFF1C1C1E);
const Color goldSolid = Color(0xFFE5C07B);
const Color textMuted = Color(0xFF8E8E93);
const Color borderDark = Colors.white10;

// ========================================================
// 1. WIDGET KARTU VIP HEADER (FOTO PROFIL & NAMA)
// ========================================================
class PrfHeaderCard extends StatelessWidget {
  final UserModel currentUser;
  final File? localImage;
  final bool isUploadingPhoto;
  final VoidCallback onUploadTap;

  const PrfHeaderCard({
    super.key,
    required this.currentUser,
    required this.localImage,
    required this.isUploadingPhoto,
    required this.onUploadTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
            onTap: isUploadingPhoto ? null : onUploadTap,
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
                    backgroundImage: localImage != null
                        ? FileImage(localImage!) as ImageProvider
                        : (currentUser.photo != null)
                        ? NetworkImage(currentUser.photo!)
                        : null,
                    child: (localImage == null && currentUser.photo == null)
                        ? const Icon(Icons.person, size: 40, color: textMuted)
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
            currentUser.name.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0x22E5C07B),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              currentUser.email,
              style: const TextStyle(
                color: goldSolid,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ========================================================
// 2. WIDGET BOTTOM SHEET KELUAR AKUN
// ========================================================
class PrfLogoutBottomSheet extends StatelessWidget {
  const PrfLogoutBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
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
            child: const Icon(Icons.logout, color: Colors.redAccent, size: 30),
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
                    padding: const EdgeInsets.symmetric(vertical: 16),
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
                    PrfService.logout(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
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
    );
  }
}

// ========================================================
// 3. WIDGET BOTTOM SHEET EDIT DATA DIRI (MEMILIKI STATE SENDIRI)
// ========================================================
class PrfEditProfileBottomSheet extends StatefulWidget {
  final UserModel currentUser;
  final VoidCallback onSuccess;
  final Widget Function(
    TextEditingController,
    String,
    IconData, {
    bool isNumber,
    int maxLines,
  })
  customTextFieldBuilder;

  const PrfEditProfileBottomSheet({
    super.key,
    required this.currentUser,
    required this.onSuccess,
    required this.customTextFieldBuilder,
  });

  @override
  State<PrfEditProfileBottomSheet> createState() =>
      _PrfEditProfileBottomSheetState();
}

class _PrfEditProfileBottomSheetState extends State<PrfEditProfileBottomSheet> {
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController addressController;

  bool isUpdatingProfile = false;
  bool isGettingLocation = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.currentUser.name);
    phoneController = TextEditingController(
      text:
          (widget.currentUser.phone == "Belum diatur" ||
              widget.currentUser.phone == null)
          ? ""
          : widget.currentUser.phone,
    );
    addressController = TextEditingController(
      text:
          (widget.currentUser.address == "Belum diatur" ||
              widget.currentUser.address == null)
          ? ""
          : widget.currentUser.address,
    );
  }

  Future<void> _handleGetLocation() async {
    setState(() => isGettingLocation = true);
    try {
      String address = await LocationService.getCurrentAddress();
      addressController.text = address;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() => isGettingLocation = false);
    }
  }

  Future<void> _handleSave() async {
    setState(() => isUpdatingProfile = true);
    try {
      await ProfileService.updateProfile(
        nameController.text,
        phoneController.text,
        addressController.text,
      );
      widget.onSuccess(); // Panggil fungsi refresh di Screen
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll("Exception: ", "")),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() => isUpdatingProfile = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
          widget.customTextFieldBuilder(
            nameController,
            "Nama Lengkap",
            Icons.person_outline,
          ),
          const SizedBox(height: 15),
          widget.customTextFieldBuilder(
            phoneController,
            "Nomor Handphone",
            Icons.phone_iphone,
            isNumber: true,
          ),
          const SizedBox(height: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              widget.customTextFieldBuilder(
                addressController,
                "Alamat Tinggal",
                Icons.location_on_outlined,
                maxLines: 2,
              ),
              const SizedBox(height: 5),
              TextButton.icon(
                onPressed: isGettingLocation ? null : _handleGetLocation,
                icon: isGettingLocation
                    ? const SizedBox(
                        width: 15,
                        height: 15,
                        child: CircularProgressIndicator(
                          color: goldSolid,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.my_location, color: goldSolid, size: 16),
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
              onPressed: isUpdatingProfile ? null : _handleSave,
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
  }
}
