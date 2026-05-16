import 'package:flutter/material.dart';
import 'package:barber_app/core/models/unified_notification_model.dart';

class UnifiedFilterBar extends StatelessWidget {
  final UnifiedNotifFilter activeFilter;
  final ValueChanged<UnifiedNotifFilter> onChanged;

  const UnifiedFilterBar({
    super.key,
    required this.activeFilter,
    required this.onChanged,
  });

  static const _filters = [
    (label: 'Semua',       value: UnifiedNotifFilter.semua),
    (label: 'Belum Dibaca',value: UnifiedNotifFilter.belumDibaca),
    (label: 'Booking',     value: UnifiedNotifFilter.booking),
    (label: 'Pembayaran',  value: UnifiedNotifFilter.pembayaran),
    (label: 'Sistem',      value: UnifiedNotifFilter.sistem),
    (label: 'Promo',       value: UnifiedNotifFilter.promo),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _filters.map((f) {
          final isActive = activeFilter == f.value;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onChanged(f.value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFFFFC107)
                      : const Color(0xFF1C1C1E),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: isActive
                        ? const Color(0xFFFFC107)
                        : const Color(0xFF2C2C2E),
                    width: 1,
                  ),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: const Color(0xFFFFC107).withOpacity(0.20),
                            blurRadius: 8,
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  f.label,
                  style: TextStyle(
                    color: isActive ? Colors.black : const Color(0xFF8E8E93),
                    fontSize: 13,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
