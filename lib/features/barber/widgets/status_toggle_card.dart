import 'package:flutter/material.dart';

class StatusToggleCard extends StatelessWidget {
  final bool isOpen;
  final VoidCallback onToggle;

  const StatusToggleCard({
    super.key,
    required this.isOpen,
    required this.onToggle,
  });

  static const _gold = Color(0xFFFFC107);
  static const _cardBg = Color(0xFF1C1C1E);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOpen
              ? _gold.withOpacity(0.25)
              : const Color(0xFF2C2C2E),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Icon store
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _gold.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.storefront_rounded,
              color: _gold,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),

          // Label
          const Expanded(
            child: Text(
              'Status Barbershop',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Status text
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              isOpen ? 'Buka' : 'Tutup',
              key: ValueKey(isOpen),
              style: TextStyle(
                color: isOpen ? _gold : const Color(0xFF8E8E93),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Toggle switch
          GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: 48,
              height: 28,
              decoration: BoxDecoration(
                color: isOpen ? _gold : const Color(0xFF3A3A3C),
                borderRadius: BorderRadius.circular(14),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                alignment:
                    isOpen ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.all(3),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: isOpen ? Colors.black : const Color(0xFF8E8E93),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
