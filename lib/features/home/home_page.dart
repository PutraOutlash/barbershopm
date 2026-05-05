import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../transaction/transaction_page.dart';
import '../history/history_page.dart';
import '../profile/profile_page.dart';
import 'home_provider.dart';
import 'widgets/activity_item.dart';
import 'widgets/bottom_navbar.dart';
import 'widgets/header_section.dart';
import 'widgets/stats_card.dart';
import 'widgets/status_toggle_card.dart';
import 'widgets/summary_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const _pages = [
    _HomeContent(),
    TransactionPage(),
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
              IndexedStack(
                index: provider.currentIndex,
                children: _pages,
              ),

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
                  child: SummaryCard(summary: provider.summary),
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
                    (context, index) => ActivityItem(
                      activity: provider.activities[index],
                    ),
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
