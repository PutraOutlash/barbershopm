import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'income_recap_dialog.dart';

// ── Entry point ───────────────────────────────────────────────────────────────

/// Tampilkan dialog buka/tutup barbershop.
/// Jika [isOpening] = true → dialog "Buka Barbershop"
/// Jika [isOpening] = false → dialog "Tutup Barbershop", setelah confirm
///   lanjut ke [IncomeRecapDialog].
/// [onConfirmed] dipanggil setelah seluruh alur selesai.
Future<void> showShopStatusDialog(
  BuildContext context, {
  required bool isOpening,
  required VoidCallback onConfirmed,
}) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'ShopStatus',
    barrierColor: Colors.black.withOpacity(0.70),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (_, _, _) => _ShopStatusDialog(
      isOpening: isOpening,
      onConfirmed: onConfirmed,
    ),
    transitionBuilder: (_, anim, _, child) {
      final curve = CurvedAnimation(
        parent: anim,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeInCubic,
      );
      return ScaleTransition(
        scale: Tween<double>(begin: 0.82, end: 1.0).animate(curve),
        child: FadeTransition(
          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: anim, curve: Curves.easeOut),
          ),
          child: child,
        ),
      );
    },
  );
}

// ── Dialog widget ─────────────────────────────────────────────────────────────
class _ShopStatusDialog extends StatefulWidget {
  final bool isOpening;
  final VoidCallback onConfirmed;

  const _ShopStatusDialog({
    required this.isOpening,
    required this.onConfirmed,
  });

  @override
  State<_ShopStatusDialog> createState() => _ShopStatusDialogState();
}

class _ShopStatusDialogState extends State<_ShopStatusDialog>
    with SingleTickerProviderStateMixin {
  static const _gold   = Color(0xFFFFC107);
  static const _card   = Color(0xFF1C1C1E);
  static const _border = Color(0xFF2C2C2E);
  static const _muted  = Color(0xFF8E8E93);

  bool _loading = false;

  // Glow pulse pada icon
  late final AnimationController _glowCtrl;
  late final Animation<double>   _glowAnim;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.25, end: 0.60).animate(
      CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  Future<void> _onConfirm() async {
    HapticFeedback.mediumImpact();
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;

    Navigator.of(context).pop();

    if (!widget.isOpening) {
      // Tutup barbershop → tampilkan rekap dulu
      await Future.delayed(const Duration(milliseconds: 180));
      if (!mounted) return;
      await showIncomeRecapDialog(
        context,
        onConfirmed: widget.onConfirmed,
      );
    } else {
      widget.onConfirmed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final title    = widget.isOpening ? 'Buka Barbershop?' : 'Tutup Barbershop?';
    final subtitle = widget.isOpening
        ? 'Apakah Anda yakin akan membuka Barbershop sekarang?'
        : 'Apakah Anda yakin akan menutup Barbershop sekarang?';

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Container(
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: _gold.withOpacity(0.18),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: _gold.withOpacity(0.10),
                  blurRadius: 32,
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.55),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(24, 30, 24, 26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Icon ─────────────────────────────────────
                AnimatedBuilder(
                  animation: _glowAnim,
                  builder: (_, _) => Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0xFF252520),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _gold.withOpacity(0.30),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _gold.withOpacity(_glowAnim.value),
                          blurRadius: 18,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.storefront_rounded,
                      color: _gold,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ── Title ─────────────────────────────────────
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _gold,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 10),

                // ── Subtitle ──────────────────────────────────
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xCCFFFFFF),
                    fontSize: 14,
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: 26),

                // ── Tombol Ya, Lanjutkan ──────────────────────
                _GoldButton(
                  label: 'Ya, Lanjutkan',
                  loading: _loading,
                  onTap: _onConfirm,
                ),
                const SizedBox(height: 10),

                // ── Tombol Batal ──────────────────────────────
                _OutlineButton(
                  label: 'Batal',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Reusable tombol gold ──────────────────────────────────────────────────────
class _GoldButton extends StatefulWidget {
  final String label;
  final bool loading;
  final VoidCallback onTap;

  const _GoldButton({
    required this.label,
    required this.loading,
    required this.onTap,
  });

  @override
  State<_GoldButton> createState() => _GoldButtonState();
}

class _GoldButtonState extends State<_GoldButton> {
  static const _gold = Color(0xFFFFC107);
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        if (!widget.loading) widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: double.infinity,
        height: 52,
        transform: Matrix4.identity()..scale(_pressed ? 0.97 : 1.0),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: _gold,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: _gold.withOpacity(_pressed ? 0.20 : 0.38),
              blurRadius: _pressed ? 8 : 18,
              offset: Offset(0, _pressed ? 1 : 4),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: widget.loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.black,
                ),
              )
            : Text(
                widget.label,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
              ),
      ),
    );
  }
}

// ── Reusable tombol outline ───────────────────────────────────────────────────
class _OutlineButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _OutlineButton({required this.label, required this.onTap});

  @override
  State<_OutlineButton> createState() => _OutlineButtonState();
}

class _OutlineButtonState extends State<_OutlineButton> {
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: double.infinity,
        height: 50,
        transform: Matrix4.identity()..scale(_pressed ? 0.97 : 1.0),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: _pressed
              ? const Color(0xFF252525)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: _gold.withOpacity(0.35),
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: const Text(
          'Batal',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
