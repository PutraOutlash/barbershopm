import 'package:flutter/material.dart';
import 'package:barber_app/core/models/unified_notification_model.dart';

class UnifiedNotificationCard extends StatelessWidget {
  final UnifiedNotificationModel notif;
  final VoidCallback onTap;

  const UnifiedNotificationCard({
    super.key,
    required this.notif,
    required this.onTap,
  });

  static const _gold       = Color(0xFFFFC107);
  static const _cardRead   = Color(0xFF1C1C1E);
  static const _cardUnread = Color(0xFF1F1D14);

  @override
  Widget build(BuildContext context) {
    final isUnread = notif.isUnread;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUnread ? _cardUnread : _cardRead,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isUnread
                ? _gold.withOpacity(0.22)
                : const Color(0xFF2C2C2E),
            width: 1,
          ),
          boxShadow: isUnread
              ? [
                  BoxShadow(
                    color: _gold.withOpacity(0.05),
                    blurRadius: 12,
                  ),
                ]
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Icon container ───────────────────────────────────
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: isUnread ? notif.iconBg : const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Icon(
                notif.icon,
                color: isUnread ? notif.iconColor : const Color(0xFF666666),
                size: 21,
              ),
            ),
            const SizedBox(width: 14),

            // ── Konten ──────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Baris judul + badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          notif.title,
                          style: TextStyle(
                            color: isUnread
                                ? Colors.white
                                : const Color(0xFF888888),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            height: 1.3,
                          ),
                        ),
                      ),
                      if (notif.badge != null) ...[
                        const SizedBox(width: 8),
                        _BadgeChip(notif: notif),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Deskripsi (dengan optional highlight)
                  notif.highlightText != null
                      ? _HighlightText(
                          text:      notif.description,
                          highlight: notif.highlightText!,
                          isRead:    !isUnread,
                        )
                      : Text(
                          notif.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF888888),
                            fontSize: 12,
                            height: 1.55,
                          ),
                        ),
                  const SizedBox(height: 8),

                  // Waktu
                  Text(
                    notif.timeAgo,
                    style: TextStyle(
                      color: isUnread
                          ? _gold.withOpacity(0.80)
                          : const Color(0xFF555555),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // ── Unread dot ───────────────────────────────────────
            if (isUnread) ...[
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _gold,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _gold.withOpacity(0.5),
                        blurRadius: 4,
                      ),
                    ],
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

// ── Badge chip ────────────────────────────────────────────────────────────────
class _BadgeChip extends StatelessWidget {
  final UnifiedNotificationModel notif;
  const _BadgeChip({required this.notif});

  @override
  Widget build(BuildContext context) {
    final color  = notif.badgeColor ?? const Color(0xFF8E8E93);
    final bg     = notif.badgeBg    ?? const Color(0xFF2A2A2A);
    final border = notif.badgeBorder ?? const Color(0xFF3A3A3C);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: border, width: 1),
      ),
      child: Text(
        notif.badge!,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ── Highlight text ────────────────────────────────────────────────────────────
class _HighlightText extends StatelessWidget {
  final String text;
  final String highlight;
  final bool isRead;

  const _HighlightText({
    required this.text,
    required this.highlight,
    required this.isRead,
  });

  @override
  Widget build(BuildContext context) {
    final idx = text.indexOf(highlight);
    if (idx == -1) {
      return Text(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Color(0xFF888888), fontSize: 12, height: 1.55),
      );
    }

    return Text.rich(
      TextSpan(
        style: const TextStyle(fontSize: 12, height: 1.55),
        children: [
          TextSpan(
            text: text.substring(0, idx),
            style: const TextStyle(color: Color(0xFF888888)),
          ),
          TextSpan(
            text: highlight,
            style: TextStyle(
              color: isRead ? const Color(0xFF888888) : const Color(0xFFFFC107),
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(
            text: text.substring(idx + highlight.length),
            style: const TextStyle(color: Color(0xFF888888)),
          ),
        ],
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}
