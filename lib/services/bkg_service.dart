class BkgService {
  // 🔥 Hitung total harga
  static int calculateTotal(Map<String, dynamic>? selectedService) {
    if (selectedService != null) {
      return int.parse(
        selectedService['price'].toString().replaceAll('.00', '').split('.')[0],
      );
    }
    return 0;
  }

  // 🔥 Hitung estimasi jam selesai
  static String calculateEndTime(
    String? selectedTime,
    Map<String, dynamic>? selectedService,
  ) {
    if (selectedTime == null || selectedService == null) return "--:--";

    int durationMinutes = selectedService['duration'] ?? 30;
    List<String> timeParts = selectedTime.split(':');

    DateTime startTime = DateTime(
      2024,
      1,
      1,
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );

    DateTime endTime = startTime.add(Duration(minutes: durationMinutes));
    return "${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}";
  }

  // 🔥 Format Tanggal untuk dikirim ke API (YYYY-MM-DD)
  static String formatDateForApi(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  // 🔥 Format Jam untuk dikirim ke API (HH:mm)
  static String formatTimeForApi(String time) {
    return time.length > 5 ? time.substring(0, 5) : time;
  }
}
