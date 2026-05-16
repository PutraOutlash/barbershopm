import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RatingFilterBar extends StatelessWidget {
  final int selectedIndex; // 0=Semua, 1=5★ … 5=1★
  final ValueChanged<int> onChanged;

  const RatingFilterBar({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  static const _gold   = Color(0xFFFFC107);
  static const _card   = Color(0xFF1C1C1E);
  static const _border = Color(0xFF2C2C2E);
  static const _muted  = Color(0xFF8E8E93);

  @override
  Widget build(BuildContext context) {
    final labels = [
      'Semua',
      '5 ★',
      '4 ★',
      '3 ★',
      '2 ★',
      '1 ★',
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: labels.asMap().entries.map((e) {
          final active = selectedIndex == e.key;
          return Padding(
            padding: EdgeInsets.only(right: e.key < labels.length - 1 ? 8 : 0),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                onChanged(e.key);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                decoration: BoxDecoration(
                  color: active ? _gold : _card,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: active ? _gold : _border,
                    width: 1,
                  ),
                ),
                child: Text(
                  e.value,
                  style: TextStyle(
                    color: active ? Colors.black : _muted,
                    fontSize: 13,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w400,
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
