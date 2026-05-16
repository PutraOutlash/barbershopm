import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:barber_app/core/config/api.dart';

// 🔥 SESUAIKAN DENGAN STRUKTUR FOLDER KAMU

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
  File? customPhoto;

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

  Future<void> _pickTime(BuildContext context) async {

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(alwaysUse24HourFormat: true), // Format 24 jam
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.dark(
                primary: Colors.amber, // Warna jarum jam
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

      // 🔥 VALIDASI: Cek jika pilih jam yang sudah lewat di hari yang sama
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

      setState(() {
        // Simpan dalam format HH:mm untuk dikirim ke Laravel
        selectedTime =
            "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _fetchAllData() async {
    String clickedShopName = widget.shopData['shop_name']
        .toString()
        .toLowerCase();

    try {
      var resServ = await http
          .get(Uri.parse("${Api.baseUrl}/services"))
          .timeout(const Duration(seconds: 5));

      if (resServ.statusCode == 200) {
        List allServices = jsonDecode(resServ.body);

        if (mounted) {
          setState(() {
            // Memfilter layanan yang tersedia di toko yang diklik
            services = allServices
                .where(
                  (s) =>
                      (s['shop_name'] ?? '').toString().toLowerCase() ==
                      clickedShopName,
                )
                .toList();

            // Fallback jika API belum mengirim shop_name
            if (services.isEmpty) {
              services = allServices
                  .where((s) => s['barber_id'] == widget.shopData['user_id'])
                  .toList();
            }

            isLoadingData = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoadingData = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Gagal menarik data dari server."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _fetchTimeSlots() async {
    // 🔥 Pengecekan kapster dihapus, jam langsung muncul setelah milih layanan
    if (selectedService == null) return;

    setState(() {
      timeSlots = [];
      selectedTime = null;
    });
    try {
      var res = await http
          .get(Uri.parse("${Api.baseUrl}/slots"))
          .timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        setState(() => timeSlots = jsonDecode(res.body));
      }
    } catch (e) {
      debugPrint("Error slots: $e");
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => customPhoto = File(image.path));
  }

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

  // Fungsi menghitung perkiraan jam selesai berdasarkan durasi layanan
  String _calculateEndTime() {
    if (selectedTime == null || selectedService == null) return "--:--";

    // Ambil durasi dari API, default 30 menit jika kosong
    int durationMinutes = selectedService!['duration'] ?? 30;

    // Pecah jam yang dipilih (misal "09:00" dipisah jadi 9 dan 0)
    List<String> timeParts = selectedTime!.split(':');
    int hours = int.parse(timeParts[0]);
    int minutes = int.parse(timeParts[1]);

    // Gunakan fungsi DateTime Dart untuk menjumlahkan waktu dengan mudah
    DateTime startTime = DateTime(2024, 1, 1, hours, minutes);
    DateTime endTime = startTime.add(Duration(minutes: durationMinutes));

    // Format kembali menjadi teks "HH:mm"
    String endHour = endTime.hour.toString().padLeft(2, '0');
    String endMinute = endTime.minute.toString().padLeft(2, '0');

    return "$endHour:$endMinute";
  }

  Future<void> _submitBooking() async {
    // 1. Validasi
    if (selectedService == null ||
        selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Mohon lengkapi layanan, tanggal, dan jam!",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => isSubmitting = true);

    try {
      // 2. Ambil Token
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      if (token == null) {
        throw Exception("Kamu belum login! Silakan login terlebih dahulu.");
      }

      // 3. Format Data
      String formattedDate =
          "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
      String formattedTime = selectedTime!.length > 5
          ? selectedTime!.substring(0, 5)
          : selectedTime!;

      Map<String, String> requestBody = {
        "barber_id": widget.shopData['user_id'].toString(),
        "service_id": selectedService!['id'].toString(),
        "booking_date": formattedDate,
        "booking_time": formattedTime,
        "notes": "Booking via Barber Mobile App",
      };

      // 4. Tembak API
      var response = await http.post(
        Uri.parse("${Api.baseUrl}/book"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: requestBody,
      );

      setState(() => isSubmitting = false);
      var result = jsonDecode(response.body);

      // 5. Eksekusi Hasil (Kode yang kamu tanyakan)
      // 5. Cek Hasil dari Laravel
      if (response.statusCode == 201) {
        // Ambil token secara aman (kasih tanda tanya (?) agar tidak error kalau kosong)
        String? snapToken = result['snap_token'];

        // SKENARIO A: Kalau ada Token (Alur Bayar Langsung Midtrans)
        if (snapToken != null && snapToken.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Pesanan berhasil! Mengalihkan ke pembayaran...",
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
            if (mounted) Navigator.pop(context); // Kembali ke beranda
          } else {
            throw Exception("Gagal membuka halaman pembayaran.");
          }
        }
        // SKENARIO B: Kalau TIDAK ada Token (Alur Tunggu ACC Barber)
        else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result['message'] ??
                    "Pesanan terkirim! Menunggu konfirmasi Barber.",
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: Colors.amber,
            ),
          );
          if (mounted) Navigator.pop(context); // Langsung kembali ke beranda
        }
      } else {
        // Tampilkan Error Asli dari Laravel
        throw Exception("Error: ${result['error'] ?? result['message']}");
      }
    } catch (e) {
      // Jika internet putus atau error lainnya
      setState(() => isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
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
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        const Color(0xFF121212),
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
                          children: services
                              .map((s) => _buildServiceCard(s))
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
                          onTap: () {
                            setState(() {
                              selectedDate = date;
                              _fetchTimeSlots();
                            });
                          },
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

                  // ✅ PASTE KODE INI SEBAGAI GANTINYA:
                  const Text(
                    "PILIH JAM BUKING",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Tombol Time Picker Baru
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
              // Bagian Info Biaya & Waktu
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔥 Teks Estimasi Waktu Baru
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

              // Tombol Konfirmasi
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

  Widget _buildServiceCard(Map<String, dynamic> service) {
    bool isSelected = selectedService == service;
    String priceDisplay =
        service['price']?.toString().replaceAll('.00', '').split('.')[0] ?? '0';

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedService = service;
          _fetchTimeSlots();
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.amber.withOpacity(0.05)
              : const Color(0xFF1A1A1A),
          border: Border.all(color: isSelected ? Colors.amber : Colors.white10),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "TREATMENT",
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    service['name'].toString().toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Rp $priceDisplay",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.amber : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.amber : Colors.grey,
                ),
              ),
              child: Icon(
                Icons.check,
                color: isSelected ? Colors.black : Colors.transparent,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
