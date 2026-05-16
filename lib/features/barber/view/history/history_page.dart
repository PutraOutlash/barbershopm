import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:barber_app/features/barber/view/notification/unified_notification_screen.dart';
import 'package:barber_app/features/barber/widgets/history/history_sidebar.dart';

enum _HistoryStatus { selesai, ditolak }

enum _HistoryFilter { semua, selesai, ditolak }

class _BookingHistory {
  final String id;
  final String customerName;
  final String serviceName;
  final String timeRange;
  final String price;
  final _HistoryStatus status;
  final bool hasAvatar;
  final String section; // "Hari Ini" | "Kemarin" | dll

  const _BookingHistory({
    required this.id,
    required this.customerName,
    required this.serviceName,
    required this.timeRange,
    required this.price,
    required this.status,
    required this.section,
    this.hasAvatar = false,
  });

  String get initials {
    final parts = customerName.trim().split(' ');
    return parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : customerName.substring(0, 2).toUpperCase();
  }
}

// ── Dummy data ────────────────────────────────────────────────────────────────
const _kDummyData = [
  _BookingHistory(
    id: 'H001',
    customerName: 'Alex Mercer',
    serviceName: 'Classic Fade',
    timeRange: '14:00 - 15:00',
    price: 'Rp 250.000',
    status: _HistoryStatus.selesai,
    section: 'Hari Ini',
    hasAvatar: true,
  ),
  _BookingHistory(
    id: 'H002',
    customerName: 'John Doe',
    serviceName: 'Beard Trim & Shape',
    timeRange: '11:00 - 11:45',
    price: 'Rp 150.000',
    status: _HistoryStatus.ditolak,
    section: 'Hari Ini',
    hasAvatar: false,
  ),
  _BookingHistory(
    id: 'H003',
    customerName: 'Michael Chen',
    serviceName: 'Executive Cut + Wash',
    timeRange: '16:30 - 17:30',
    price: 'Rp 300.000',
    status: _HistoryStatus.selesai,
    section: 'Kemarin',
    hasAvatar: true,
  ),
  _BookingHistory(
    id: 'H004',
    customerName: 'Raka Wijaya',
    serviceName: 'Hot Towel Shave',
    timeRange: '10:00 - 10:30',
    price: 'Rp 120.000',
    status: _HistoryStatus.selesai,
    section: 'Kemarin',
    hasAvatar: false,
  ),
  _BookingHistory(
    id: 'H005',
    customerName: 'Budi Santoso',
    serviceName: 'Classic Fade + Beard Trim',
    timeRange: '13:00 - 14:00',
    price: 'Rp 180.000',
    status: _HistoryStatus.ditolak,
    section: '23 Mei',
    hasAvatar: false,
  ),
  _BookingHistory(
    id: 'H006',
    customerName: 'Dimas Prayoga',
    serviceName: 'Premium Hair Sculpting',
    timeRange: '09:00 - 10:00',
    price: 'Rp 220.000',
    status: _HistoryStatus.selesai,
    section: '23 Mei',
    hasAvatar: true,
  ),
];

