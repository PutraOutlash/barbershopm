import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─── Model ────────────────────────────────────────────────────────────────────

class ServiceModel {
  final String id;
  final String name;
  final String description;
  final int price;
  final int durationMinutes;
  final String imageUrl;
  bool isActive;
  final DateTime updatedAt;

  ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.durationMinutes,
    required this.imageUrl,
    required this.isActive,
    required this.updatedAt,
  });
}

// ─── Dummy Data ───────────────────────────────────────────────────────────────

final List<ServiceModel> _dummyServices = [
  ServiceModel(
    id: 'SRV-001',
    name: 'Classic Fade',
    description:
        'Potongan rambut presisi dengan gradasi halus dari kulit kepala hingga rambut bagian atas.',
    price: 150000,
    durationMinutes: 45,
    imageUrl:
        'https://images.unsplash.com/photo-1599351431202-1e0f0137899a?w=600',
    isActive: true,
    updatedAt: DateTime(2026, 5, 8, 19, 30),
  ),
  ServiceModel(
    id: 'SRV-002',
    name: 'Premium Hot Towel Shave',
    description:
        'Cukur tradisional menggunakan handuk panas, krim cukur premium, dan pisau cukur lurus.',
    price: 120000,
    durationMinutes: 30,
    imageUrl:
        'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=600',
    isActive: false,
    updatedAt: DateTime(2026, 5, 1, 10, 15),
  ),
  ServiceModel(
    id: 'SRV-003',
    name: 'Hair Coloring',
    description:
        'Pewarnaan rambut profesional dengan bahan berkualitas tinggi dan tahan lama.',
    price: 250000,
    durationMinutes: 90,
    imageUrl:
        'https://images.unsplash.com/photo-1622286342621-4bd786c2447c?w=600',
    isActive: true,
    updatedAt: DateTime(2026, 5, 5, 14, 0),
  ),
  ServiceModel(
    id: 'SRV-004',
    name: 'Beard Treatment',
    description:
        'Perawatan jenggot lengkap mulai dari trimming, conditioning, hingga styling.',
    price: 85000,
    durationMinutes: 30,
    imageUrl:
        'https://images.unsplash.com/photo-1534297635766-a262cdcb8ee4?w=600',
    isActive: true,
    updatedAt: DateTime(2026, 5, 7, 11, 45),
  ),
  ServiceModel(
    id: 'SRV-005',
    name: 'Scalp Treatment',
    description:
        'Perawatan kulit kepala mendalam untuk mengurangi ketombe dan memperkuat akar rambut.',
    price: 175000,
    durationMinutes: 60,
    imageUrl: 'https://images.unsplash.com/photo-1560869713-7d0a29430803?w=600',
    isActive: false,
    updatedAt: DateTime(2026, 4, 28, 9, 0),
  ),
];

// ─── Page ─────────────────────────────────────────────────────────────────────

class ManageServicePage extends StatefulWidget {
  const ManageServicePage({super.key});

  @override
  State<ManageServicePage> createState() => _ManageServicePageState();
}

