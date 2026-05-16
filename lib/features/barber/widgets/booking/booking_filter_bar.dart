import 'package:flutter/material.dart';
import 'package:barber_app/core/models/booking_model.dart';

class BookingFilterBar extends StatelessWidget {
  final BookingStatus activeStatus;
  final ValueChanged<BookingStatus> onChanged;

  const BookingFilterBar({
    super.key,
    required this.activeStatus,
    required this.onChanged,
  });

  static const _gold = Color(0xFFFFC107);

  static const _filters = [
    (label: 'Pending', value: BookingStatus.pending),
    (label: 'Diterima', value: BookingStatus.diterima),
    (label: 'Ditolak', value: BookingStatus.ditolak),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _filters.map((f) {
        final isActive = activeStatus == f.value;
        return Padding(
          padding: const EdgeInsets.only(right: 10),
          child: _FilterPill(
            label: f.label,
            isActive: isActive,
            onTap: () => onChanged(f.value),
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

  static const _gold = Color(0xFFFFC107);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 230),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? _gold : const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isActive ? _gold : const Color(0xFF2C2C2E),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.black : const Color(0xFF8E8E93),
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            letterSpacing: 0.1,
          ),
        ),
      ),
    );
  }
}
