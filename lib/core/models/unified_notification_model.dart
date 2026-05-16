import 'package:flutter/material.dart';

// ── Enum tipe notifikasi terpadu ──────────────────────────────────────────────
enum UnifiedNotifType {
  booking,
  pembayaran,
  promo,
  sistem,
  warning,
  pendapatan,
  updateLayanan,
  reminder,
}

// ── Enum filter ───────────────────────────────────────────────────────────────
enum UnifiedNotifFilter {
  semua,
  belumDibaca,
  booking,
  pembayaran,
  sistem,
  promo,
}

// ── Enum section group ────────────────────────────────────────────────────────
enum NotifSectionGroup { hariIni, kemarin, mingguIni }

// ── Model terpadu ─────────────────────────────────────────────────────────────
class UnifiedNotificationModel {
  final String id;
  final UnifiedNotifType type;
  final String title;
  final String description;
  final String timeAgo;
  bool isRead;
  final String? badge;          // 'DITOLAK' | 'UPDATE' | 'PROMO' | 'BERHASIL' | 'PERINGATAN'
  final String? highlightText;  // teks dalam desc yang di-gold
  final DateTime createdAt;
  final NotifSectionGroup sectionGroup;

  UnifiedNotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.timeAgo,
    this.isRead = false,
    this.badge,
    this.highlightText,
    required this.createdAt,
    required this.sectionGroup,
  });

  bool get isUnread => !isRead;

  // ── Konfigurasi visual per tipe ──────────────────────────────────────────────
  IconData get icon {
    switch (type) {
      case UnifiedNotifType.booking:       return Icons.calendar_today_rounded;
      case UnifiedNotifType.pembayaran:    return Icons.check_circle_outline_rounded;
      case UnifiedNotifType.promo:         return Icons.local_offer_rounded;
      case UnifiedNotifType.sistem:        return Icons.error_outline_rounded;
      case UnifiedNotifType.warning:       return Icons.warning_amber_rounded;
      case UnifiedNotifType.pendapatan:    return Icons.payments_outlined;
      case UnifiedNotifType.updateLayanan: return Icons.local_offer_outlined;
      case UnifiedNotifType.reminder:      return Icons.access_time_rounded;
    }
  }

  Color get iconColor {
    switch (type) {
      case UnifiedNotifType.warning:       return const Color(0xFFFF453A);
      case UnifiedNotifType.pembayaran:    return const Color(0xFF4CD964);
      case UnifiedNotifType.pendapatan:    return const Color(0xFF4CD964);
      case UnifiedNotifType.promo:         return const Color(0xFFFFC107);
      case UnifiedNotifType.updateLayanan: return const Color(0xFFFFC107);
      case UnifiedNotifType.sistem:        return const Color(0xFFFFC107);
      case UnifiedNotifType.booking:
        return isUnread ? const Color(0xFFFFC107) : const Color(0xFF666666);
      case UnifiedNotifType.reminder:      return const Color(0xFF8E8E93);
    }
  }

  Color get iconBg {
    switch (type) {
      case UnifiedNotifType.warning:       return const Color(0xFF2A0A0A);
      case UnifiedNotifType.pembayaran:    return const Color(0xFF0A2A0A);
      case UnifiedNotifType.pendapatan:    return const Color(0xFF0A2A0A);
      case UnifiedNotifType.promo:         return const Color(0xFF2A2000);
      case UnifiedNotifType.updateLayanan: return const Color(0xFF2A2000);
      case UnifiedNotifType.sistem:        return const Color(0xFF2A2000);
      case UnifiedNotifType.booking:
        return isUnread ? const Color(0xFF2A2000) : const Color(0xFF2A2A2A);
      case UnifiedNotifType.reminder:      return const Color(0xFF2A2A2A);
    }
  }

  // ── Badge color ───────────────────────────────────────────────────────────────
  Color? get badgeColor {
    switch (badge) {
      case 'DITOLAK':    return const Color(0xFFFF453A);
      case 'PERINGATAN': return const Color(0xFFFF453A);
      case 'BERHASIL':   return const Color(0xFF4CD964);
      case 'PROMO':      return const Color(0xFFFFC107);
      case 'UPDATE':     return const Color(0xFFFFC107);
      default:           return null;
    }
  }

  Color? get badgeBg {
    switch (badge) {
      case 'DITOLAK':
      case 'PERINGATAN': return const Color(0xFF2A0A0A);
      case 'BERHASIL':   return const Color(0xFF0A2A0A);
      case 'PROMO':
      case 'UPDATE':     return const Color(0xFF2A2000);
      default:           return null;
    }
  }

  Color? get badgeBorder {
    switch (badge) {
      case 'DITOLAK':
      case 'PERINGATAN': return const Color(0xFF5A1A1A);
      case 'BERHASIL':   return const Color(0xFF1A5A1A);
      case 'PROMO':
      case 'UPDATE':     return const Color(0xFFFFC107).withOpacity(0.4);
      default:           return null;
    }
  }

  // ── Filter match ──────────────────────────────────────────────────────────────
  bool matchesFilter(UnifiedNotifFilter filter) {
    switch (filter) {
      case UnifiedNotifFilter.semua:      return true;
      case UnifiedNotifFilter.belumDibaca:return isUnread;
      case UnifiedNotifFilter.booking:    return type == UnifiedNotifType.booking || type == UnifiedNotifType.reminder;
      case UnifiedNotifFilter.pembayaran: return type == UnifiedNotifType.pembayaran || type == UnifiedNotifType.pendapatan;
      case UnifiedNotifFilter.sistem:     return type == UnifiedNotifType.sistem || type == UnifiedNotifType.warning || type == UnifiedNotifType.updateLayanan;
      case UnifiedNotifFilter.promo:      return type == UnifiedNotifType.promo;
    }
  }
}

