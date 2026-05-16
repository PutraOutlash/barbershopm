import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'edit_profile_page.dart';
import 'manage_product_page.dart';
import 'manage_service_page.dart'; // ← import halaman baru
import 'help_center_page.dart';
import 'package:barber_app/features/barber/widgets/profile/profile_menu_item.dart';
import 'package:barber_app/features/barber/widgets/profile/logout_dialog.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with AutomaticKeepAliveClientMixin {
  static const _gold = Color(0xFFFFC107);
  static const _bg = Color(0xFF0D0D0D);
  static const _card = Color(0xFF1C1C1E);
  static const _border = Color(0xFF2C2C2E);
  static const _muted = Color(0xFF8E8E93);
  static const _red = Color(0xFFFF453A);

  @override
  bool get wantKeepAlive => true;

  void _navigate(Widget page) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, a, b) => page,
        transitionsBuilder: (_, a, b, child) => SlideTransition(
          position: Tween(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildHeader(),
            const Divider(color: Color(0xFF1A1A1A), height: 1),
            const SizedBox(height: 28),
            _buildAvatarSection(),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildInfoCard(),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildMenuCard(),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: const Row(
        children: [
          Expanded(
            child: Text(
              'Profil',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.amber,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _gold, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: _gold.withOpacity(0.22),
                    blurRadius: 18,
                    spreadRadius: 2,
                  ),
                ],
                color: const Color(0xFF2A2000),
              ),
              alignment: Alignment.center,
              child: const Text(
                'BC',
                style: TextStyle(
                  color: _gold,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Positioned(
              right: 2,
              bottom: 2,
              child: GestureDetector(
                onTap: () => _navigate(const EditProfilePage()),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: _gold,
                    shape: BoxShape.circle,
                    border: Border.all(color: _bg, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.edit_rounded,
                    color: Colors.black,
                    size: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        const Text(
          'Barber Cave',
          style: TextStyle(
            color: Colors.amber,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 5),
        const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_on_outlined, color: _muted, size: 14),
            SizedBox(width: 4),
            Text(
              'Jl. Karimata, Jember',
              style: TextStyle(color: _muted, fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    const items = [
      (label: 'Nama Barbershop', value: 'Barber Cave Premium'),
      (label: 'Email', value: 'hello@barbercave.id'),
      (label: 'Nomor WhatsApp', value: '+62 812-3456-7890'),
      (
        label: 'Alamat Lengkap',
        value: 'Jl. Karimata No. 45, Sumber Sari, Jember, 68121',
      ),
      (label: 'Jam Operasional', value: 'Setiap Hari, 08:00 – 22:00'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border, width: 1),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'INFORMASI BARBERSHOP',
            style: TextStyle(
              color: _gold,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 14),
          ...items.asMap().entries.map((e) {
            final isLast = e.key == items.length - 1;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e.value.label,
                  style: const TextStyle(color: _muted, fontSize: 11),
                ),
                const SizedBox(height: 3),
                Text(
                  e.value.value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (!isLast) ...[
                  const SizedBox(height: 12),
                  const Divider(color: Color(0xFF2C2C2E), height: 1),
                  const SizedBox(height: 12),
                ] else
                  const SizedBox(height: 12),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMenuCard() {
    return Container(
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border, width: 1),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          // 1. Edit Profil
          ProfileMenuItem(
            icon: Icons.person_outline_rounded,
            title: 'Edit Profil',
            onTap: () => _navigate(const EditProfilePage()),
          ),

          // 2. Kelola Layanan ← BARU
          ProfileMenuItem(
            icon: Icons.content_cut_rounded,
            title: 'Kelola Layanan',
            onTap: () => _navigate(const ManageServicePage()),
          ),

          // 3. Kelola Produk
          ProfileMenuItem(
            icon: Icons.inventory_2_outlined,
            title: 'Kelola Produk',
            showDivider: true,
            onTap: () => _navigate(const ManageProductPage()),
          ),

          // 4. Pusat Bantuan
          ProfileMenuItem(
            icon: Icons.help_outline_rounded,
            title: 'Pusat Bantuan',
            showDivider: true,
            onTap: () => _navigate(const HelpCenterPage()),
          ),

          // 5. Logout
          ProfileMenuItem(
            icon: Icons.logout_rounded,
            title: 'Logout',
            titleColor: _red,
            iconColor: _red,
            trailing: ProfileMenuTrailing.none,
            showDivider: false,
            onTap: () => showLogoutDialog(
              context,
              onLogout: () {
                // TODO: implement actual logout
              },
            ),
          ),
        ],
      ),
    );
  }
}
