import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:barber_app/features/barber/view/history/history_page.dart';
import 'package:barber_app/features/barber/view/profile/profile_page.dart';
import 'package:barber_app/features/barber/view/booking/booking_page.dart';
import 'package:barber_app/features/barber/viewmodel/home_provider.dart';
import 'package:barber_app/features/barber/widgets/home/activity_item.dart';
import 'package:barber_app/features/barber/widgets/home/bottom_navbar.dart';
import 'package:barber_app/features/barber/widgets/home/header_section.dart';
import 'package:barber_app/features/barber/widgets/home/stats_card.dart';
import 'package:barber_app/features/barber/widgets/home/status_toggle_card.dart';
import 'package:barber_app/features/barber/widgets/home/summary_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const _pages = [
    _HomeContent(),
    BookingPage(),
    HistoryPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<HomeProvider>(
        builder: (context, provider, _) {
          return Stack(
            children: [
              // Konten halaman aktif
              IndexedStack(index: provider.currentIndex, children: _pages),

              // Bottom Navbar di atas semua
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: BottomNavBar(
                  currentIndex: provider.currentIndex,
                  onTap: provider.setIndex,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Konten tab Beranda ────────────────────────────────────────────────────────
class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, provider, _) {
        return SafeArea(
          bottom: false,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Header ──────────────────────────────────────
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: HeaderSection(),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),

              // ── Status Barbershop ────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: StatusToggleCard(
                    isOpen: provider.isOpen,
                    onToggle: provider.toggleStatus,
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // ── Ringkasan + Grafik ───────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SummaryCard(
                    popularService: provider.summary.popularService,
                    growthPercent: provider.summary.growthPercent,
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // ── Statistik Cepat ──────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: StatsRow(
                    newCustomers: provider.newCustomers,
                    activeServices: provider.activeServices,
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // ── Aktivitas Terbaru – header ───────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Text(
                        'Aktivitas Terbaru',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => provider.setIndex(2),
                        child: const Text(
                          'Lihat Semua',
                          style: TextStyle(
                            color: Color(0xFFFFC107),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              // ── Aktivitas Terbaru – list ─────────────────────
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                        ActivityItem(activity: provider.activities[index]),
                    childCount: provider.activities.length,
                  ),
                ),
              ),

              // Spacing bawah untuk navbar
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        );
      },
    );
  }
}
