import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:barber_app/core/models/unified_notification_model.dart';
import 'package:barber_app/features/barber/widgets/notification/unified_filter_bar.dart';
import 'package:barber_app/features/barber/widgets/notification/unified_notification_card.dart';
import 'package:barber_app/features/barber/widgets/notification/unified_widgets.dart';

class UnifiedNotificationScreen extends StatefulWidget {
  const UnifiedNotificationScreen({super.key});

  @override
  State<UnifiedNotificationScreen> createState() =>
      _UnifiedNotificationScreenState();
}

class _UnifiedNotificationScreenState extends State<UnifiedNotificationScreen> {
  static const _gold = Color(0xFFFFC107);
  static const _bg = Color(0xFF0D0D0D);
  static const _card = Color(0xFF1C1C1E);
  static const _border = Color(0xFF2C2C2E);
  static const _muted = Color(0xFF8E8E93);

  UnifiedNotifFilter _filter = UnifiedNotifFilter.semua;
  String _searchQuery = '';

  final List<UnifiedNotificationModel> _notifs = List.from(
    dummyUnifiedNotifications,
  );

  int get _unreadCount => _notifs.where((n) => n.isUnread).length;

  List<UnifiedNotificationModel> get _filtered => _notifs.where((n) {
    final matchFilter = n.matchesFilter(_filter);
    final q = _searchQuery.toLowerCase();
    final matchSearch =
        q.isEmpty ||
        n.title.toLowerCase().contains(q) ||
        n.description.toLowerCase().contains(q);
    return matchFilter && matchSearch;
  }).toList();

  Map<NotifSectionGroup, List<UnifiedNotificationModel>> get _grouped {
    final map = <NotifSectionGroup, List<UnifiedNotificationModel>>{};
    for (final n in _filtered) {
      map.putIfAbsent(n.sectionGroup, () => []).add(n);
    }
    return map;
  }

  static const _sectionOrder = [
    NotifSectionGroup.hariIni,
    NotifSectionGroup.kemarin,
    NotifSectionGroup.mingguIni,
  ];

  String _sectionLabel(NotifSectionGroup g) {
    switch (g) {
      case NotifSectionGroup.hariIni:
        return 'HARI INI';
      case NotifSectionGroup.kemarin:
        return 'KEMARIN';
      case NotifSectionGroup.mingguIni:
        return 'MINGGU INI';
    }
  }

  void _markRead(String id) {
    final idx = _notifs.indexWhere((n) => n.id == id);
    if (idx != -1 && _notifs[idx].isUnread) {
      setState(() => _notifs[idx].isRead = true);
      HapticFeedback.lightImpact();
    }
  }

  void _markAllRead() {
    setState(() {
      for (final n in _notifs) {
        n.isRead = true;
      }
    });
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _grouped;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            const Divider(color: Color(0xFF1A1A1A), height: 1),

            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // ── Search ──────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: UnifiedSearchBar(
                        onChanged: (q) => setState(() => _searchQuery = q),
                      ),
                    ),
                  ),

                  // ── Summary cards ────────────────────────────────
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16, 14, 16, 0),
                      child: UnifiedSummaryCards(
                        bookingHariIni: bookingHariIni,
                        pembayaranMasuk: pembayaranMasuk,
                      ),
                    ),
                  ),

                  // ── Filter bar ────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                      child: UnifiedFilterBar(
                        activeFilter: _filter,
                        onChanged: (f) => setState(() => _filter = f),
                      ),
                    ),
                  ),

                  // ── Empty state ───────────────────────────────────
                  if (grouped.isEmpty)
                    SliverFillRemaining(child: _buildEmpty())
                  else
                    // ── Grouped list ────────────────────────────────
                    ..._sectionOrder
                        .where((g) => grouped.containsKey(g))
                        .expand(
                          (g) => [
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  20,
                                  16,
                                  10,
                                ),
                                child: Text(
                                  _sectionLabel(g),
                                  style: const TextStyle(
                                    color: _muted,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                            ),
                            SliverPadding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate((ctx, i) {
                                  final n = grouped[g]![i];
                                  return UnifiedNotificationCard(
                                    key: ValueKey(n.id),
                                    notif: n,
                                    onTap: () => _markRead(n.id),
                                  );
                                }, childCount: grouped[g]!.length),
                              ),
                            ),
                          ],
                        ),

                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button
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
          const SizedBox(width: 12),

          // Title + subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Notifikasi',
                      style: TextStyle(
                        color: _gold,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    if (_unreadCount > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF453A),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF453A).withOpacity(0.35),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '$_unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                const Text(
                  'Aktivitas penting terkait operasional barbershop',
                  style: TextStyle(color: _muted, fontSize: 12, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Icon buttons
          Row(
            children: [
              if (_unreadCount > 0) ...[
                _HeaderIconBtn(
                  icon: Icons.done_all_rounded,
                  onTap: _markAllRead,
                ),
                const SizedBox(width: 8),
              ],
              _HeaderIconBtn(
                icon: Icons.tune_rounded,
                onTap: () => HapticFeedback.lightImpact(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    String msg;
    if (_searchQuery.isNotEmpty) {
      msg = 'Tidak ditemukan untuk\n"$_searchQuery"';
    } else if (_filter != UnifiedNotifFilter.semua) {
      msg = 'Tidak ada notifikasi\nuntuk filter ini';
    } else {
      msg = 'Belum ada notifikasi';
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.notifications_off_outlined,
            color: Color(0xFF333333),
            size: 52,
          ),
          const SizedBox(height: 14),
          Text(
            msg,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF555555),
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Header icon button ─────────────────────────────────────────────────────────
class _HeaderIconBtn extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _HeaderIconBtn({required this.icon, required this.onTap});

  @override
  State<_HeaderIconBtn> createState() => _HeaderIconBtnState();
}

class _HeaderIconBtnState extends State<_HeaderIconBtn> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: 38,
        height: 38,
        transform: Matrix4.identity()..scale(_pressed ? 0.92 : 1.0),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: _pressed ? const Color(0xFF252525) : const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2C2C2E)),
        ),
        alignment: Alignment.center,
        child: Icon(widget.icon, color: const Color(0xFF8E8E93), size: 17),
      ),
    );
  }
}
