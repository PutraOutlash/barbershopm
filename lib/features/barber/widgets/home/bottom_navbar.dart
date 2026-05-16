import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:barber_app/features/barber/view/scanner/scanner_page.dart';

/// Bottom navbar dengan 5 item:
/// index 0=Beranda, 1=Booking, (scan button), 2=Riwayat, 3=Profil
class BottomNavBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar>
    with SingleTickerProviderStateMixin {
  static const _gold = Color(0xFFFFC107);

  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseScale;
  late final Animation<double> _pulseOpacity;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _pulseScale = Tween<double>(begin: 1.0, end: 1.55).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeOut),
    );
    _pulseOpacity = Tween<double>(begin: 0.55, end: 0.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _openScanner() {
    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, a, b) => const ScannerPage(),
        transitionsBuilder: (_, a, b, child) => FadeTransition(
          opacity: CurvedAnimation(parent: a, curve: Curves.easeOut),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: SizedBox(
        height: 72,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // ── Capsule container ──────────────────────────────
            Container(
              height: 72,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1C1C1C), Color(0xFF101010)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(36),
                border: Border.all(
                  color: _gold.withOpacity(0.14),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.65),
                    blurRadius: 28,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: _gold.withOpacity(0.05),
                    blurRadius: 18,
                    spreadRadius: 0,
                  ),
                ],
              ),
            ),

            // ── Nav items row ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  // Beranda
                  _NavBtn(
                    icon: Icons.home_rounded,
                    label: 'BERANDA',
                    isActive: widget.currentIndex == 0,
                    onTap: () { HapticFeedback.lightImpact(); widget.onTap(0); },
                  ),

                  // Booking
                  _NavBtn(
                    icon: Icons.receipt_long_rounded,
                    label: 'BOOKING',
                    isActive: widget.currentIndex == 1,
                    onTap: () { HapticFeedback.lightImpact(); widget.onTap(1); },
                  ),

                  // Spacer scan button
                  const SizedBox(width: 68),

                  // Riwayat
                  _NavBtn(
                    icon: Icons.history_rounded,
                    label: 'RIWAYAT',
                    isActive: widget.currentIndex == 2,
                    onTap: () { HapticFeedback.lightImpact(); widget.onTap(2); },
                  ),

                  // Profil
                  _NavBtn(
                    icon: Icons.person_rounded,
                    label: 'PROFIL',
                    isActive: widget.currentIndex == 3,
                    onTap: () { HapticFeedback.lightImpact(); widget.onTap(3); },
                  ),
                ],
              ),
            ),

            // ── Floating scan button ────────────────────────────
            Positioned(
              top: -20,
              child: _ScanButton(
                onTap: _openScanner,
                pulseScale: _pulseScale,
                pulseOpacity: _pulseOpacity,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Floating scan button ──────────────────────────────────────────────────────
class _ScanButton extends StatefulWidget {
  final VoidCallback onTap;
  final Animation<double> pulseScale;
  final Animation<double> pulseOpacity;

  const _ScanButton({
    required this.onTap,
    required this.pulseScale,
    required this.pulseOpacity,
  });

  @override
  State<_ScanButton> createState() => _ScanButtonState();
}

class _ScanButtonState extends State<_ScanButton> {
  static const _gold = Color(0xFFFFC107);
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: SizedBox(
        width: 68,
        height: 68,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Pulse ring
            AnimatedBuilder(
              animation: widget.pulseScale,
              builder: (_, _) => Transform.scale(
                scale: widget.pulseScale.value,
                child: FadeTransition(
                  opacity: widget.pulseOpacity,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: _gold, width: 1.5),
                    ),
                  ),
                ),
              ),
            ),

            // Button body
            AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              width: _pressed ? 54 : 60,
              height: _pressed ? 54 : 60,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFE040), Color(0xFFFFC107)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: _gold.withOpacity(_pressed ? 0.3 : 0.55),
                    blurRadius: _pressed ? 12 : 26,
                    spreadRadius: _pressed ? 0 : 3,
                    offset: Offset(0, _pressed ? 2 : 5),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: AnimatedScale(
                scale: _pressed ? 0.85 : 1.0,
                duration: const Duration(milliseconds: 100),
                child: const Icon(
                  Icons.qr_code_scanner_rounded,
                  color: Colors.black,
                  size: 28,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Nav item button ──────────────────────────────────────────────────────────
class _NavBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavBtn({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  static const _gold = Color(0xFFFFC107);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.symmetric(
              horizontal: isActive ? 14 : 10,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: isActive ? _gold : Colors.transparent,
              borderRadius: BorderRadius.circular(22),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: _gold.withOpacity(0.22),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: isActive ? Colors.black : const Color(0xFF555555),
                  size: 20,
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  style: TextStyle(
                    color: isActive ? Colors.black : const Color(0xFF555555),
                    fontSize: 9,
                    fontWeight:
                        isActive ? FontWeight.w800 : FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
