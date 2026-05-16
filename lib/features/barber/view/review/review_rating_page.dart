import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:barber_app/features/barber/widgets/review/review_card.dart';
import 'package:barber_app/features/barber/widgets/review/rating_distribution.dart';
import 'package:barber_app/features/barber/widgets/review/rating_filter_bar.dart';
import 'package:barber_app/features/barber/widgets/review/review_search_bar.dart';
import 'package:barber_app/features/barber/widgets/review/statistic_card.dart';

// ─── Model ────────────────────────────────────────────────────────────────────

class ReviewModel {
  final String id;
  final String customerName;
  final String initials;
  final String serviceName;
  final int    rating;
  final String reviewText;
  final String timeAgo;
  final String? imageUrl;

  const ReviewModel({
    required this.id,
    required this.customerName,
    required this.initials,
    required this.serviceName,
    required this.rating,
    required this.reviewText,
    required this.timeAgo,
    this.imageUrl,
  });
}

// ─── Dummy data ───────────────────────────────────────────────────────────────

const _dummyReviews = <ReviewModel>[
  ReviewModel(
    id: 'RVW-001',
    customerName: 'Budi Santoso',
    initials: 'BS',
    serviceName: 'Classic Fade',
    rating: 5,
    reviewText:
        'Pelayanan sangat ramah dan hasil potongannya rapi. Barber sangat detail dan tempat nyaman.',
    timeAgo: '2 Hari yang lalu',
    imageUrl: 'https://images.unsplash.com/photo-1599351431202-1e0f0137899a?w=300',
  ),
  ReviewModel(
    id: 'RVW-002',
    customerName: 'Raka Wijaya',
    initials: 'RW',
    serviceName: 'Premium Hair Spa',
    rating: 4,
    reviewText: 'Tempatnya oke banget, tapi tadi nunggu agak lama.',
    timeAgo: '1 Minggu yang lalu',
  ),
  ReviewModel(
    id: 'RVW-003',
    customerName: 'Adit Pratama',
    initials: 'AP',
    serviceName: 'Beard Trim',
    rating: 2,
    reviewText: 'Kurang teliti pas bagian kumis.',
    timeAgo: '2 Minggu yang lalu',
  ),
  ReviewModel(
    id: 'RVW-004',
    customerName: 'Fajar Nugroho',
    initials: 'FN',
    serviceName: 'Hair Coloring',
    rating: 5,
    reviewText:
        'Warnanya pas banget sesuai request, hasilnya keren! Pasti balik lagi.',
    timeAgo: '3 Hari yang lalu',
  ),
  ReviewModel(
    id: 'RVW-005',
    customerName: 'Dimas Setiawan',
    initials: 'DS',
    serviceName: 'Classic Fade',
    rating: 5,
    reviewText:
        'Sudah langganan di sini. Konsisten bagus, barbernya profesional dan ramah.',
    timeAgo: '5 Hari yang lalu',
  ),
  ReviewModel(
    id: 'RVW-006',
    customerName: 'Wahyu Hidayat',
    initials: 'WH',
    serviceName: 'Scalp Treatment',
    rating: 4,
    reviewText: 'Perawatannya nyaman, kulit kepala terasa segar setelahnya.',
    timeAgo: '1 Minggu yang lalu',
  ),
  ReviewModel(
    id: 'RVW-007',
    customerName: 'Rizky Maulana',
    initials: 'RM',
    serviceName: 'Premium Hot Towel Shave',
    rating: 3,
    reviewText: 'Lumayan, tapi hasilnya kurang rata di bagian pipi kiri.',
    timeAgo: '3 Minggu yang lalu',
  ),
  ReviewModel(
    id: 'RVW-008',
    customerName: 'Andi Prasetyo',
    initials: 'AN',
    serviceName: 'Classic Fade',
    rating: 5,
    reviewText: 'Top banget! Fadenya bersih, barbernya asik ngobrolnya juga.',
    timeAgo: '4 Hari yang lalu',
  ),
];

// ─── Distribution ─────────────────────────────────────────────────────────────

const _distribution = <int, int>{5: 190, 4: 38, 3: 10, 2: 5, 1: 2};

// ─── Page ─────────────────────────────────────────────────────────────────────

class ReviewRatingPage extends StatefulWidget {
  const ReviewRatingPage({super.key});

  @override
  State<ReviewRatingPage> createState() => _ReviewRatingPageState();
}

class _ReviewRatingPageState extends State<ReviewRatingPage> {
  static const _bg   = Color(0xFF0D0D0D);
  static const _gold = Color(0xFFFFC107);

  final _searchCtrl = TextEditingController();
  String _search      = '';
  int    _filterIndex = 0; // 0=Semua, 1=5★ … 5=1★

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<ReviewModel> get _filtered {
    int? starFilter = _filterIndex > 0 ? 6 - _filterIndex : null;
    return _dummyReviews.where((r) {
      final matchStar = starFilter == null || r.rating == starFilter;
      final matchSearch = _search.isEmpty ||
          r.customerName.toLowerCase().contains(_search.toLowerCase()) ||
          r.reviewText.toLowerCase().contains(_search.toLowerCase());
      return matchStar && matchSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: _bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Sticky header ──
          SliverAppBar(
            pinned: true,
            backgroundColor: _bg,
            elevation: 0,
            expandedHeight: 72,
            leading: IconButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 20),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 56, bottom: 14),
              title: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Ulasan & Rating',
                        style: TextStyle(
                          color: _gold,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.star_rounded, color: _gold, size: 16),
                    ],
                  ),
                  const Text(
                    'Lihat penilaian customer terhadap layanan barber',
                    style: TextStyle(
                      color: Color(0xFF8E8E93),
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(
                  height: 1, color: const Color(0xFF2C2C2E)),
            ),
          ),

          // ── Body ──
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Rating distribution card
                RatingDistribution(
                  distribution: _distribution,
                  averageRating: 4.8,
                  totalReviews: 245,
                ),
                const SizedBox(height: 16),

                // Mini stats
                Row(
                  children: const [
                    StatisticCard(
                      label: 'Customer Puas',
                      value: '98%',
                      icon: Icons.thumb_up_rounded,
                      iconColor: Color(0xFFFFC107),
                    ),
                    SizedBox(width: 12),
                    StatisticCard(
                      label: 'Review Bulan Ini',
                      value: '42',
                      icon: Icons.calendar_month_rounded,
                      iconColor: Colors.white,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Search bar
                ReviewSearchBar(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _search = v),
                ),
                const SizedBox(height: 16),

                // Filter bar
                RatingFilterBar(
                  selectedIndex: _filterIndex,
                  onChanged: (i) => setState(() => _filterIndex = i),
                ),
                const SizedBox(height: 24),

                // List
                if (filtered.isEmpty)
                  _buildEmpty()
                else
                  ...filtered.asMap().entries.map((e) => ReviewCard(
                        key: ValueKey(e.value.id),
                        review: e.value,
                        index: e.key,
                      )),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.star_outline_rounded,
                color: Color(0xFF3A3A3C), size: 48),
            SizedBox(height: 14),
            Text('Tidak ada ulasan ditemukan',
                style: TextStyle(
                    color: Color(0xFF8E8E93), fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
