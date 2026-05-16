import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:barber_app/features/barber/view/review/review_rating_page.dart';
import 'package:barber_app/features/barber/view/profile/edit_profile_page.dart';
import 'package:barber_app/features/barber/view/profile/manage_service_page.dart';

class HistorySidebar extends StatefulWidget {
  const HistorySidebar({super.key});

  @override
  State<HistorySidebar> createState() => _HistorySidebarState();
}

class _HistorySidebarState extends State<HistorySidebar>
    with SingleTickerProviderStateMixin {
  // ── Warna ────────────────────────────────────────────────────────────────────
  static const _gold  = Color(0xFFFFC107);
  static const _muted = Color(0xFF8E8E93);
  static const _green = Color(0xFF4CD964);

  // ── Animasi masuk ─────────────────────────────────────────────────────────────
  late final AnimationController _ctrl;
  late final Animation<Offset>   _slideAnim;
  late final Animation<double>   _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _fadeAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _closeSidebar() async {
    await _ctrl.reverse();
    if (mounted) Navigator.of(context).pop();
  }

  /// Navigasi slide-from-right ke halaman tujuan.
  /// Sidebar ditutup dulu, lalu push ke halaman baru.
  Future<void> _navigateTo(Widget page) async {
    HapticFeedback.lightImpact();
    await _ctrl.reverse();
    if (!mounted) return;
    Navigator.of(context).pop(); // tutup sidebar (route-nya)
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, a, b) => page,
        transitionsBuilder: (_, a, b, child) => SlideTransition(
          position: Tween(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(parent: a, curve: Curves.easeOutCubic),
          ),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenW  = MediaQuery.of(context).size.width;
    final sidebarW = screenW * 0.78;

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // ── Overlay gelap ─────────────────────────────────────
          FadeTransition(
            opacity: _fadeAnim,
            child: GestureDetector(
              onTap: _closeSidebar,
              child: Container(color: Colors.black.withOpacity(0.55)),
            ),
          ),

          // ── Sidebar panel ─────────────────────────────────────
          SlideTransition(
            position: _slideAnim,
            child: SafeArea(
              child: SizedBox(
                width: sidebarW,
                height: double.infinity,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF0D0D0D),
                    border: Border(
                      right: BorderSide(color: Color(0xFF2C2C2E), width: 1),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Header barbershop ──────────────────
                      _buildShopHeader(),

                      const Divider(
                        color: Color(0xFF1F1F1F),
                        height: 1,
                        thickness: 1,
                      ),

                      // ── Menu utama ─────────────────────────
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),

                              // OPERASIONAL
                              const _SectionLabel(label: 'OPERASIONAL'),
                              const SizedBox(height: 8),

                              // 1. Jam Operasional → EditProfilePage
                              _SidebarItem(
                                icon: Icons.access_time_outlined,
                                title: 'Jam Operasional',
                                subtitle: 'Atur jam buka & tutup',
                                onTap: () =>
                                    _navigateTo(const EditProfilePage()),
                              ),

                              // 2. Kelola Layanan → ManageServicePage
                              _SidebarItem(
                                icon: Icons.content_cut_rounded,
                                title: 'Kelola Layanan',
                                subtitle: 'Edit layanan barbershop',
                                onTap: () =>
                                    _navigateTo(const ManageServicePage()),
                              ),

                              const SizedBox(height: 8),
                              const Divider(color: Color(0xFF1F1F1F), height: 1),
                              const SizedBox(height: 16),

                              // CUSTOMER
                              const _SectionLabel(label: 'CUSTOMER'),
                              const SizedBox(height: 8),

                              // 3. Ulasan & Rating → ReviewRatingPage
                              _SidebarItem(
                                icon: Icons.star_outline_rounded,
                                title: 'Ulasan & Rating',
                                subtitle: 'Lihat feedback customer',
                                onTap: () =>
                                    _navigateTo(const ReviewRatingPage()),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header barbershop ─────────────────────────────────────────────────────────
  Widget _buildShopHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 18),
      child: Row(
        children: [
          // Avatar BC
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.transparent,
              border: Border.all(color: _gold, width: 2),
            ),
            alignment: Alignment.center,
            child: const Text(
              'BC',
              style: TextStyle(
                color: _gold,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Info barbershop
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Barber Cave',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: _green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'BUKA',
                      style: TextStyle(
                        color: _green,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 3,
                      height: 3,
                      decoration: const BoxDecoration(
                        color: Color(0xFF555555),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Sen - Min',
                      style: TextStyle(
                        color: Color(0xFF8E8E93),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Label section uppercase ───────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF555555),
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

// ── Item menu sidebar ─────────────────────────────────────────────────────────
class _SidebarItem extends StatelessWidget {
  final IconData    icon;
  final String      title;
  final String      subtitle;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  static const _muted = Color(0xFF8E8E93);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        splashColor: const Color(0xFFFFC107).withOpacity(0.08),
        highlightColor: const Color(0xFFFFC107).withOpacity(0.04),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
          child: Row(
            children: [
              Icon(icon, color: _muted, size: 20),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        )),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: const TextStyle(
                          color: _muted,
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                        )),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: Color(0xFF3A3A3C), size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
