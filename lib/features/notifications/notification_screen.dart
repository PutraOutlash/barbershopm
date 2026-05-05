import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/notification_model.dart';
import 'widgets/notification_filter_bar.dart';
import 'widgets/notification_item.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  static const _gold = Color(0xFFF2B705);
  static const _bg = Color(0xFF0D0D0D);

  NotificationFilter _activeFilter = NotificationFilter.semua;

  // Salinan mutable dari dummy data
  final List<NotificationModel> _notifications = List.from(dummyNotifications);

  // ── Filter logic ────────────────────────────────────────────────────────────
  List<NotificationModel> get _filtered {
    switch (_activeFilter) {
      case NotificationFilter.semua:
        return _notifications;
      case NotificationFilter.belumDibaca:
        return _notifications.where((n) => n.isUnread).toList();
      case NotificationFilter.promo:
        return _notifications.where((n) => n.isPromo).toList();
    }
  }

  int get _unreadCount => _notifications.where((n) => n.isUnread).length;

  // ── Mark as read ────────────────────────────────────────────────────────────
  void _markAsRead(String id) {
    setState(() {
      final idx = _notifications.indexWhere((n) => n.id == id);
      if (idx != -1 && !_notifications[idx].isRead) {
        _notifications[idx].isRead = true;
        HapticFeedback.lightImpact();
      }
    });
  }

  // ── Mark all as read ─────────────────────────────────────────────────────────
  void _markAllRead() {
    setState(() {
      for (final n in _notifications) {
        n.isRead = true;
      }
    });
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: _Header(
                unreadCount: _unreadCount,
                onBack: () => Navigator.of(context).pop(),
                onMarkAll: _unreadCount > 0 ? _markAllRead : null,
              ),
            ),

            const SizedBox(height: 24),

            // ── Filter pills ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: NotificationFilterBar(
                activeFilter: _activeFilter,
                onFilterChanged: (f) => setState(() => _activeFilter = f),
              ),
            ),

            const SizedBox(height: 20),

            // ── List ─────────────────────────────────────────────
            Expanded(
              child: filtered.isEmpty
                  ? _EmptyState(filter: _activeFilter)
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      physics: const BouncingScrollPhysics(),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final notif = filtered[index];
                        return NotificationItem(
                          key: ValueKey(notif.id),
                          notification: notif,
                          onTap: () => _markAsRead(notif.id),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header widget ─────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final int unreadCount;
  final VoidCallback onBack;
  final VoidCallback? onMarkAll;

  const _Header({
    required this.unreadCount,
    required this.onBack,
    this.onMarkAll,
  });

  static const _gold = Color(0xFFF2B705);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Tombol kembali
            GestureDetector(
              onTap: onBack,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF2A2A2A), width: 1),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
            const Spacer(),

            // Tombol tandai semua dibaca
            if (onMarkAll != null)
              GestureDetector(
                onTap: onMarkAll,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: _gold.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: _gold.withOpacity(0.25), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.done_all_rounded,
                          color: _gold, size: 14),
                      const SizedBox(width: 5),
                      const Text(
                        'Baca Semua',
                        style: TextStyle(
                          color: _gold,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 20),

        // Judul + unread badge
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Notifikasi',
              style: TextStyle(
                color: _gold,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            if (unreadCount > 0) ...[
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: _gold,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$unreadCount baru',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Informasi penting untuk Anda',
          style: TextStyle(
            color: Color(0xFF666666),
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final NotificationFilter filter;
  const _EmptyState({required this.filter});

  String get _message {
    switch (filter) {
      case NotificationFilter.belumDibaca:
        return 'Semua notifikasi sudah dibaca';
      case NotificationFilter.promo:
        return 'Belum ada promo saat ini';
      case NotificationFilter.semua:
        return 'Belum ada notifikasi';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            color: const Color(0xFF333333),
            size: 56,
          ),
          const SizedBox(height: 14),
          Text(
            _message,
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
