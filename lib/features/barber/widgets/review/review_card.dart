import 'package:flutter/material.dart';
import 'package:barber_app/features/barber/view/review/review_rating_page.dart';

class ReviewCard extends StatefulWidget {
  final ReviewModel review;
  final int index;

  const ReviewCard({super.key, required this.review, required this.index});

  @override
  State<ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<ReviewCard>
    with SingleTickerProviderStateMixin {
  static const _card   = Color(0xFF1C1C1E);
  static const _border = Color(0xFF2C2C2E);
  static const _gold   = Color(0xFFFFC107);
  static const _muted  = Color(0xFF8E8E93);
  static const _red    = Color(0xFFFF453A);

  late AnimationController _ctrl;
  late Animation<double>    _fade;
  late Animation<Offset>    _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 350 + widget.index * 60),
    );
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    Future.delayed(Duration(milliseconds: widget.index * 50), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color get _borderColor {
    if (widget.review.rating >= 4) return _gold.withOpacity(0.35);
    if (widget.review.rating <= 2) return _red.withOpacity(0.35);
    return _border;
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.review;
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _borderColor, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gold left accent for high rating
              if (r.rating >= 4)
                Container(
                  height: 3,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24)),
                    gradient: LinearGradient(
                      colors: [_gold.withOpacity(0.8), Colors.transparent],
                    ),
                  ),
                ),

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Top row: avatar + name + stars ──
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Avatar
                        _Avatar(initials: r.initials),
                        const SizedBox(width: 12),

                        // Name + time
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(r.customerName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  )),
                              const SizedBox(height: 2),
                              Text(r.timeAgo,
                                  style: const TextStyle(
                                      color: _muted, fontSize: 12)),
                            ],
                          ),
                        ),

                        // Stars
                        _StarRow(rating: r.rating),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // ── Service badge ──
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.10), width: 1),
                      ),
                      child: Text(r.serviceName,
                          style: const TextStyle(
                              color: _muted,
                              fontSize: 11,
                              fontWeight: FontWeight.w500)),
                    ),
                    const SizedBox(height: 12),

                    // ── Review text ──
                    Text(
                      '"${r.reviewText}"',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        height: 1.55,
                        fontStyle: FontStyle.italic,
                      ),
                    ),

                    // ── Optional image ──
                    if (r.imageUrl != null) ...[
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          r.imageUrl!,
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const SizedBox.shrink(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Avatar ───────────────────────────────────────────────────────────────────
class _Avatar extends StatelessWidget {
  final String initials;
  const _Avatar({required this.initials});

  static const _gold = Color(0xFFFFC107);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF2A2000),
        border: Border.all(color: _gold.withOpacity(0.4), width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(initials,
          style: const TextStyle(
            color: _gold,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          )),
    );
  }
}

// ─── Star Row ─────────────────────────────────────────────────────────────────
class _StarRow extends StatelessWidget {
  final int rating;
  const _StarRow({required this.rating});

  static const _gold = Color(0xFFFFC107);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        return Icon(
          i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
          color: i < rating ? _gold : const Color(0xFF3A3A3C),
          size: 16,
        );
      }),
    );
  }
}
