import 'package:barber_app/core/models/notification_model.dart';
import 'package:flutter/material.dart';

class NotificationItem extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const NotificationItem({
    super.key,
    required this.notification,
    required this.onTap,
  });

  static const _gold = Color(0xFFF2B705);
  static const _cardRead = Color(0xFF1A1A1A);
  static const _cardUnread = Color(0xFF1F1D14);

  _IconConfig get _iconConfig {
    switch (notification.type) {
      case NotificationType.booking:
        return _IconConfig(
          icon: Icons.calendar_today_rounded,
          bg: notification.isRead
              ? const Color(0xFF2A2A2A)
              : const Color(0xFF2E2500),
          iconColor: notification.isRead ? const Color(0xFF666666) : _gold,
        );
      case NotificationType.promo:
        return _IconConfig(
          icon: Icons.local_offer_rounded,
          bg: notification.isRead
              ? const Color(0xFF2A2A2A)
              : const Color(0xFF2E2500),
          iconColor: notification.isRead ? const Color(0xFF666666) : _gold,
        );
      case NotificationType.payment:
        return _IconConfig(
          icon: Icons.check_circle_outline_rounded,
          bg: const Color(0xFF2A2A2A),
          iconColor: const Color(0xFF666666),
        );
      case NotificationType.reminder:
        return _IconConfig(
          icon: Icons.access_time_rounded,
          bg: const Color(0xFF2A2A2A),
          iconColor: const Color(0xFF666666),
        );
      case NotificationType.loyalty:
        return _IconConfig(
          icon: Icons.star_outline_rounded,
          bg: const Color(0xFF2A2A2A),
          iconColor: const Color(0xFF666666),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cfg = _iconConfig;
    final isUnread = notification.isUnread;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUnread ? _cardUnread : _cardRead,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isUnread
                ? _gold.withOpacity(0.20)
                : const Color(0xFF252525),
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: cfg.bg,
                borderRadius: BorderRadius.circular(13),
              ),
              alignment: Alignment.center,
              child: Icon(cfg.icon, color: cfg.iconColor, size: 20),
            ),
            const SizedBox(width: 14),

            // Teks
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(
                      color:
                          isUnread ? Colors.white : const Color(0xFF888888),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    notification.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF888888),
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    notification.timeAgo,
                    style: TextStyle(
                      color: isUnread
                          ? _gold.withOpacity(0.85)
                          : const Color(0xFF555555),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Dot unread
            if (isUnread) ...[
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: _gold,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _IconConfig {
  final IconData icon;
  final Color bg;
  final Color iconColor;
  const _IconConfig({
    required this.icon,
    required this.bg,
    required this.iconColor,
  });
}
