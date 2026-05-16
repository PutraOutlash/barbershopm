import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ── Enum & Model ─────────────────────────────────────────────────────────────
enum StatPeriod { hari, bulan, tahun }

class BarItem {
  final String label; // label bawah bar (S, S, R …)
  final double value; // nilai untuk tinggi bar
  final String tooltip; // judul tooltip (Senin, Jan, 2022 …)
  final String amount; // nominal (Rp 1.2M, Rp 52Jt …)

  const BarItem({
    required this.label,
    required this.value,
    required this.tooltip,
    required this.amount,
  });
}

class PeriodData {
  final String revenue;
  final List<BarItem> bars;
  final int defaultActive;

  const PeriodData({
    required this.revenue,
    required this.bars,
    required this.defaultActive,
  });
}

// ── Dummy data ─────────────────────────────────────────────────────────────────
const _hariData = PeriodData(
  revenue: 'Rp 3.450K',
  defaultActive: 2,
  bars: [
    BarItem(label: 'S', value: 1.2, tooltip: 'Senin', amount: 'Rp 1.2M'),
    BarItem(label: 'S', value: 0.8, tooltip: 'Selasa', amount: 'Rp 0.8M'),
    BarItem(label: 'R', value: 3.4, tooltip: 'Hari Ini', amount: 'Rp 3.4M'),
    BarItem(label: 'K', value: 1.8, tooltip: 'Kamis', amount: 'Rp 1.8M'),
    BarItem(label: 'J', value: 2.1, tooltip: 'Jumat', amount: 'Rp 2.1M'),
    BarItem(label: 'S', value: 0.5, tooltip: 'Sabtu', amount: 'Rp 0.5M'),
    BarItem(label: 'M', value: 1.0, tooltip: 'Minggu', amount: 'Rp 1.0M'),
  ],
);

const _bulanData = PeriodData(
  revenue: 'Rp 78.2Jt',
  defaultActive: 11,
  bars: [
    BarItem(label: 'J', value: 52, tooltip: 'Jan', amount: 'Rp 52Jt'),
    BarItem(label: 'F', value: 61, tooltip: 'Feb', amount: 'Rp 61Jt'),
    BarItem(label: 'M', value: 48, tooltip: 'Mar', amount: 'Rp 48Jt'),
    BarItem(label: 'A', value: 70, tooltip: 'Apr', amount: 'Rp 70Jt'),
    BarItem(label: 'M', value: 65, tooltip: 'Mei', amount: 'Rp 65Jt'),
    BarItem(label: 'J', value: 80, tooltip: 'Jun', amount: 'Rp 80Jt'),
    BarItem(label: 'J', value: 55, tooltip: 'Jul', amount: 'Rp 55Jt'),
    BarItem(label: 'A', value: 72, tooltip: 'Ags', amount: 'Rp 72Jt'),
    BarItem(label: 'S', value: 68, tooltip: 'Sep', amount: 'Rp 68Jt'),
    BarItem(label: 'O', value: 90, tooltip: 'Okt', amount: 'Rp 90Jt'),
    BarItem(label: 'N', value: 75, tooltip: 'Nov', amount: 'Rp 75Jt'),
    BarItem(label: 'D', value: 78.2, tooltip: 'Bulan Ini', amount: 'Rp 78.2Jt'),
  ],
);

const _tahunData = PeriodData(
  revenue: 'Rp 842Jt',
  defaultActive: 3,
  bars: [
    BarItem(label: '2021', value: 520, tooltip: '2021', amount: 'Rp 520Jt'),
    BarItem(label: '2022', value: 640, tooltip: '2022', amount: 'Rp 640Jt'),
    BarItem(label: '2023', value: 710, tooltip: '2023', amount: 'Rp 710Jt'),
    BarItem(
      label: '2024',
      value: 842,
      tooltip: 'Tahun Ini',
      amount: 'Rp 842Jt',
    ),
  ],
);

// ── SummaryCard ───────────────────────────────────────────────────────────────
class SummaryCard extends StatefulWidget {
  final String popularService;
  final String growthPercent;

  const SummaryCard({
    super.key,
    this.popularService = 'Classic Fade',
    this.growthPercent = '+12.5%',
  });

  @override
  State<SummaryCard> createState() => _SummaryCardState();
}