// ── Dummy data gabungan ───────────────────────────────────────────────────────
final List<UnifiedNotificationModel> dummyUnifiedNotifications = [
  // ── HARI INI ──
  UnifiedNotificationModel(
    id: 'UN001',
    type: UnifiedNotifType.warning,
    title: 'Pesanan Dibatalkan Mendadak',
    description: 'Customer membatalkan jadwal pukul 14:00. Slot tersedia kembali.',
    timeAgo: '10 menit lalu',
    isRead: false,
    createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
    sectionGroup: NotifSectionGroup.hariIni,
  ),
  UnifiedNotificationModel(
    id: 'UN002',
    type: UnifiedNotifType.booking,
    title: 'Booking Baru Dikonfirmasi',
    description: 'Jadwal cukur Anda dengan Barber Alex pada 24 Okt, 14:00...',
    timeAgo: '10 menit lalu',
    isRead: false,
    createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
    sectionGroup: NotifSectionGroup.hariIni,
  ),
  UnifiedNotificationModel(
    id: 'UN003',
    type: UnifiedNotifType.sistem,
    title: 'Pesanan Ditolak Sistem',
    description: 'Booking dilakukan di luar jam operasional (08:00–22:00).',
    timeAgo: '1 jam lalu',
    badge: 'DITOLAK',
    createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    sectionGroup: NotifSectionGroup.hariIni,
  ),

  // ── KEMARIN ──
  UnifiedNotificationModel(
    id: 'UN004',
    type: UnifiedNotifType.pembayaran,
    title: 'Pembayaran Berhasil',
    description: 'Transaksi untuk layanan Classic Cut sebesar Rp 150.000 telah berhasil.',
    timeAgo: 'Kemarin, 15:30 WIB',
    badge: 'BERHASIL',
    createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 8)),
    sectionGroup: NotifSectionGroup.kemarin,
  ),
  UnifiedNotificationModel(
    id: 'UN005',
    type: UnifiedNotifType.pendapatan,
    title: 'Rekap Pendapatan Hari Ini',
    description: 'Total 12 transaksi selesai dengan omzet Rp 3.450.000',
    timeAgo: 'Kemarin, 18:00',
    highlightText: 'Rp 3.450.000',
    createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 6)),
    sectionGroup: NotifSectionGroup.kemarin,
  ),
  UnifiedNotificationModel(
    id: 'UN006',
    type: UnifiedNotifType.promo,
    title: 'Promo Eksklusif Member',
    description: 'Nikmati diskon 20% untuk semua layanan Premium...',
    timeAgo: 'Kemarin, 09:00',
    isRead: false,
    badge: 'PROMO',
    createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 15)),
    sectionGroup: NotifSectionGroup.kemarin,
  ),
  UnifiedNotificationModel(
    id: 'UN007',
    type: UnifiedNotifType.updateLayanan,
    title: 'Update Layanan & Harga',
    description: 'Harga Classic Fade diperbarui. Paket baru tersedia.',
    timeAgo: 'Kemarin, 08:30',
    badge: 'UPDATE',
    createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 15, minutes: 30)),
    sectionGroup: NotifSectionGroup.kemarin,
  ),

  // ── MINGGU INI ──
  UnifiedNotificationModel(
    id: 'UN008',
    type: UnifiedNotifType.reminder,
    title: 'Pengingat Jadwal',
    description: 'Halo, Anda memiliki jadwal cukur besok pukul 10:00 WIB. Jangan sampai terlewat!',
    timeAgo: '2 hari lalu',
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
    sectionGroup: NotifSectionGroup.mingguIni,
  ),
  UnifiedNotificationModel(
    id: 'UN009',
    type: UnifiedNotifType.booking,
    title: 'Pengingat Jadwal Customer',
    description: 'Raka Wijaya memiliki jadwal Hot Towel Shave besok pukul 11:00 WIB.',
    timeAgo: '2 hari lalu',
    createdAt: DateTime.now().subtract(const Duration(days: 2, hours: 2)),
    sectionGroup: NotifSectionGroup.mingguIni,
  ),
  UnifiedNotificationModel(
    id: 'UN010',
    type: UnifiedNotifType.pembayaran,
    title: 'Pembayaran Premium Masuk',
    description: 'Pembayaran Premium Hair Sculpting Rp 200.000 telah diterima.',
    timeAgo: '3 hari lalu',
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
    sectionGroup: NotifSectionGroup.mingguIni,
  ),
];

// ── Statistik harian ──────────────────────────────────────────────────────────
const int bookingHariIni   = 12;
const String pembayaranMasuk = 'Rp 3.4M';
