import 'package:barber_app/core/models/notification_model.dart';
import 'package:flutter/material.dart';

class NotificationFilterBar extends StatelessWidget {
  final NotificationFilter activeFilter;
  final ValueChanged<NotificationFilter> onFilterChanged;

  const NotificationFilterBar({
    super.key,
    required this.activeFilter,
    required this.onFilterChanged,
  });

  //static const _gold = Color(0xFFF2B705);

  static const _filters = [
    (label: 'Semua', value: NotificationFilter.semua),
    (label: 'Belum Dibaca', value: NotificationFilter.belumDibaca),
    (label: 'Promo', value: NotificationFilter.promo),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _filters.map((f) {
        final isActive = activeFilter == f.value;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: _FilterPill(
            label: f.label,
            isActive: isActive,
            onTap: () => onFilterChanged(f.value),
          ),
        );
      }).toList(),
    );
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  static const _gold = Color(0xFFF2B705);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: isActive ? _gold : const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isActive ? _gold : const Color(0xFF2A2A2A),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.black : const Color(0xFF888888),
            fontSize: 13,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