// ═══════════════════════════════════════════════════════════════════════════════
// HISTORY PAGE
// ═══════════════════════════════════════════════════════════════════════════════

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage>
    with AutomaticKeepAliveClientMixin {
  // ── Konstanta warna ──────────────────────────────────────────────────────────
  static const _bg = Color(0xFF000000);
  static const _gold = Color(0xFFFFC107);
  static const _card = Color(0xFF1C1C1E);
  static const _border = Color(0xFF2C2C2E);
  static const _muted = Color(0xFF8E8E93);

  // ── State ────────────────────────────────────────────────────────────────────
  _HistoryFilter _activeFilter = _HistoryFilter.semua;
  String _selectedMonth = 'Mei 2026';

  @override
  bool get wantKeepAlive => true;

  // ── Filter logic ─────────────────────────────────────────────────────────────
  List<_BookingHistory> get _filtered {
    switch (_activeFilter) {
      case _HistoryFilter.semua:
        return _kDummyData;
      case _HistoryFilter.selesai:
        return _kDummyData.where((h) => h.status == _HistoryStatus.selesai).toList();
      case _HistoryFilter.ditolak:
        return _kDummyData.where((h) => h.status == _HistoryStatus.ditolak).toList();
    }
  }

  // ── Grouped sections ─────────────────────────────────────────────────────────
  Map<String, List<_BookingHistory>> get _grouped {
    final result = <String, List<_BookingHistory>>{};
    for (final item in _filtered) {
      result.putIfAbsent(item.section, () => []).add(item);
    }
    return result;
  }

  // ── Build sections list ───────────────────────────────────────────────────────
  List<Widget> _buildSections() {
    final sections = _grouped;
    final widgets = <Widget>[];

    for (final entry in sections.entries) {
      // Section title
      widgets.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 12),
          child: Text(
            entry.key,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
        ),
      );

      // Cards
      for (final item in entry.value) {
        widgets.add(_HistoryCard(item: item));
        widgets.add(const SizedBox(height: 10));
      }

      widgets.add(const SizedBox(height: 8));
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final sections = _grouped;

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────
          _buildHeader(context),

          const SizedBox(height: 6),

          // ── Subtitle ─────────────────────────────────────────
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Semua transaksi yang telah diproses',
              style: TextStyle(
                color: _muted,
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),

          const SizedBox(height: 18),

          // ── Filter section ────────────────────────────────────
          _buildFilterSection(),

          const SizedBox(height: 20),

          // ── List ──────────────────────────────────────────────
          Expanded(
            child: sections.isEmpty
                ? _buildEmptyState()
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    physics: const BouncingScrollPhysics(),
                    children: _buildSections(),
                  ),
          ),
        ],
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          // Hamburger
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).push(
                PageRouteBuilder(
                  opaque: false,
                  barrierColor: Colors.transparent,
                  pageBuilder: (_, _, _) => const HistorySidebar(),
                  transitionDuration: const Duration(milliseconds: 300),
                ),
              );
            },
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: _border, width: 1),
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _MenuLine(width: 16),
                  const SizedBox(height: 4),
                  _MenuLine(width: 12),
                  const SizedBox(height: 4),
                  _MenuLine(width: 16),
                ],
              ),
            ),
          ),

          // Judul tengah
          const Expanded(
            child: Text(
              'Riwayat Booking',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _gold,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
            ),
          ),

          // Ikon lonceng
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, a, b) =>
                      const UnifiedNotificationScreen(),
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
            },
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: _border, width: 1),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.notifications_outlined,
                color: _muted,
                size: 19,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Filter section ────────────────────────────────────────────────────────────
  Widget _buildFilterSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Dropdown bulan
          GestureDetector(
            onTap: () => _showMonthPicker(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: _border, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_today_rounded,
                      color: _muted, size: 13),
                  const SizedBox(width: 7),
                  Text(
                    _selectedMonth,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.keyboard_arrow_down_rounded,
                      color: _muted, size: 16),
                ],
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Divider vertikal
          Container(width: 1, height: 28, color: _border),

          const SizedBox(width: 12),

          // Filter status pills (scrollable)
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _StatusPill(
                    label: 'Semua',
                    isActive: _activeFilter == _HistoryFilter.semua,
                    onTap: () =>
                        setState(() => _activeFilter = _HistoryFilter.semua),
                  ),
                  const SizedBox(width: 8),
                  _StatusPill(
                    label: 'Selesai',
                    isActive: _activeFilter == _HistoryFilter.selesai,
                    onTap: () =>
                        setState(() => _activeFilter = _HistoryFilter.selesai),
                  ),
                  const SizedBox(width: 8),
                  _StatusPill(
                    label: 'Ditolak',
                    isActive: _activeFilter == _HistoryFilter.ditolak,
                    onTap: () =>
                        setState(() => _activeFilter = _HistoryFilter.ditolak),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Month picker bottom sheet ─────────────────────────────────────────────────
  void _showMonthPicker(BuildContext context) {
    const months = [
      'Jan 2026', 'Feb 2026', 'Mar 2026', 'Apr 2026',
      'Mei 2026', 'Jun 2026',
    ];
    showModalBottomSheet(
      context: context,
      backgroundColor: _card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF3A3A3C),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 18),
            const Text('Pilih Bulan',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: months.map((m) {
                final isSelected = m == _selectedMonth;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedMonth = m);
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? _gold : const Color(0xFF2C2C2E),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      m,
                      style: TextStyle(
                        color: isSelected ? Colors.black : _muted,
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // ── Empty state ───────────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.history_rounded,
              color: Color(0xFF3A3A3C), size: 56),
          const SizedBox(height: 14),
          Text(
            _activeFilter == _HistoryFilter.ditolak
                ? 'Tidak ada transaksi ditolak'
                : _activeFilter == _HistoryFilter.selesai
                    ? 'Tidak ada transaksi selesai'
                    : 'Belum ada riwayat booking',
            style: const TextStyle(
              color: Color(0xFF555555),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// WIDGET: GARIS HAMBURGER
// ═══════════════════════════════════════════════════════════════════════════════

class _MenuLine extends StatelessWidget {
  final double width;
  const _MenuLine({required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 2,
      decoration: BoxDecoration(
        color: const Color(0xFF8E8E93),
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// WIDGET: PILL FILTER STATUS
// ═══════════════════════════════════════════════════════════════════════════════

class _StatusPill extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _StatusPill({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFFFC107) : const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isActive ? const Color(0xFFFFC107) : const Color(0xFF2C2C2E),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.black : const Color(0xFF8E8E93),
            fontSize: 13,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// WIDGET: HISTORY CARD
// ═══════════════════════════════════════════════════════════════════════════════

class _HistoryCard extends StatelessWidget {
  final _BookingHistory item;

  const _HistoryCard({required this.item});

  static const _gold = Color(0xFFFFC107);
  static const _card = Color(0xFF1C1C1E);
  static const _border = Color(0xFF2C2C2E);
  static const _muted = Color(0xFF8E8E93);

  bool get _isSelesai => item.status == _HistoryStatus.selesai;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isSelesai ? const Color(0xFF2C2C2E) : const Color(0xFF2C2C2E),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          children: [
            // ── Garis kuning kiri (hanya SELESAI) ───────────────
            if (_isSelesai)
              Container(
                width: 4,
                decoration: const BoxDecoration(
                  color: _gold,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                ),
              ),

            // ── Konten card ──────────────────────────────────────
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  _isSelesai ? 14 : 18,
                  16,
                  16,
                  16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Baris atas: avatar + info + badge
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Avatar
                        _Avatar(
                          initials: item.initials,
                          hasAvatar: item.hasAvatar,
                          isSelesai: _isSelesai,
                        ),
                        const SizedBox(width: 14),

                        // Nama + layanan
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.customerName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.serviceName,
                                style: const TextStyle(
                                  color: _muted,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 10),

                        // Badge status
                        _StatusBadge(status: item.status),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Divider
                    Container(height: 1, color: _border),

                    const SizedBox(height: 14),

                    // Baris bawah: waktu + harga
                    Row(
                      children: [
                        // Waktu
                        Row(
                          children: [
                            const Icon(Icons.access_time_rounded,
                                color: _muted, size: 14),
                            const SizedBox(width: 6),
                            Text(
                              item.timeRange,
                              style: const TextStyle(
                                color: _muted,
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),

                        const Spacer(),

                        // Harga
                        _PriceText(
                          price: item.price,
                          isDitolak: item.status == _HistoryStatus.ditolak,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Avatar ────────────────────────────────────────────────────────────────────
class _Avatar extends StatelessWidget {
  final String initials;
  final bool hasAvatar;
  final bool isSelesai;

  const _Avatar({
    required this.initials,
    required this.hasAvatar,
    required this.isSelesai,
  });

  static const _gold = Color(0xFFFFC107);

  @override
  Widget build(BuildContext context) {
    if (hasAvatar) {
      // Simulasi avatar dengan gradient seperti foto profil
      return Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isSelesai
                ? [
                    _gold.withOpacity(0.8),
                    _gold.withOpacity(0.4),
                  ]
                : [
                    const Color(0xFF3A3A3C),
                    const Color(0xFF2C2C2E),
                  ],
          ),
          border: Border.all(
            color: isSelesai
                ? _gold.withOpacity(0.3)
                : const Color(0xFF3A3A3C),
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          initials,
          style: TextStyle(
            color: isSelesai ? Colors.black : Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 15,
          ),
        ),
      );
    }

    // Inisial saja
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF2C2C2E),
        border: Border.all(color: const Color(0xFF3A3A3C), width: 1),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
          color: Color(0xFF8E8E93),
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
    );
  }
}

// ── Badge status ──────────────────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final _HistoryStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final isSelesai = status == _HistoryStatus.selesai;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isSelesai
            ? const Color(0xFF2C2C2E)
            : const Color(0xFF2A0A0A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelesai
              ? const Color(0xFF3A3A3C)
              : const Color(0xFF5A1A1A),
          width: 1,
        ),
      ),
      child: Text(
        isSelesai ? 'SELESAI' : 'DITOLAK',
        style: TextStyle(
          color: isSelesai
              ? const Color(0xFF8E8E93)
              : const Color(0xFFFF453A),
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ── Harga dengan efek coret ───────────────────────────────────────────────────
class _PriceText extends StatelessWidget {
  final String price;
  final bool isDitolak;

  const _PriceText({required this.price, required this.isDitolak});

  @override
  Widget build(BuildContext context) {
    if (isDitolak) {
      return Text(
        price,
        style: const TextStyle(
          color: Color(0xFF555555),
          fontSize: 15,
          fontWeight: FontWeight.w700,
          decoration: TextDecoration.lineThrough,
          decorationColor: Color(0xFF555555),
          decorationThickness: 2,
        ),
      );
    }
    return Text(
      price,
      style: const TextStyle(
        color: Color(0xFFFFC107),
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}