class _SummaryCardState extends State<SummaryCard>
    with SingleTickerProviderStateMixin {
  static const _gold = Color(0xFFFFC107);
  static const _card = Color(0xFF1C1C1E);

  StatPeriod _period = StatPeriod.hari;
  int _activeIndex = _hariData.defaultActive;

  // fade saat ganti periode
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  PeriodData get _data {
    switch (_period) {
      case StatPeriod.hari:
        return _hariData;
      case StatPeriod.bulan:
        return _bulanData;
      case StatPeriod.tahun:
        return _tahunData;
    }
  }

  String get _title {
    switch (_period) {
      case StatPeriod.hari:
        return 'Pendapatan Hari Ini';
      case StatPeriod.bulan:
        return 'Pendapatan Bulan Ini';
      case StatPeriod.tahun:
        return 'Pendapatan Tahun Ini';
    }
  }

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
      value: 1.0,
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  // Ganti periode → reset ke default active
  Future<void> _changePeriod(StatPeriod p) async {
    if (p == _period) return;
    HapticFeedback.selectionClick();
    await _fadeCtrl.reverse();
    setState(() {
      _period = p;
      _activeIndex = _data.defaultActive;
    });
    _fadeCtrl.forward();
  }

  // Tap batang → ubah active index
  void _onBarTap(int index) {
    if (index == _activeIndex) return;
    HapticFeedback.lightImpact();
    setState(() => _activeIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final data = _data;
    final activeBar = data.bars[_activeIndex];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF2C2C2E), width: 1),
        boxShadow: [BoxShadow(color: _gold.withOpacity(0.04), blurRadius: 20)],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: judul + badge ──────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: Text(
                  _title,
                  key: ValueKey(_period),
                  style: const TextStyle(
                    color: Color(0xFF8E8E93),
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const Spacer(),
              _GrowthBadge(text: '${widget.growthPercent} HARI INI'),
            ],
          ),
          const SizedBox(height: 6),

          // ── Nominal pendapatan ─────────────────────────────────
          FadeTransition(
            opacity: _fadeAnim,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, anim) => SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.18),
                  end: Offset.zero,
                ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
                child: FadeTransition(opacity: anim, child: child),
              ),
              child: Text(
                data.revenue,
                key: ValueKey('${_period}_revenue'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // ── Filter Hari / Bulan / Tahun ─────────────────────────
          _PeriodFilter(selected: _period, onChanged: _changePeriod),
          const SizedBox(height: 18),

          // ── Divider ────────────────────────────────────────────
          const Divider(color: Color(0xFF2C2C2E), height: 1),
          const SizedBox(height: 14),

          // ── Layanan terpopuler ─────────────────────────────────
          const Text(
            'LAYANAN TERPOPULER',
            style: TextStyle(
              color: Color(0xFF8E8E93),
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.popularService,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),

          // ── Chart interaktif ───────────────────────────────────
          FadeTransition(
            opacity: _fadeAnim,
            child: _InteractiveBarChart(
              key: ValueKey(_period),
              bars: data.bars,
              activeIndex: _activeIndex,
              onBarTap: _onBarTap,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Chart interaktif ──────────────────────────────────────────────────────────
class _InteractiveBarChart extends StatefulWidget {
  final List<BarItem> bars;
  final int activeIndex;
  final ValueChanged<int> onBarTap;

  const _InteractiveBarChart({
    super.key,
    required this.bars,
    required this.activeIndex,
    required this.onBarTap,
  });

  @override
  State<_InteractiveBarChart> createState() => _InteractiveBarChartState();
}

class _InteractiveBarChartState extends State<_InteractiveBarChart>
    with SingleTickerProviderStateMixin {
  static const _gold = Color(0xFFFFC107);
  static const _barDark = Color(0xFF2C2C2E);
  static const _chartH = 90.0; // max tinggi bar
  static const _tooltipH = 52.0; // tinggi estimasi tooltip
  static const _labelH = 22.0; // tinggi label bawah

  late final AnimationController _ctrl;
  late final Animation<double> _heightAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _heightAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bars = widget.bars;
    final maxVal = bars.map((b) => b.value).reduce((a, b) => a > b ? a : b);
    final count = bars.length;
    final hPad = count > 8 ? 2.0 : 3.5;
    // Font label lebih kecil jika banyak bar
    final lblSize = count > 8 ? 8.0 : 10.0;

    return AnimatedBuilder(
      animation: _heightAnim,
      builder: (_, _) {
        return SizedBox(
          // Total height = tooltip + bar + spacing + label
          height: _tooltipH + 14 + _chartH + 10 + _labelH,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(count, (i) {
              final bar = bars[i];
              final isActive = i == widget.activeIndex;
              final ratio = bar.value / maxVal;
              final barH = (_chartH * ratio * _heightAnim.value).clamp(
                4.0,
                _chartH,
              );

              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => widget.onBarTap(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // ── Tooltip area (fixed height) ──────────
                      SizedBox(
                        height: _tooltipH + 10,
                        child: isActive
                            ? _AnimatedTooltip(
                                key: ValueKey('tt_$i'),
                                label: bar.tooltip,
                                amount: bar.amount,
                              )
                            : const SizedBox.shrink(),
                      ),

                      // ── Bar ───────────────────────────────────
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: hPad),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic,
                          width: double.infinity,
                          height: barH,
                          decoration: BoxDecoration(
                            color: isActive ? _gold : _barDark,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(5),
                              topRight: Radius.circular(5),
                            ),
                            boxShadow: isActive
                                ? [
                                    BoxShadow(
                                      color: _gold.withOpacity(0.36),
                                      blurRadius: 10,
                                      offset: const Offset(0, -2),
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                      ),

                      // ── Label bawah ───────────────────────────
                      SizedBox(
                        height: _labelH,
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 240),
                            style: TextStyle(
                              color: isActive ? _gold : const Color(0xFF48484A),
                              fontSize: lblSize,
                              fontWeight: isActive
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                            ),
                            child: Text(
                              bar.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

// ── Tooltip animasi ───────────────────────────────────────────────────────────
class _AnimatedTooltip extends StatefulWidget {
  final String label;
  final String amount;

  const _AnimatedTooltip({
    super.key,
    required this.label,
    required this.amount,
  });

  @override
  State<_AnimatedTooltip> createState() => _AnimatedTooltipState();
}

class _AnimatedTooltipState extends State<_AnimatedTooltip>
    with SingleTickerProviderStateMixin {
  static const _gold = Color(0xFFFFC107);

  late final AnimationController _ctrl;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    )..forward();
    _scaleAnim = Tween<double>(
      begin: 0.75,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: ScaleTransition(
        scale: _scaleAnim,
        alignment: Alignment.bottomCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Kotak tooltip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2000),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _gold.withOpacity(0.45), width: 1),
                boxShadow: [
                  BoxShadow(color: _gold.withOpacity(0.20), blurRadius: 8),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.label,
                    style: const TextStyle(
                      color: _gold,
                      fontSize: 7,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                  Text(
                    widget.amount,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            // Triangle
            CustomPaint(
              size: const Size(8, 5),
              painter: _TrianglePainter(color: _gold.withOpacity(0.45)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Triangle painter ──────────────────────────────────────────────────────────
class _TrianglePainter extends CustomPainter {
  final Color color;
  const _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width / 2, size.height)
        ..close(),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_TrianglePainter old) => old.color != color;
}

// ── Filter Hari / Bulan / Tahun ───────────────────────────────────────────────
class _PeriodFilter extends StatelessWidget {
  final StatPeriod selected;
  final ValueChanged<StatPeriod> onChanged;

  const _PeriodFilter({required this.selected, required this.onChanged});

  static const _filters = [
    (label: 'HARI', value: StatPeriod.hari),
    (label: 'BULAN', value: StatPeriod.bulan),
    (label: 'TAHUN', value: StatPeriod.tahun),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2C2C2E), width: 1),
      ),
      child: Row(
        children: _filters.map((f) {
          final isActive = selected == f.value;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(f.value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFFFFC107)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(17),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: const Color(0xFFFFC107).withOpacity(0.22),
                            blurRadius: 8,
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  f.label,
                  style: TextStyle(
                    color: isActive ? Colors.black : const Color(0xFF8E8E93),
                    fontSize: 11,
                    fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
                    letterSpacing: 0.5,
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

// ── Growth badge ──────────────────────────────────────────────────────────────
class _GrowthBadge extends StatelessWidget {
  final String text;
  const _GrowthBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2A0A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2E4A0E), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.trending_up_rounded,
            color: Color(0xFF4CD964),
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF4CD964),
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
