import 'package:barber_app/core/models/activity_model.dart';
import 'package:flutter/material.dart';

class ActivityItem extends StatelessWidget {
  final ActivityModel activity;

  const ActivityItem({super.key, required this.activity});

  static const _gold = Color(0xFFFFC107);
  static const _cardBg = Color(0xFF1C1C1E);

  @override
  Widget build(BuildContext context) {
    final isActive = activity.isActive;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF1A1500) : _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? _gold.withOpacity(0.4) : const Color(0xFF2C2C2E),
          width: isActive ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          // Garis kuning kiri untuk item aktif
          if (isActive)
            Container(
              width: 3.5,
              height: 68,
              decoration: const BoxDecoration(
                color: _gold,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),

          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                isActive ? 12 : 16,
                12,
                16,
                12,
              ),
              child: Row(
                children: [
                  // Avatar inisial
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive
                          ? _gold.withOpacity(0.2)
                          : const Color(0xFF2C2C2E),
                      border: Border.all(
                        color: isActive
                            ? _gold.withOpacity(0.5)
                            : const Color(0xFF3A3A3C),
                        width: 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      activity.initials,
                      style: TextStyle(
                        color: isActive ? _gold : Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Info pelanggan
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity.customerName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          activity.serviceName,
                          style: const TextStyle(
                            color: Color(0xFF8E8E93),
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 6),
                        _StatusBadge(status: activity.status),
                      ],
                    ),
                  ),

                  // Jam + Harga
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        activity.time,
                        style: TextStyle(
                          color: isActive ? _gold : const Color(0xFF8E8E93),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        activity.price,
                        style: TextStyle(
                          color: isActive ? const Color(0xFF8E8E93) : Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
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

class _StatusBadge extends StatelessWidget {
  final ActivityStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final isActive = status == ActivityStatus.sedangBerjalan;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFFFFC107).withOpacity(0.15)
            : const Color(0xFF1A3A1A),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isActive
              ? const Color(0xFFFFC107).withOpacity(0.4)
              : const Color(0xFF2E5A2E),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isActive) ...[
            Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: Color(0xFFFFC107),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            isActive ? 'SEDANG BERJALAN' : 'SELESAI',
            style: TextStyle(
              color: isActive ? const Color(0xFFFFC107) : const Color(0xFF4CD964),
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
