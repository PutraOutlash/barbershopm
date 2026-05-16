import 'package:flutter/material.dart';

class RatingDistribution extends StatelessWidget {
  final Map<int, int> distribution; // {5: 190, 4: 38, ...}
  final double averageRating;
  final int totalReviews;

  const RatingDistribution({
    super.key,
    required this.distribution,
    required this.averageRating,
    required this.totalReviews,
  });

  static const _gold  = Color(0xFFFFC107);
  static const _muted = Color(0xFF8E8E93);
  static const _bar   = Color(0xFF2C2C2E);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _gold.withOpacity(0.18), width: 1),
        boxShadow: [
          BoxShadow(
            color: _gold.withOpacity(0.06),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Big rating number ──
          Text(
            averageRating.toStringAsFixed(1),
            style: const TextStyle(
              color: _gold,
              fontSize: 56,
              fontWeight: FontWeight.w900,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final filled = i < averageRating.floor();
              final half   = !filled && i < averageRating;
              return Icon(
                half
                    ? Icons.star_half_rounded
                    : filled
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                color: _gold,
                size: 22,
              );
            }),
          ),
          const SizedBox(height: 6),
          Text(
            'Dari $totalReviews ulasan',
            style: const TextStyle(color: _muted, fontSize: 13),
          ),
          const SizedBox(height: 20),

          // ── Bars ──
          ...List.generate(5, (i) {
            final star  = 5 - i;
            final count = distribution[star] ?? 0;
            final pct   = totalReviews > 0 ? count / totalReviews : 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Text('$star',
                      style: const TextStyle(
                          color: _muted, fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 4),
                  const Icon(Icons.star_rounded, color: _muted, size: 12),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Stack(
                        children: [
                          Container(height: 6, color: _bar),
                          FractionallySizedBox(
                            widthFactor: pct.toDouble(),
                            child: Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: _gold,
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 28,
                    child: Text(
                      '$count',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                          color: _muted, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
