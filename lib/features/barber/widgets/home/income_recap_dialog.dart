import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ── Model data rekap ──────────────────────────────────────────────────────────
class IncomeRecapData {
  final int completedTransactions;
  final String totalRevenue;
  final String topService;

  const IncomeRecapData({
    required this.completedTransactions,
    required this.totalRevenue,
    required this.topService,
  });
}

// ── Entry point ───────────────────────────────────────────────────────────────
Future<void> showIncomeRecapDialog(
  BuildContext context, {
  required VoidCallback onConfirmed,
  IncomeRecapData? data,
}) {
  final recap = data ??
      const IncomeRecapData(
        completedTransactions: 12,
        totalRevenue: 'Rp 3.450.000',
        topService: 'Classic Fade',
      );

  return showGeneralDialog(
    context: context,
    barrierDismissible: false, // wajib tekan tombol
    barrierLabel: 'IncomeRecap',
    barrierColor: Colors.black.withOpacity(0.80),
    transitionDuration: const Duration(milliseconds: 320),
    pageBuilder: (_, _, _) => _IncomeRecapDialog(
      data: recap,
      onConfirmed: onConfirmed,
    ),
    transitionBuilder: (_, anim, _, child) {
      final curve = CurvedAnimation(
        parent: anim,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeIn,
      );
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.12),
          end: Offset.zero,
        ).animate(curve),
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
class _IncomeRecapDialog extends StatefulWidget {
  final IncomeRecapData data;
  final VoidCallback onConfirmed;

  const _IncomeRecapDialog({
    required this.data,
    required this.onConfirmed,
  });

  @override
  State<_IncomeRecapDialog> createState() => _IncomeRecapDialogState();
}

class _IncomeRecapDialogState extends State<_IncomeRecapDialog>
    with SingleTickerProviderStateMixin {
  static const _gold   = Color(0xFFFFC107);
  static const _card   = Color(0xFF1C1C1E);
  static const _inner  = Color(0xFF252525);
  static const _border = Color(0xFF2C2C2E);
  static const _muted  = Color(0xFF8E8E93);

  bool _loading = false;

  late final AnimationController _glowCtrl;
  late final Animation<double>   _glowAnim;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.20, end: 0.55).animate(
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
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    Navigator.of(context).pop();
    widget.onConfirmed();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: _gold.withOpacity(0.20),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: _gold.withOpacity(0.12),
                  blurRadius: 36,
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.60),
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
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
                        color: _gold.withOpacity(0.32),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _gold.withOpacity(_glowAnim.value),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      color: _gold,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ── Title ─────────────────────────────────────
                const Text(
                  'Rekap Pendapatan\nHari Ini',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _gold,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 12),

                // ── Subtitle ──────────────────────────────────
                const Text(
                  'Barbershop akan ditutup setelah rekap pendapatan hari ini disimpan ke sistem.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xBBFFFFFF),
                    fontSize: 13,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 22),

                // ── Card ringkasan ─────────────────────────────
                _buildSummaryCard(),
                const SizedBox(height: 24),

                // ── Tombol konfirmasi ─────────────────────────
                _ConfirmButton(
                  loading: _loading,
                  onTap: _onConfirm,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Card summary ─────────────────────────────────────────────────────────────
  Widget _buildSummaryCard() {
    return Container(
      decoration: BoxDecoration(
        color: _inner,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF333333), width: 1),
      ),
      child: Column(
        children: [
          _SummaryRow(
            label: 'Transaksi selesai',
            value: '${widget.data.completedTransactions}',
            valueColor: Colors.white,
            isFirst: true,
          ),
          const _Divider(),
          _SummaryRow(
            label: 'Total omzet',
            value: widget.data.totalRevenue,
            valueColor: _gold,
            valueLarge: true,
          ),
          const _Divider(),
          _SummaryRow(
            label: 'Layanan terlaris',
            value: widget.data.topService,
            valueColor: Colors.white,
            valueBold: true,
            isLast: true,
          ),
        ],
      ),
    );
  }
}

// ── Row item summary ──────────────────────────────────────────────────────────
class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final bool valueLarge;
  final bool valueBold;
  final bool isFirst;
  final bool isLast;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.valueColor,
    this.valueLarge  = false,
    this.valueBold   = false,
    this.isFirst     = false,
    this.isLast      = false,
  });

  static const _muted = Color(0xFF8E8E93);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        18,
        isFirst ? 16 : 14,
        18,
        isLast  ? 16 : 14,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                color: _muted,
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: valueLarge ? 18 : 15,
              fontWeight: valueLarge || valueBold
                  ? FontWeight.w800
                  : FontWeight.w600,
              letterSpacing: valueLarge ? -0.3 : 0,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Divider tipis ─────────────────────────────────────────────────────────────
class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      color: Color(0xFF333333),
      height: 1,
      indent: 18,
      endIndent: 18,
    );
  }
}

// ── Confirm button ────────────────────────────────────────────────────────────
class _ConfirmButton extends StatefulWidget {
  final bool loading;
  final VoidCallback onTap;

  const _ConfirmButton({required this.loading, required this.onTap});

  @override
  State<_ConfirmButton> createState() => _ConfirmButtonState();
}

class _ConfirmButtonState extends State<_ConfirmButton> {
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
        height: 54,
        transform: Matrix4.identity()..scale(_pressed ? 0.97 : 1.0),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: _gold,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: _gold.withOpacity(_pressed ? 0.20 : 0.40),
              blurRadius: _pressed ? 8 : 20,
              offset: Offset(0, _pressed ? 1 : 5),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: widget.loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.black,
                ),
              )
            : const Text(
                'Ya, Rekap Pendapatan Hari Ini',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
      ),
    );
  }
}
