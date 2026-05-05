enum NotificationType { booking, promo, payment, reminder, loyalty }

enum NotificationFilter { semua, belumDibaca, promo }

class NotificationModel {
  final String id;
  final String title;
  final String description;
  final String timeAgo;
  final NotificationType type;
  bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.timeAgo,
    required this.type,
    this.isRead = false,
  });

  bool get isPromo => type == NotificationType.promo;
  bool get isUnread => !isRead;
}

// ── Dummy data ────────────────────────────────────────────────────────────────
final List<NotificationModel> dummyNotifications = [
  NotificationModel(
    id: '1',
    title: 'Booking Baru Dikonfirmasi',
    description: 'Jadwal cukur Anda dengan Barber Alex pada 24 Okt, 14:00...',
    timeAgo: '10 menit lalu',
    type: NotificationType.booking,
    isRead: false,
  ),
  NotificationModel(
    id: '2',
    title: 'Promo Eksklusif Member',
    description: 'Nikmati diskon 20% untuk semua layanan Premium...',
    timeAgo: '1 jam lalu',
    type: NotificationType.promo,
    isRead: false,
  ),
  NotificationModel(
    id: '3',
    title: 'Pembayaran Berhasil',
    description:
        'Transaksi untuk layanan Classic Cut sebesar Rp 150.000 telah berhasil...',
    timeAgo: 'Kemarin, 15:30 WIB',
    type: NotificationType.payment,
    isRead: true,
  ),
  NotificationModel(
    id: '4',
    title: 'Pengingat Jadwal',
    description:
        'Halo, Anda memiliki jadwal cukur besok pukul 10:00 WIB. Jangan...',
    timeAgo: '2 hari lalu',
    type: NotificationType.reminder,
    isRead: true,
  ),
  NotificationModel(
    id: '5',
    title: 'Poin Loyalty Bertambah',
    description:
        'Anda mendapatkan 50 poin dari kunjungan terakhir. Kumpulkan terus',
    timeAgo: '1 minggu lalu',
    type: NotificationType.loyalty,
    isRead: true,
  ),
];
