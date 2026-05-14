import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// 🔥 IMPORT HALAMAN, ASISTEN, DAN WIDGET KITA
import '../services/booking_service.dart';
import '../widgets/service_card_widget.dart';

class BookingPage extends StatefulWidget {
  final Map<String, dynamic> shopData;

  const BookingPage({super.key, required this.shopData});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  List services = [];
  List timeSlots = [];

  Map<String, dynamic>? selectedService;
  DateTime selectedDate = DateTime.now();
  String? selectedTime;

  bool isLoadingData = true;
  bool isSubmitting = false;

  late List<DateTime> upcomingDates;

  final List<String> _namaHari = [
    '',
    'SEN',
    'SEL',
    'RAB',
    'KAM',
    'JUM',
    'SAB',
    'MIN',
  ];
  final List<String> _namaBulan = [
    '',
    'JAN',
    'FEB',
    'MAR',
    'APR',
    'MEI',
    'JUN',
    'JUL',
    'AGU',
    'SEP',
    'OKT',
    'NOV',
    'DES',
  ];

  @override
  void initState() {
    super.initState();
    upcomingDates = List.generate(
      14,
      (index) => DateTime.now().add(Duration(days: index)),
    );
    _fetchAllData();
  }

  // --- FUNGSI MENGGUNAKAN ASISTEN ---
  Future<void> _fetchAllData() async {
    String clickedShopName = widget.shopData['shop_name']
        .toString()
        .toLowerCase();

    try {
      // Panggil asisten
      List allServices = await BookingService.getAllServices();

      if (mounted) {
        setState(() {
          services = allServices
              .where(
                (s) =>
                    (s['shop_name'] ?? '').toString().toLowerCase() ==
                    clickedShopName,
              )
              .toList();

          if (services.isEmpty) {
            services = allServices
                .where((s) => s['barber_id'] == widget.shopData['user_id'])
                .toList();
          }
          isLoadingData = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoadingData = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _fetchTimeSlots() async {
    if (selectedService == null) return;

    setState(() {
      timeSlots = [];
      selectedTime = null;
    });

    try {
      List slots = await BookingService.getTimeSlots();
      if (mounted) setState(() => timeSlots = slots);
    } catch (e) {
      debugPrint("Error slots: $e");
    }
  }

  Future<void> _submitBooking() async {
    if (selectedService == null || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Mohon lengkapi layanan dan jam!"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => isSubmitting = true);

    try {
      String formattedDate =
          "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
      String formattedTime = selectedTime!.length > 5
          ? selectedTime!.substring(0, 5)
          : selectedTime!;

      // Siapkan data, lalu suruh asisten yang kirim
      Map<String, String> requestData = {
        "barber_id": widget.shopData['user_id'].toString(),
        "service_id": selectedService!['id'].toString(),
        "booking_date": formattedDate,
        "booking_time": formattedTime,
        "notes": "Booking via Barber Mobile App",
      };

      var result = await BookingService.submitBooking(requestData);

      setState(() => isSubmitting = false);

      String? snapToken = result['snap_token'];

      // SKENARIO A: Bayar Langsung Midtrans
      if (snapToken != null && snapToken.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Mengalihkan ke pembayaran...",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.amber,
          ),
        );

        final Uri paymentUrl = Uri.parse(
          "https://app.sandbox.midtrans.com/snap/v2/vtweb/$snapToken",
        );
        if (await canLaunchUrl(paymentUrl)) {
          await launchUrl(paymentUrl, mode: LaunchMode.externalApplication);
          if (mounted) Navigator.pop(context);
        } else {
          throw Exception("Gagal membuka halaman pembayaran.");
        }
      }
      // SKENARIO B: Tunggu ACC Barber
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ?? "Pesanan terkirim! Menunggu konfirmasi.",
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.amber,
          ),
        );
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      setState(() => isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll("Exception: ", "")),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // --- LOGIKA LOKAL (UI & PERHITUNGAN) ---
  int _calculateTotal() {
    if (selectedService != null) {
      return int.parse(
        selectedService!['price']
            .toString()
            .replaceAll('.00', '')
            .split('.')[0],
      );
    }
    return 0;
  }

  String _calculateEndTime() {
    if (selectedTime == null || selectedService == null) return "--:--";
    int durationMinutes = selectedService!['duration'] ?? 30;
    List<String> timeParts = selectedTime!.split(':');
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

  Future<void> _pickTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.dark(
                primary: Colors.amber,
                onPrimary: Colors.black,
                surface: Color(0xFF1A1A1A),
                onSurface: Colors.white,
              ),
            ),
            child: child!,
          ),
        );
      },
    );

