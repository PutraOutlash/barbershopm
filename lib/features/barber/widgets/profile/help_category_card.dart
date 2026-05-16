import 'package:flutter/material.dart';

class HelpCategoryCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final bool isWide; // untuk item "Lainnya" yang span full width

  const HelpCategoryCard({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
    this.isWide = false,
  });

  @override
  State<HelpCategoryCard> createState() => _HelpCategoryCardState();
}

class _HelpCategoryCardState extends State<HelpCategoryCard> {
  bool _pressed = false;

  static const _gold   = Color(0xFFFFC107);
  static const _card   = Color(0xFF1C1C1E);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: widget.isWide
            ? const EdgeInsets.symmetric(horizontal: 20, vertical: 16)
            : const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: _pressed
              ? const Color(0xFF252520)
              : _card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _pressed
                ? _gold.withOpacity(0.45)
                : _gold.withOpacity(0.20),
            width: 1,
          ),
          boxShadow: _pressed
              ? [
                  BoxShadow(
                    color: _gold.withOpacity(0.10),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: widget.isWide
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(widget.icon, color: _gold, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(widget.icon, color: _gold, size: 28),
                  const SizedBox(height: 10),
                  Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
