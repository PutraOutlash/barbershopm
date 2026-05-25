import 'package:flutter/material.dart';

// 🔥 IMPORT SERVICE DAN WIDGET KITA
import '../services/booking_service.dart';
import '../services/bkg_service.dart';
import '../widgets/service_card_widget.dart';
import '../widgets/bkg_widgets.dart';

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

  // --- FUNGSI MENGAMBIL DATA ---
  Future<void> _fetchAllData() async {
    String clickedShopName = widget.shopData['shop_name']
        .toString()
        .toLowerCase();

    try {
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
        _showSnackBar(e.toString(), Colors.red);
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

  // --- FUNGSI MEMILIH WAKTU ---
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
          _showSnackBar("Waduh, jam tersebut sudah lewat!", Colors.redAccent);
          return;
        }
      }
      setState(
        () => selectedTime =
            "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}",
      );
    }
  }

  // --- FUNGSI SUBMIT PESANAN ---
  Future<void> _submitBooking() async {
    if (selectedService == null || selectedTime == null) {
      _showSnackBar("Mohon lengkapi layanan dan jam!", Colors.redAccent);
      return;
    }

    setState(() => isSubmitting = true);

    try {
      // Menggunakan fungsi pemformatan dari BkgService
      String formattedDate = BkgService.formatDateForApi(selectedDate);
      String formattedTime = BkgService.formatTimeForApi(selectedTime!);

      Map<String, String> requestData = {
        "barber_id": widget.shopData['user_id'].toString(),
        "service_id": selectedService!['id'].toString(),
        "booking_date": formattedDate,
        "booking_time": formattedTime,
        "notes": "Booking via Barber Mobile App",
      };

      await BookingService.submitBooking(requestData);
      setState(() => isSubmitting = false);

      _showSnackBar(
        "Pesanan terkirim! Silakan cek Tab Proses untuk menunggu ACC Kapster.",
        Colors.amber,
        isTextBlack: true,
      );
      if (mounted) Navigator.pop(context); // Kembali ke beranda
    } catch (e) {
      setState(() => isSubmitting = false);
      _showSnackBar(
        e.toString().replaceAll("Exception: ", ""),
        Colors.redAccent,
      );
    }
  }

  // --- HELPER UNTUK SNACKBAR ---
  void _showSnackBar(String message, Color color, {bool isTextBlack = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: isTextBlack ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: color,
      ),
    );
  }

  // --- UI HELPER ---
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
            // BAGIAN GAMBAR HEADER TOKO
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

            // KONTEN UTAMA FORM
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

                  // PEMILIH TANGGAL MENGGUNAKAN WIDGET BKG
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

                        return BkgDateCard(
                          date: date,
                          isSelected: isSelected,
                          namaHari: _namaHari[date.weekday],
                          namaBulan: _namaBulan[date.month],
                          onTap: () => setState(() {
                            selectedDate = date;
                            _fetchTimeSlots();
                          }),
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

                  // PEMILIH WAKTU MENGGUNAKAN WIDGET BKG
                  BkgTimeSelector(
                    selectedTime: selectedTime,
                    onTap: () => _pickTime(context),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ],
        ),
      ),

      // BOTTOM NAVIGATION (TOTAL BIAYA & SUBMIT)
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
                          "Estimasi Selesai: ${BkgService.calculateEndTime(selectedTime, selectedService)}",
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
                    "Rp ${BkgService.calculateTotal(selectedService)}",
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
