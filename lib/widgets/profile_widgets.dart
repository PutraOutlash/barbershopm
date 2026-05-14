import 'package:flutter/material.dart';

// Palet Warna Internal Widget
const Color pureBlack = Color(0xFF0A0A0C);
const Color cardBlack = Color(0xFF141416);
const Color goldSolid = Color(0xFFE5C07B);
const Color textMuted = Color(0xFF7E7E84);
const Color borderDark = Color(0xFF262628);

class GroupedCardWidget extends StatelessWidget {
  final List<Widget> children;
  const GroupedCardWidget({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardBlack,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderDark),
      ),
      child: Column(children: children),
    );
  }
}

class ProfileListTileWidget extends StatelessWidget {
  final IconData? icon;
  final Widget? customIcon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  const ProfileListTileWidget({
    super.key,
    this.icon,
    this.customIcon,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: pureBlack,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderDark),
        ),
        child: customIcon ?? Icon(icon, color: goldSolid, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: const TextStyle(color: textMuted, fontSize: 12),
            )
          : null,
      trailing:
          trailing ??
          const Icon(Icons.arrow_forward_ios, size: 14, color: borderDark),
      onTap: onTap,
    );
  }
}

class CustomTextFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool isNumber;
  final int maxLines;

  const CustomTextFieldWidget({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.isNumber = false,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: textMuted),
        prefixIcon: Padding(
          padding: EdgeInsets.only(bottom: maxLines > 1 ? 20.0 : 0.0),
          child: Icon(icon, color: textMuted, size: 20),
        ),
        filled: true,
        fillColor: pureBlack,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: goldSolid),
        ),
      ),
    );
  }
}

class CustomDividerWidget extends StatelessWidget {
  const CustomDividerWidget({super.key});
  @override
  Widget build(BuildContext context) =>
      const Divider(color: borderDark, height: 1, indent: 20, endIndent: 20);
}