    if (picked != null) {
      DateTime now = DateTime.now();
      if (selectedDate.year == now.year &&
          selectedDate.month == now.month &&
          selectedDate.day == now.day) {
        if (picked.hour < now.hour ||
            (picked.hour == now.hour && picked.minute < now.minute)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Waduh, jam tersebut sudah lewat!"),
              backgroundColor: Colors.redAccent,
            ),
          );
          return;
        }
      }
      setState(
        () => selectedTime =
            "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}",
      );
    }
  }

  // --- UI WIDGET UTAMA ---
  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: Colors.amber,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoadingData) {
      return const Scaffold(
        backgroundColor: Color(0xFF121212),
        body: Center(child: CircularProgressIndicator(color: Colors.amber)),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 280,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                        "https://images.unsplash.com/photo-1585747860715-2ba37e788b70?w=800&q=80",
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  height: 280,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Color(0xFF121212),
                        Colors.transparent,
                        Colors.black45,
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 50,
                  left: 20,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Text(
                    widget.shopData['shop_name'].toString().toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("PILIH LAYANAN UTAMA"),
                  const SizedBox(height: 15),
                  services.isEmpty
                      ? const Text(
                          "Belum ada layanan.",
                          style: TextStyle(color: Colors.grey),
                        )
                      : Column(
                          // 🔥 MEMANGGIL WIDGET EKSTERNAL
                          children: services
                              .map(
                                (s) => ServiceCardWidget(
                                  service: s,
                                  isSelected: selectedService == s,
                                  onTap: () => setState(() {
                                    selectedService = s;
                                    _fetchTimeSlots();
                                  }),
                                ),
                              )
                              .toList(),
                        ),
                  const SizedBox(height: 30),
                  _buildSectionTitle("PILIH JADWAL & JAM"),
                  const SizedBox(height: 15),
                  SizedBox(
                    height: 90,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: upcomingDates.length,
                      itemBuilder: (context, index) {
                        DateTime date = upcomingDates[index];
                        bool isSelected =
                            date.year == selectedDate.year &&
                            date.month == selectedDate.month &&
                            date.day == selectedDate.day;
                        return GestureDetector(
                          onTap: () => setState(() {
                            selectedDate = date;
                            _fetchTimeSlots();
                          }),
                          child: Container(
                            width: 70,
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1A1A),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.amber
                                    : Colors.transparent,
                                width: isSelected ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _namaHari[date.weekday],
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.amber
                                        : Colors.grey,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "${date.day}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  _namaBulan[date.month],
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "PILIH JAM BUKING",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () => _pickTime(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selectedTime != null
                              ? Colors.amber
                              : Colors.white10,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            color: selectedTime != null
                                ? Colors.amber
                                : Colors.white54,
                          ),
                          const SizedBox(width: 15),
                          Text(
                            selectedTime ?? "Ketuk untuk tentukan jam...",
                            style: TextStyle(
                              color: selectedTime != null
                                  ? Colors.amber
                                  : Colors.white54,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          if (selectedTime != null)
                            const Icon(
                              Icons.check_circle,
                              color: Colors.amber,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          border: Border(top: BorderSide(color: Colors.white10)),
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (selectedTime != null && selectedService != null) ...[
                    Row(
                      children: [
                        const Icon(
                          Icons.timer_outlined,
                          color: Colors.amber,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "Estimasi Selesai: ${_calculateEndTime()}",
                          style: const TextStyle(
                            color: Colors.amber,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                  ],
                  const Text(
                    "TOTAL BIAYA",
                    style: TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Rp ${_calculateTotal()}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: isSubmitting ? null : _submitBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.black,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "KONFIRMASI",
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

