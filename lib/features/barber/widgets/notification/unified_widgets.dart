import 'package:flutter/material.dart';

// ── Search Bar ────────────────────────────────────────────────────────────────
class UnifiedSearchBar extends StatefulWidget {
  final ValueChanged<String> onChanged;

  const UnifiedSearchBar({super.key, required this.onChanged});

  @override
  State<UnifiedSearchBar> createState() => _UnifiedSearchBarState();
}

class _UnifiedSearchBarState extends State<UnifiedSearchBar> {
  final _ctrl = TextEditingController();
  bool _focused = false;

  static const _gold = Color(0xFFFFC107);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (f) => setState(() => _focused = f),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: _focused
                ? _gold.withOpacity(0.45)
                : const Color(0xFF2C2C2E),
            width: 1,
          ),
          boxShadow: _focused
              ? [BoxShadow(color: _gold.withOpacity(0.10), blurRadius: 12)]
              : null,
        ),
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 16),
              child: Icon(Icons.search_rounded, color: Color(0xFF8E8E93), size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _ctrl,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                onChanged: widget.onChanged,
                decoration: InputDecoration(
                  hintText: 'Cari notifikasi...',
                  hintStyle: TextStyle(
                    color: const Color(0xFF8E8E93).withOpacity(0.6),
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            if (_ctrl.text.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _ctrl.clear();
                  widget.onChanged('');
                  setState(() {});
                },
                child: const Padding(
                  padding: EdgeInsets.only(right: 14),
                  child: Icon(Icons.close_rounded,
                      color: Color(0xFF8E8E93), size: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Summary Mini Cards ────────────────────────────────────────────────────────
class UnifiedSummaryCards extends StatelessWidget {
  final int bookingHariIni;
  final String pembayaranMasuk;

  const UnifiedSummaryCards({
    super.key,
    required this.bookingHariIni,
    required this.pembayaranMasuk,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MiniCard(
            icon: Icons.calendar_today_rounded,
            label: 'BOOKING HARI INI',
            value: '$bookingHariIni',
            iconColor: const Color(0xFFFFC107),
            iconBg: const Color(0xFF2A2000),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MiniCard(
            icon: Icons.payments_outlined,
            label: 'PEMBAYARAN MASUK',
            value: pembayaranMasuk,
            iconColor: const Color(0xFF4CD964),
            iconBg: const Color(0xFF0A2A0A),
          ),
        ),
      ],
    );
  }
}

class _MiniCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;
  final Color iconBg;

  const _MiniCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
    required this.iconBg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF2C2C2E), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(11),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF8E8E93),
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
