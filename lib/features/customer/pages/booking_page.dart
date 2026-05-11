import 'package:barber_app/core/config/api.dart';
import 'package:barber_app/core/services/booking_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  // --- STATE VARIABLES ---
  List services = [];
  List barbers = [];
  List addons = [];
  List hairstyles = [];
  List timeSlots = [];

  Map<String, dynamic>? selectedService;
  Map<String, dynamic>? selectedBarber;
  Map<String, dynamic>? selectedHairstyle;
  List<Map<String, dynamic>> selectedAddons = [];

  DateTime selectedDate = DateTime.now(); // Default ke hari ini
  String? selectedTime;
  File? customPhoto;

  bool isLoadingData = true;
  bool isSubmitting = false;

  // Daftar 14 Hari ke depan untuk kalender horizontal
  late List<DateTime> upcomingDates;

  // Format Hari & Bulan Bahasa Indonesia
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
    // Generate 14 hari ke depan mulai dari hari ini
    upcomingDates = List.generate(
      14,
      (index) => DateTime.now().add(Duration(days: index)),
    );
    _fetchAllData();
  }

  // --- API FETCHERS ---
  Future<void> _fetchAllData() async {
    try {
      var resServ = await http.get(Uri.parse("${Api.baseUrl}/service/get.php"));
      var resBarb = await http.get(
        Uri.parse("${Api.baseUrl}/booking/barbers.php"),
      );
      var resAdd = await http.get(Uri.parse("${Api.baseUrl}/addon/get.php"));
      var resHair = await http.get(
        Uri.parse("${Api.baseUrl}/hairstyle/get.php"),
      );

      if (mounted) {
        setState(() {
          services = jsonDecode(resServ.body);
          barbers = jsonDecode(resBarb.body);
          addons = jsonDecode(resAdd.body);
          hairstyles = jsonDecode(resHair.body);
          isLoadingData = false;
        });
      }
    } catch (e) {
      print("Error fetching data: $e");
      // Fallback jika API mati agar layar tidak terus loading
      if (mounted) {
        setState(() => isLoadingData = false);
      }
    }
  }

  Future<void> _fetchTimeSlots() async {
    if (selectedBarber == null || selectedService == null) return;
    setState(() => timeSlots = []);

    int totalDuration = int.parse(selectedService!['duration'].toString());
    String dateStr =
        "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";

    try {
      var res = await http.get(
        Uri.parse(
          "${Api.baseUrl}/booking/slots.php?date=$dateStr&barber_id=${selectedBarber!['id']}&duration=$totalDuration",
        ),
      );

      if (mounted) {
        setState(() {
          timeSlots = jsonDecode(res.body);
          selectedTime = null;
        });
      }
    } catch (e) {
      print("Error fetching slots: $e");
    }
  }

  // --- LOGIC HELPERS ---
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        customPhoto = File(image.path);
        selectedHairstyle = null;
      });
    }
  }

  int _calculateTotal() {
    int total = 0;
    if (selectedService != null) {
      total += int.parse(selectedService!['price'].toString());
    }
    for (var addon in selectedAddons) {
      total += int.parse(addon['price'].toString());
    }
    return total;
  }

  Future<void> _submitBooking() async {
    if (selectedService == null ||
        selectedBarber == null ||
        selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Pilih Layanan, Barber, dan Jam!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isSubmitting = true);
    String dateStr =
        "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
    int totalDuration = int.parse(selectedService!['duration'].toString());
    DateTime startTime = DateTime.parse("2026-01-01 $selectedTime");
    DateTime endTime = startTime.add(Duration(minutes: totalDuration));
    String endStr =
        "${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}:00";

    var result = await BookingService.createBooking(
      userId: "1",
      serviceId: selectedService!['id'].toString(),
      barberId: selectedBarber!['id'].toString(),
      hairstyleId: selectedHairstyle?['id']?.toString(),
      imageFile: customPhoto,
      date: dateStr,
      startTime: selectedTime!,
      endTime: endStr,
      totalPrice: _calculateTotal().toString(),
    );

    setState(() => isSubmitting = false);

    if (result['status'] == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Booking Berhasil!"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal: ${result['message']}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // --- UI BUILDERS ---
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
      // 🔥 AppBar bawaan DIHAPUS, diganti dengan Stack gambar di body
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==========================================
            // 1. HEADER: FOTO TOKO & INFO (Konsep Jalan Tengah)
            // ==========================================
            Stack(
              children: [
                // Gambar Banner Toko
                Container(
                  height: 280,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      // Menggunakan gambar dummy barbershop premium
                      image: NetworkImage(
                        "https://images.unsplash.com/photo-1585747860715-2ba37e788b70?w=800&q=80",
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Efek Gradien Hitam di bawah gambar agar teks terbaca
                Container(
                  height: 280,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        const Color(0xFF121212),
                        const Color(0xFF121212).withOpacity(0.0),
                        const Color(
                          0xFF121212,
                        ).withOpacity(0.4), // Gradien atas untuk tombol back
                      ],
                    ),
                  ),
                ),
                // Tombol Back (Kembali ke Peta)
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
                        border: Border.all(color: Colors.white24),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                // Teks Nama Toko & Rating
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              "⭐ 4.8",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "Buka sampai 22:00",
                            style: TextStyle(
                              color: Colors.greenAccent,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Gentleman's Club Barbershop",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.grey, size: 14),
                          SizedBox(width: 4),
                          Text(
                            "Jl. Sudirman No. 10 (2 KM dari lokasimu)",
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // ==========================================
            // 2. KONTEN FORM BOOKING (Area Bawah Banner)
            // ==========================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- PILIH LAYANAN ---
                  _buildSectionTitle("PILIH LAYANAN UTAMA"),
                  const SizedBox(height: 15),
                  services.isEmpty
                      ? const Text(
                          "Belum ada layanan tersedia",
                          style: TextStyle(color: Colors.grey),
                        )
                      : Column(
                          children: services
                              .map((s) => _buildServiceCard(s))
                              .toList(),
                        ),
                  const SizedBox(height: 30),

                  // --- PILIH BARBER / KAPSTER ---
                  _buildSectionTitle("PILIH KAPSTER / BARBER"),
                  const SizedBox(height: 15),
                  barbers.isEmpty
                      ? const Text(
                          "Belum ada kapster tersedia",
                          style: TextStyle(color: Colors.grey),
                        )
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: barbers
                                .map((b) => _buildBarberCard(b))
                                .toList(),
                          ),
                        ),
                  const SizedBox(height: 30),

                  // --- JADWAL & JAM ---
                  _buildSectionTitle("PILIH JADWAL & JAM"),
                  const SizedBox(height: 15),
                  // Kalender Horizontal
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
                                const SizedBox(height: 5),
                                Text(
                                  "${date.day}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
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

                  // Grid Jam
                  if (selectedBarber == null || selectedService == null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        "Pilih Layanan & Kapster dulu untuk melihat jam yang kosong.",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    )
                  else if (timeSlots.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        "Tidak ada jam tersedia / Sedang memuat...",
                        style: TextStyle(color: Colors.amber, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    )
                  else
                    Wrap(
                      spacing: 15,
                      runSpacing: 15,
                      children: timeSlots.map((slot) {
                        bool isAvailable =
                            slot['available'] ?? false; // Pastikan tidak null
                        bool isSelected = selectedTime == slot['start'];
                        return InkWell(
                          onTap: isAvailable
                              ? () =>
                                    setState(() => selectedTime = slot['start'])
                              : null,
                          child: Container(
                            width:
                                (MediaQuery.of(context).size.width - 75) /
                                3, // Bagi 3 kolom
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.amber.withOpacity(0.1)
                                  : const Color(0xFF1A1A1A),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.amber
                                    : Colors.white10,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              slot['start'].toString(),
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.amber
                                    : (isAvailable
                                          ? Colors.white
                                          : Colors.white24),
                                fontWeight: FontWeight.bold,
                                decoration: isAvailable
                                    ? TextDecoration.none
                                    : TextDecoration
                                          .lineThrough, // Coret jam yang penuh
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                  const SizedBox(height: 35),

                  // --- REFERENSI POTONGAN / CUSTOM ---
                  _buildSectionTitle("REFERENSI GAYA (OPSIONAL)"),
                  const SizedBox(height: 15),
                  SizedBox(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount:
                          hairstyles.length +
                          1, // +1 untuk tombol upload custom
                      itemBuilder: (context, index) {
                        if (index == 0) return _buildCustomPhotoCard();
                        var style = hairstyles[index - 1];
                        bool isSelected =
                            selectedHairstyle == style && customPhoto == null;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedHairstyle = style;
                              customPhoto =
                                  null; // Batalkan foto custom jika milih katalog
                            });
                          },
                          child: Container(
                            width: 130,
                            margin: const EdgeInsets.only(right: 15),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isSelected
                                    ? Colors.amber
                                    : Colors.transparent,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  style['image'] != null
                                      ? Image.network(
                                          style['image'],
                                          fit: BoxFit.cover,
                                        )
                                      : Container(
                                          color: const Color(0xFF2A2A2A),
                                        ),
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.black.withOpacity(0.9),
                                          Colors.transparent,
                                        ],
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.center,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 12,
                                    left: 10,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (isSelected)
                                          const Text(
                                            "DIPILIH",
                                            style: TextStyle(
                                              color: Colors.amber,
                                              fontSize: 8,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                        Text(
                                          style['name']
                                              .toString()
                                              .toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 35),

                  // --- TAMBAHAN OPSIONAL ---
                  if (selectedService != null && addons.isNotEmpty) ...[
                    _buildSectionTitle("TAMBAHAN PERAWATAN"),
                    const SizedBox(height: 15),
                    ...addons.map((a) => _buildAddonCard(a)).toList(),
                  ],

                  const SizedBox(
                    height: 50,
                  ), // Spasi bawah agar tidak mentok Navbar
                ],
              ),
            ),
          ],
        ),
      ),

      // ==========================================
      // BOTTOM NAVBAR: TOTAL & TOMBOL KONFIRMASI
      // ==========================================
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
                  const Text(
                    "TOTAL BIAYA",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 5),
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
                        child: CircularProgressIndicator(color: Colors.black),
                      )
                    : const Text(
                        "KONFIRMASI JADWAL",
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- COMPONENT BUILDERS ---

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
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service) {
    bool isSelected = selectedService == service;
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "TREATMENT",
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 8,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  service['name'].toString().toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Rp ${service['price']}",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
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

  // Widget khusus untuk Kapster agar layoutnya menyamping rapi
  Widget _buildBarberCard(Map<String, dynamic> barber) {
    bool isSelected = selectedBarber == barber;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedBarber = barber;
          _fetchTimeSlots();
        });
      },
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.amber.withOpacity(0.1)
              : const Color(0xFF1A1A1A),
          border: Border.all(color: isSelected ? Colors.amber : Colors.white10),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: isSelected
                  ? Colors.amber
                  : const Color(0xFF2A2A2A),
              child: Icon(
                Icons.person,
                color: isSelected ? Colors.black : Colors.grey,
                size: 30,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              barber['name'],
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? Colors.amber : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddonCard(Map<String, dynamic> addon) {
    bool isSelected = selectedAddons.contains(addon);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            selectedAddons.remove(addon);
          } else {
            selectedAddons.add(addon);
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          border: Border.all(
            color: isSelected ? Colors.white30 : Colors.transparent,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  addon['name'].toString().toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "+ Rp ${addon['price']}",
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.add_circle_outline,
              color: isSelected ? Colors.amber : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomPhotoCard() {
    bool isSelected = customPhoto != null;
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: 130,
        margin: const EdgeInsets.only(right: 15),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          border: Border.all(
            color: isSelected ? Colors.amber : Colors.white10,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            fit: StackFit.expand,
            children: [
              customPhoto != null
                  ? Image.file(customPhoto!, fit: BoxFit.cover)
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo, color: Colors.amber, size: 35),
                        SizedBox(height: 10),
                        Text(
                          "UPLOAD\nFOTOMU",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
              if (isSelected)
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.9),
                        Colors.transparent,
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.center,
                    ),
                  ),
                ),
              if (isSelected)
                const Positioned(
                  bottom: 12,
                  left: 10,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "DIPILIH",
                        style: TextStyle(
                          color: Colors.amber,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        "CUSTOM FOTO",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
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