import 'package:barber_app/core/models/activity_model.dart';
import 'package:flutter/foundation.dart';

class HomeProvider extends ChangeNotifier {
  // ── Navigation ──────────────────────────────────────────────
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  void setIndex(int index) {
    if (_currentIndex == index) return;
    _currentIndex = index;
    notifyListeners();
  }

  // ── Barbershop Status ────────────────────────────────────────
  bool _isOpen = true;
  bool get isOpen => _isOpen;

  void toggleStatus() {
    _isOpen = !_isOpen;
    notifyListeners();
  }

  // ── Summary Data ─────────────────────────────────────────────
  final SummaryModel summary = const SummaryModel(
    totalRevenue: 'Rp 3.450K',
    growthPercent: '+12.5%',
    popularService: 'Classic Fade',
    weeklyData: [1.2, 0.8, 3.4, 1.8, 2.1, 0.5, 1.0],
    activeDayIndex: 2, // Rabu (index 2 dari S,S,R,K,U,S,M)
  );

  // ── Stats ─────────────────────────────────────────────────────
  final int newCustomers = 12;
  final int activeServices = 2;

  // ── Activities ────────────────────────────────────────────────
  final List<ActivityModel> activities = const [
    ActivityModel(
      id: '1',
      customerName: 'Budi Santoso',
      serviceName: 'Classic Fade + Beard Trim',
      status: ActivityStatus.selesai,
      price: 'Rp 150.000',
      time: '10:30 AM',
    ),
    ActivityModel(
      id: '2',
      customerName: 'Adit Pratama',
      serviceName: 'Premium Hair Sculpting',
      status: ActivityStatus.selesai,
      price: 'Rp 200.000',
      time: '09:15 AM',
    ),
    ActivityModel(
      id: '3',
      customerName: 'Raka Wijaya',
      serviceName: 'Hot Towel Shave',
      status: ActivityStatus.sedangBerjalan,
      price: '–',
      time: '11:00 AM',
    ),
  ];
}
