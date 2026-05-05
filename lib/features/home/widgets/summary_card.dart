import 'package:flutter/material.dart';
import '../../../models/activity_model.dart';

class SummaryCard extends StatelessWidget {
  final SummaryModel summary;

  const SummaryCard({super.key, required this.summary});

  static const _gold = Color(0xFFFFC107);
  static const _cardBg = Color(0xFF1C1C1E);
  static const _barDark = Color(0xFF2C2C2E);

  static const _dayLabels = ['S', 'S', 'R', 'K', 'J', 'S', 'M'];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2C2C2E), width: 1),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Judul + badge growth
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ringkasan Hari Ini',
                style: TextStyle(
                  color: Color(0xFF8E8E93),
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Spacer(),
              _GrowthBadge(text: '${summary.growthPercent} HARI INI'),
            ],
          ),
          const SizedBox(height: 6),

          // Total pendapatan
          Text(
            summary.totalRevenue,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),

          // Layanan terpopuler
          const Text(
            'LAYANAN TERPOPULER',
            style: TextStyle(
              color: Color(0xFF48484A),
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            summary.popularService,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),

          // Grafik batang 7 hari
          _WeeklyBarChart(
            data: summary.weeklyData,
            activeDayIndex: summary.activeDayIndex,
            dayLabels: _dayLabels,
          ),
        ],
      ),
    );
  }
}

// ── Badge pertumbuhan ────────────────────────────────────────────────────────
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
          const Icon(Icons.trending_up_rounded, color: Color(0xFF4CD964), size: 12),
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

// ── Grafik batang 7 hari ─────────────────────────────────────────────────────
class _WeeklyBarChart extends StatelessWidget {
  final List<double> data;
  final int activeDayIndex;
  final List<String> dayLabels;

  const _WeeklyBarChart({
    required this.data,
    required this.activeDayIndex,
    required this.dayLabels,
  });

  static const _gold = Color(0xFFFFC107);
  static const _barDark = Color(0xFF2C2C2E);

  @override
  Widget build(BuildContext context) {
    final maxVal = data.reduce((a, b) => a > b ? a : b);
    const chartHeight = 80.0;

    return SizedBox(
      height: chartHeight + 55, // extra untuk label atas + bawah
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(data.length, (i) {
          final isActive = i == activeDayIndex;
          final ratio = data[i] / maxVal;
          final barH = chartHeight * ratio;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Label "Hari Ini" di atas bar aktif
                  if (isActive) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: _gold,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Rp ${data[i].toStringAsFixed(1)}M',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                  ] else
                    SizedBox(height: isActive ? 0 : 24),

                  // Bar
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutCubic,
                    width: double.infinity,
                    height: barH,
                    decoration: BoxDecoration(
                      color: isActive ? _gold : _barDark,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      ),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: _gold.withOpacity(0.35),
                                blurRadius: 8,
                                offset: const Offset(0, -2),
                              )
                            ]
                          : null,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Label hari
                  Text(
                    dayLabels[i],
                    style: TextStyle(
                      color: isActive ? _gold : const Color(0xFF48484A),
                      fontSize: 11,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
