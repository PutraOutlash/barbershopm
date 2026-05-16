import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:barber_app/features/barber/widgets/profile/help_category_card.dart';
import 'package:barber_app/features/barber/widgets/profile/faq_item.dart';

class HelpCenterPage extends StatefulWidget {
  const HelpCenterPage({super.key});

  @override
  State<HelpCenterPage> createState() => _HelpCenterPageState();
}

class _HelpCenterPageState extends State<HelpCenterPage> {
  static const _gold = Color(0xFFFFC107);
  static const _bg = Color(0xFF0D0D0D);
  static const _card = Color(0xFF1C1C1E);
  static const _border = Color(0xFF2C2C2E);
  static const _muted = Color(0xFF8E8E93);

  final TextEditingController _searchCtrl = TextEditingController();

  // ── Data FAQ ──────────────────────────────────────────────────────────────────
  static const _faqs = [
    (
      q: 'Bagaimana cara menerima booking?',
      a:
          'Buka halaman Transaksi, lalu pilih booking dengan status Pending. '
          'Tap tombol "Terima" untuk mengkonfirmasi jadwal customer. '
          'Customer akan mendapat notifikasi otomatis.',
    ),
    (
      q: 'Bagaimana jika jadwal bentrok?',
      a:
          'Jika ada indikator "Jadwal Bentrok" pada booking, berarti terdapat '
          'jadwal lain di waktu yang sama. Tolak salah satu atau hubungi '
          'customer untuk menjadwal ulang.',
    ),
    (
      q: 'Cara mengubah profil barbershop saya?',
      a:
          'Buka halaman Profil → pilih "Edit Profil". Ubah informasi yang '
          'diperlukan seperti nama, email, nomor WhatsApp, alamat, dan jam '
          'operasional. Tap "Simpan Perubahan" untuk menyimpan.',
    ),
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────
            _buildHeader(context),
            const Divider(color: Color(0xFF1A1A1A), height: 1),

            // ── Scrollable body ──────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 36),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search intro text
                    const Text(
                      'Temukan jawaban atau hubungi kami',
                      style: TextStyle(color: _muted, fontSize: 13),
                    ),
                    const SizedBox(height: 12),

                    // Search bar
                    _buildSearchBar(),
                    const SizedBox(height: 28),

                    // Kategori
                    const Text(
                      'Kategori',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildCategoryGrid(),
                    const SizedBox(height: 28),

                    // FAQ Populer
                    const Text(
                      'FAQ Populer',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._faqs.map((f) => FaqItem(question: f.q, answer: f.a)),
                    const SizedBox(height: 24),

                    // Bantuan lanjut card
                    _buildContactCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        children: [
          // Back
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _border),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 15,
              ),
            ),
          ),

          // Title tengah
          const Expanded(
            child: Text(
              'Pusat Bantuan',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _gold,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

          // Search icon
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _border),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.search_rounded, color: _muted, size: 18),
          ),
        ],
      ),
    );
  }

  // ── Search bar ────────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: _border, width: 1),
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 16),
            child: Icon(Icons.search_rounded, color: _muted, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Cari bantuan...',
                hintStyle: TextStyle(
                  color: _muted.withOpacity(0.6),
                  fontSize: 14,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Grid kategori ─────────────────────────────────────────────────────────
  Widget _buildCategoryGrid() {
    const gridCategories = [
      (icon: Icons.calendar_today_rounded, title: 'Booking &\nTransaksi'),
      (icon: Icons.payments_outlined, title: 'Pembayaran'),
      (icon: Icons.inventory_2_outlined, title: 'Produk'),
      (icon: Icons.person_outline_rounded, title: 'Akun & Profil'),
    ];

    return Column(
      children: [
        // 2×2 grid
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.1,
          children: gridCategories
              .map(
                (c) => HelpCategoryCard(
                  icon: c.icon,
                  title: c.title,
                  onTap: () => HapticFeedback.lightImpact(),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 10),

        // "Lainnya" full width
        HelpCategoryCard(
          icon: Icons.more_horiz_rounded,
          title: 'Lainnya',
          isWide: true,
          onTap: () => HapticFeedback.lightImpact(),
        ),
      ],
    );
  }

  // ── Card bantuan lanjut ───────────────────────────────────────────────────
  Widget _buildContactCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Butuh bantuan lebih lanjut?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tim support kami siap membantu Anda 24/7 untuk memastikan kelancaran bisnis Anda.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _muted, fontSize: 13, height: 1.55),
          ),
          const SizedBox(height: 20),

          // Tombol WhatsApp
          GestureDetector(
            onTap: () => HapticFeedback.mediumImpact(),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: _gold,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: _gold.withOpacity(0.28),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_rounded, color: Colors.black, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'HUBUNGI WHATSAPP',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Tombol Email (outline)
          GestureDetector(
            onTap: () => HapticFeedback.lightImpact(),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _gold, width: 1.5),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.mail_outline_rounded, color: _gold, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'EMAIL SUPPORT',
                    style: TextStyle(
                      color: _gold,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
