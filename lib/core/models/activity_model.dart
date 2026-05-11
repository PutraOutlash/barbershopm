enum ActivityStatus { selesai, sedangBerjalan }

class ActivityModel {
  final String id;
  final String customerName;
  final String serviceName;
  final ActivityStatus status;
  final String price;
  final String time;

  const ActivityModel({
    required this.id,
    required this.customerName,
    required this.serviceName,
    required this.status,
    required this.price,
    required this.time,
  });

  String get initials {
    final parts = customerName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return customerName.substring(0, 2).toUpperCase();
  }

  bool get isActive => status == ActivityStatus.sedangBerjalan;
}

class SummaryModel {
  final String totalRevenue;
  final String growthPercent;
  final String popularService;
  final List<double> weeklyData;
  final int activeDayIndex;

  const SummaryModel({
    required this.totalRevenue,
    required this.growthPercent,
    required this.popularService,
    required this.weeklyData,
    required this.activeDayIndex,
  });
}
