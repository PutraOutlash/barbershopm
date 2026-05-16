import 'package:flutter/material.dart';

class StatsRow extends StatelessWidget {
  final int newCustomers;
  final int activeServices;

  const StatsRow({
    super.key,
    required this.newCustomers,
    required this.activeServices,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatsCard(
            icon: Icons.person_add_outlined,
            label: 'Pelanggan Baru',
            value: newCustomers.toString(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatsCard(
            icon: Icons.content_cut_rounded,
            label: 'Layanan Aktif',
            value: activeServices.toString(),
          ),
        ),
      ],
    );
  }
}

class _StatsCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatsCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  static const _gold = Color(0xFFFFC107);
  static const _cardBg = Color(0xFF1C1C1E);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF2C2C2E), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon dalam lingkaran
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _gold.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: _gold, size: 18),
          ),
          const SizedBox(height: 14),

          // Label
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF8E8E93),
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 4),

          // Nilai
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}
