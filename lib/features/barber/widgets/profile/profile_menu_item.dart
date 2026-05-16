import 'package:flutter/material.dart';

enum ProfileMenuTrailing { arrow, toggle, none }

class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? titleColor;
  final Color? iconColor;
  final ProfileMenuTrailing trailing;
  final bool toggleValue;
  final ValueChanged<bool>? onToggleChanged;
  final VoidCallback? onTap;
  final bool showDivider;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.title,
    this.titleColor,
    this.iconColor,
    this.trailing = ProfileMenuTrailing.arrow,
    this.toggleValue = false,
    this.onToggleChanged,
    this.onTap,
    this.showDivider = true,
  });

  static const _gold   = Color(0xFFFFC107);
  static const _muted  = Color(0xFF8E8E93);

  @override
  Widget build(BuildContext context) {
    final effectiveTitleColor = titleColor ?? Colors.white;
    final effectiveIconColor  = iconColor  ?? _muted;

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: trailing == ProfileMenuTrailing.toggle ? null : onTap,
            borderRadius: BorderRadius.zero,
            splashColor: _gold.withOpacity(0.06),
            highlightColor: _gold.withOpacity(0.03),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              child: Row(
                children: [
                  // Icon dalam kotak kecil
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: effectiveIconColor.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Icon(icon, color: effectiveIconColor, size: 17),
                  ),
                  const SizedBox(width: 14),

                  // Label
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: effectiveTitleColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  // Trailing
                  _buildTrailing(),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          const Divider(
            color: Color(0xFF2C2C2E),
            height: 1,
            indent: 16,
            endIndent: 16,
          ),
      ],
    );
  }

  Widget _buildTrailing() {
    switch (trailing) {
      case ProfileMenuTrailing.arrow:
        return const Icon(
          Icons.chevron_right_rounded,
          color: Color(0xFF3A3A3C),
          size: 20,
        );
      case ProfileMenuTrailing.toggle:
        return GestureDetector(
          onTap: () => onToggleChanged?.call(!toggleValue),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeInOut,
            width: 44,
            height: 26,
            decoration: BoxDecoration(
              color: toggleValue ? _gold : const Color(0xFF3A3A3C),
              borderRadius: BorderRadius.circular(13),
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeInOut,
              alignment:
                  toggleValue ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.all(3),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: toggleValue ? Colors.black : const Color(0xFF8E8E93),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        );
      case ProfileMenuTrailing.none:
        return const SizedBox.shrink();
    }
  }
}
