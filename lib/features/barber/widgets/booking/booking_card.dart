import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:barber_app/core/models/booking_model.dart';

class BookingCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onChat;

  const BookingCard({
    super.key,
    required this.booking,
    this.onAccept,
    this.onReject,
    this.onChat,
  });

  static const _gold = Color(0xFFFFC107);
  static const _cardBg = Color(0xFF1C1C1E);
  static const _border = Color(0xFF2C2C2E);
  static const _muted = Color(0xFF8E8E93);

  @override
  Widget build(BuildContext context) {
    final isPending = booking.status == BookingStatus.pending;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Baris atas: nama + waktu ────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.customerName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        booking.serviceName,
                        style: const TextStyle(
                          color: _gold,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                _buildRightChips(),
              ],
            ),

            const SizedBox(height: 12),

            // ── Telepon ─────────────────────────────────────────
            Row(
              children: [
                const Icon(Icons.phone_outlined, color: _muted, size: 14),
                const SizedBox(width: 6),
                Text(
                  booking.phoneNumber,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),

            // ── Action buttons (hanya Pending) ──────────────────
            if (isPending) ...[
              const SizedBox(height: 16),
              const Divider(color: Color(0xFF2C2C2E), height: 1),
              const SizedBox(height: 14),
              _ActionRow(
                onAccept: () {
                  HapticFeedback.lightImpact();
                  onAccept?.call();
                },
                onReject: () {
                  HapticFeedback.lightImpact();
                  onReject?.call();
                },
                onChat: () {
                  HapticFeedback.lightImpact();
                  onChat?.call();
                },
              ),
            ],

            // ── Status label (bukan Pending) ────────────────────
            if (!isPending) ...[
              const SizedBox(height: 14),
              _StatusBadge(status: booking.status),
            ],
          ],
        ),
      ),
    );
  }

  // ── Chip waktu + badge bentrok ─────────────────────────────────────────────
  Widget _buildRightChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (booking.status == BookingStatus.pending ||
            booking.status == BookingStatus.diterima)
          _TimeChip(time: booking.scheduleTime)
        else
          const SizedBox.shrink(),
        if (booking.hasConflict) ...[
          const SizedBox(height: 6),
          _ConflictBadge(),
        ],
        if (booking.status == BookingStatus.diterima &&
            !booking.hasConflict)
          const SizedBox.shrink(),
      ],
    );
  }
}

// ── Chip waktu ────────────────────────────────────────────────────────────────
class _TimeChip extends StatelessWidget {
  final String time;
  const _TimeChip({required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.access_time_rounded,
              color: Color(0xFF8E8E93), size: 12),
          const SizedBox(width: 4),
          Text(
            time,
            style: const TextStyle(
              color: Color(0xFF8E8E93),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Badge bentrok ─────────────────────────────────────────────────────────────
class _ConflictBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF2A0A0A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF5A1A1A), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.warning_amber_rounded, color: Color(0xFFFF453A), size: 11),
          SizedBox(width: 4),
          Text(
            'Jadwal bentrok',
            style: TextStyle(
              color: Color(0xFFFF453A),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Status badge (Diterima / Ditolak) ─────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final BookingStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final isDiterima = status == BookingStatus.diterima;
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isDiterima
              ? const Color(0xFF0A2A0A)
              : const Color(0xFF2A0A0A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDiterima
                ? const Color(0xFF1A5A1A)
                : const Color(0xFF5A1A1A),
            width: 1,
          ),
        ),
        child: Text(
          isDiterima ? 'Diterima' : 'Ditolak',
          style: TextStyle(
            color: isDiterima
                ? const Color(0xFF4CD964)
                : const Color(0xFFFF453A),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ── Baris tombol aksi ─────────────────────────────────────────────────────────
class _ActionRow extends StatelessWidget {
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onChat;

  const _ActionRow({
    required this.onAccept,
    required this.onReject,
    required this.onChat,
  });

  static const _gold = Color(0xFFFFC107);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Tombol Terima
        Expanded(
          flex: 5,
          child: _ActionButton(
            label: 'Terima',
            icon: Icons.check_circle_outline_rounded,
            backgroundColor: _gold,
            labelColor: Colors.black,
            iconColor: Colors.black,
            onTap: onAccept,
          ),
        ),
        const SizedBox(width: 10),

        // Tombol Tolak
        Expanded(
          flex: 5,
          child: _ActionButton(
            label: 'Tolak',
            icon: Icons.cancel_outlined,
            backgroundColor: Colors.transparent,
            labelColor: const Color(0xFFFF453A),
            iconColor: const Color(0xFFFF453A),
            borderColor: const Color(0xFFFF453A),
            onTap: onReject,
          ),
        ),
        const SizedBox(width: 10),

        // Tombol Chat
        _ChatButton(onTap: onChat),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color labelColor;
  final Color iconColor;
  final Color? borderColor;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.labelColor,
    required this.iconColor,
    this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(14),
          border: borderColor != null
              ? Border.all(color: borderColor!, width: 1.5)
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: labelColor,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatButton extends StatelessWidget {
  final VoidCallback onTap;
  const _ChatButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2E),
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: const Icon(
          Icons.chat_bubble_outline_rounded,
          color: Color(0xFF8E8E93),
          size: 18,
        ),
      ),
    );
  }
}