class _ManageServicePageState extends State<ManageServicePage>
    with TickerProviderStateMixin {
  // ─── Colors ──────────────────────────────────────────────────────────────
  static const _bg = Color(0xFF0D0D0D);
  static const _card = Color(0xFF1C1C1E);
  static const _border = Color(0xFF2C2C2E);
  static const _gold = Color(0xFFFFC107);
  static const _muted = Color(0xFF8E8E93);
  static const _green = Color(0xFF32D583);
  static const _red = Color(0xFFFF453A);

  // ─── State ───────────────────────────────────────────────────────────────
  late List<ServiceModel> _services;
  String _search = '';
  int _filterIndex = 0; // 0=Semua, 1=Aktif, 2=Nonaktif
  final _searchCtrl = TextEditingController();
  late AnimationController _fabAnim;

  @override
  void initState() {
    super.initState();
    _services = List.from(_dummyServices);
    _fabAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _fabAnim.dispose();
    super.dispose();
  }

  // ─── Computed ─────────────────────────────────────────────────────────────
  List<ServiceModel> get _filtered {
    return _services.where((s) {
      final matchSearch =
          s.name.toLowerCase().contains(_search.toLowerCase()) ||
          s.description.toLowerCase().contains(_search.toLowerCase());
      final matchFilter = _filterIndex == 0
          ? true
          : _filterIndex == 1
          ? s.isActive
          : !s.isActive;
      return matchSearch && matchFilter;
    }).toList();
  }

  int get _totalActive => _services.where((s) => s.isActive).length;
  int get _totalInactive => _services.where((s) => !s.isActive).length;

  // ─── Helpers ──────────────────────────────────────────────────────────────
  String _formatPrice(int price) {
    final str = price.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
    }
    return 'Rp ${buffer.toString()}';
  }

  String _formatDate(DateTime dt) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.day.toString().padLeft(2, '0')} ${months[dt.month]} ${dt.year}, $h:$m';
  }

  // ─── Actions ──────────────────────────────────────────────────────────────
  void _toggleActive(ServiceModel svc) {
    HapticFeedback.lightImpact();
    setState(() => svc.isActive = !svc.isActive);
  }

  Future<void> _confirmDelete(ServiceModel svc) async {
    HapticFeedback.mediumImpact();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => _DeleteDialog(name: svc.name),
    );
    if (ok == true) {
      setState(() => _services.remove(svc));
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.black)),
        backgroundColor: _gold,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Sticky Header ──
              SliverAppBar(
                pinned: true,
                backgroundColor: _bg,
                elevation: 0,
                leading: IconButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                title: const Text(
                  'Kelola Layanan',
                  style: TextStyle(
                    color: _gold,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                centerTitle: true,
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(1),
                  child: Container(height: 1, color: _border),
                ),
              ),

              // ── Body ──
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 120),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Description
                    _buildDescription(),
                    const SizedBox(height: 24),

                    // Stats
                    _buildStatsRow(),
                    const SizedBox(height: 24),

                    // Search
                    _buildSearchBar(),
                    const SizedBox(height: 16),

                    // Filter
                    _buildFilterBar(),
                    const SizedBox(height: 24),

                    // List
                    if (filtered.isEmpty)
                      _buildEmptyState()
                    else
                      ...filtered.asMap().entries.map((e) {
                        return _ServiceCard(
                          key: ValueKey(e.value.id),
                          service: e.value,
                          index: e.key,
                          formatPrice: _formatPrice,
                          formatDate: _formatDate,
                          onToggle: () => _toggleActive(e.value),
                          onDelete: () => _confirmDelete(e.value),
                          onView: () => _showSnack('Lihat: ${e.value.name}'),
                          onEdit: () => _showSnack('Edit: ${e.value.name}'),
                        );
                      }),
                  ]),
                ),
              ),
            ],
          ),

          // ── FAB ──
          _buildFAB(),
        ],
      ),
    );
  }

  // ─── Section Builders ─────────────────────────────────────────────────────

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kelola Layanan',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Kelola layanan barber dan status layanan yang tersedia untuk pelanggan.',
          style: TextStyle(color: _muted, fontSize: 13.5, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _StatCard(
            icon: Icons.content_cut_rounded,
            label: 'Total Layanan',
            value: _services.length.toString(),
            iconColor: _gold,
            glowColor: _gold,
          ),
          const SizedBox(width: 12),
          _StatCard(
            icon: Icons.check_circle_outline_rounded,
            label: 'Layanan Aktif',
            value: _totalActive.toString(),
            iconColor: _green,
            glowColor: _green,
          ),
          const SizedBox(width: 12),
          _StatCard(
            icon: Icons.cancel_outlined,
            label: 'Layanan Nonaktif',
            value: _totalInactive.toString(),
            iconColor: _red,
            glowColor: _red,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: _border, width: 1),
      ),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (v) => setState(() => _search = v),
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Cari layanan...',
          hintStyle: const TextStyle(color: _muted, fontSize: 14),
          prefixIcon: const Icon(Icons.search_rounded, color: _muted, size: 20),
          suffixIcon: _search.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchCtrl.clear();
                    setState(() => _search = '');
                  },
                  icon: const Icon(
                    Icons.close_rounded,
                    color: _muted,
                    size: 18,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    final labels = ['Semua', 'Aktif', 'Nonaktif'];
    return Row(
      children: labels.asMap().entries.map((e) {
        final active = _filterIndex == e.key;
        return Padding(
          padding: EdgeInsets.only(right: e.key < labels.length - 1 ? 8 : 0),
          child: GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _filterIndex = e.key);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
              decoration: BoxDecoration(
                color: active ? _gold : _card,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: active ? _gold : _border, width: 1),
              ),
              child: Text(
                e.value,
                style: TextStyle(
                  color: active ? Colors.black : _muted,
                  fontSize: 13,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.content_cut_rounded, color: _muted, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Tidak ada layanan ditemukan',
              style: TextStyle(color: _muted, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return Positioned(
      bottom: 24,
      left: 0,
      right: 0,
      child: Center(
        child: ScaleTransition(
          scale: CurvedAnimation(parent: _fabAnim, curve: Curves.elasticOut),
          child: GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              _showSnack('Tambah Layanan baru');
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              decoration: BoxDecoration(
                color: _gold,
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: _gold.withOpacity(0.40),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_rounded, color: Colors.black, size: 20),
                  SizedBox(width: 6),
                  Text(
                    'Tambah Layanan',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Stat Card ────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;
  final Color glowColor;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
    required this.glowColor,
  });

  static const _card = Color(0xFF1C1C1E);
  static const _border = Color(0xFF2C2C2E);
  static const _muted = Color(0xFF8E8E93);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border, width: 1),
        boxShadow: [
          BoxShadow(
            color: glowColor.withOpacity(0.08),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: glowColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              color: _muted,
              fontSize: 10,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: iconColor,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Service Card ─────────────────────────────────────────────────────────────

class _ServiceCard extends StatefulWidget {
  final ServiceModel service;
  final int index;
  final String Function(int) formatPrice;
  final String Function(DateTime) formatDate;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onView;
  final VoidCallback onEdit;

  const _ServiceCard({
    super.key,
    required this.service,
    required this.index,
    required this.formatPrice,
    required this.formatDate,
    required this.onToggle,
    required this.onDelete,
    required this.onView,
    required this.onEdit,
  });

  @override
  State<_ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<_ServiceCard>
    with SingleTickerProviderStateMixin {
  static const _bg = Color(0xFF0D0D0D);
  static const _card = Color(0xFF1C1C1E);
  static const _border = Color(0xFF2C2C2E);
  static const _gold = Color(0xFFFFC107);
  static const _muted = Color(0xFF8E8E93);
  static const _green = Color(0xFF32D583);
  static const _red = Color(0xFFFF453A);

  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400 + widget.index * 80),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    Future.delayed(Duration(milliseconds: widget.index * 60), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final svc = widget.service;
    final borderColor = svc.isActive ? _gold.withOpacity(0.5) : _border;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: borderColor, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: (svc.isActive ? _gold : Colors.black).withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.hardEdge,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Image ──
              Stack(
                children: [
                  SizedBox(
                    height: 180,
                    width: double.infinity,
                    child: Image.network(
                      svc.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        color: const Color(0xFF1A1A1A),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.content_cut_rounded,
                          color: Color(0xFF3A3A3A),
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                  // ID Badge
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.70),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.15),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '#${svc.id}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  // Gradient overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, _card.withOpacity(0.95)],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // ── Content ──
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status + Actions row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Status badge
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: _StatusBadge(
                            key: ValueKey(svc.isActive),
                            isActive: svc.isActive,
                          ),
                        ),
                        const Spacer(),
                        // Action buttons
                        _ActionBtn(
                          icon: Icons.remove_red_eye_outlined,
                          onTap: widget.onView,
                        ),
                        const SizedBox(width: 8),
                        _ActionBtn(
                          icon: Icons.edit_outlined,
                          onTap: widget.onEdit,
                        ),
                        const SizedBox(width: 8),
                        _ActionBtn(
                          icon: svc.isActive
                              ? Icons.toggle_on_rounded
                              : Icons.toggle_off_rounded,
                          iconColor: svc.isActive ? _green : _muted,
                          onTap: widget.onToggle,
                        ),
                        const SizedBox(width: 8),
                        _ActionBtn(
                          icon: Icons.delete_outline_rounded,
                          iconColor: _red,
                          onTap: widget.onDelete,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Name
                    Text(
                      svc.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Description
                    Text(
                      svc.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _muted,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Price + Duration
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          widget.formatPrice(svc.price),
                          style: const TextStyle(
                            color: _gold,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Icon(
                          Icons.timer_outlined,
                          color: _muted,
                          size: 15,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${svc.durationMinutes} Menit',
                          style: const TextStyle(
                            color: _muted,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Updated at
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          color: Color(0xFF55555A),
                          size: 13,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Terakhir diperbarui: ${widget.formatDate(svc.updatedAt)}',
                          style: const TextStyle(
                            color: Color(0xFF55555A),
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Status Badge ─────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final bool isActive;
  const _StatusBadge({super.key, required this.isActive});

  static const _green = Color(0xFF32D583);
  static const _red = Color(0xFFFF453A);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (isActive ? _green : _red).withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: (isActive ? _green : _red).withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Text(
        isActive ? 'AKTIF' : 'NONAKTIF',
        style: TextStyle(
          color: isActive ? _green : _red,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// ─── Action Button ────────────────────────────────────────────────────────────

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final VoidCallback onTap;

  const _ActionBtn({required this.icon, this.iconColor, required this.onTap});

  static const _border = Color(0xFF2C2C2E);
  static const _muted = Color(0xFF8E8E93);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: const Color(0xFF252527),
          shape: BoxShape.circle,
          border: Border.all(color: _border, width: 1),
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: iconColor ?? _muted, size: 16),
      ),
    );
  }
}

// ─── Delete Dialog ────────────────────────────────────────────────────────────

class _DeleteDialog extends StatelessWidget {
  final String name;
  const _DeleteDialog({required this.name});

  static const _bg = Color(0xFF1C1C1E);
  static const _gold = Color(0xFFFFC107);
  static const _red = Color(0xFFFF453A);
  static const _muted = Color(0xFF8E8E93);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: _bg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: _red.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.delete_outline_rounded,
                color: _red,
                size: 26,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Hapus Layanan',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Apakah kamu yakin ingin menghapus "$name"? Tindakan ini tidak dapat dibatalkan.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: _muted, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF2C2C2E)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    child: const Text(
                      'Batal',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    child: const Text(
                      'Hapus',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
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
  }
}
