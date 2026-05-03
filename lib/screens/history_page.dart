import 'package:flutter/material.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // ==========================================
  // DUMMY DATA UNTUK VISUALISASI
  // Nanti data ini diganti dari fetch API/Database
  // ==========================================

  // Data Tiket Aktif (Jika kosong, ganti isHasActiveTicket jadi false)
  bool isHasActiveTicket = true;
  final Map<String, dynamic> activeTicket = {
    "order_id": "ORD-092",
    "shop_name": "Gentleman's Club Barbershop",
    "address": "Jl. Sudirman No. 10",
    "date": "Sabtu, 02 Mei 2026",
    "time": "10:00 - 10:45 AM",
    "barber": "Kapster Andi",
    "service": "Premium Haircut",
    "total": "Rp 50.000",
    "status": "MENUNGGU GILIRAN",
  };

  // Data Riwayat Masa Lalu
  final List<Map<String, dynamic>> pastHistories = [
    {
      "order_id": "ORD-045",
      "shop_name": "Barber Bros",
      "date": "14 Apr 2026",
      "service": "Classic Cut",
      "price": "50.000",
      "status": "SELESAI",
      "color": Colors.green,
    },
    {
      "order_id": "ORD-012",
      "shop_name": "Gentleman's Club Barbershop",
      "date": "20 Mar 2026",
      "service": "Hair & Beard",
      "price": "75.000",
      "status": "SELESAI",
      "color": Colors.green,
    },
    {
      "order_id": "ORD-008",
      "shop_name": "Gentleman's Club Barbershop",
      "date": "05 Feb 2026",
      "service": "Premium Haircut",
      "price": "50.000",
      "status": "DIBATALKAN",
      "color": Colors.red,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        title: const Text(
          "PESANAN SAYA",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.amber,
          labelColor: Colors.amber,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
          tabs: const [
            Tab(text: "AKTIF"),
            Tab(text: "RIWAYAT"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: TIKET AKTIF
          _buildActiveTab(),
          // TAB 2: RIWAYAT MASA LALU
          _buildHistoryTab(),
        ],
      ),
    );
  }

  // ==========================================
  // WIDGET: TAB TIKET AKTIF
  // ==========================================
  Widget _buildActiveTab() {
    // Jika tidak ada tiket aktif
    if (!isHasActiveTicket) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: 80,
              color: Colors.grey.withOpacity(0.3),
            ),
            const SizedBox(height: 20),
            const Text(
              "Belum ada jadwal cukur nih.",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Yuk cari barbershop di beranda!",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      );
    }

    // Jika ada tiket aktif (Desain Tiket Digital)
    return SingleChildScrollView(
      // Padding bawah besar agar tidak tertutup custom floating navbar
      padding: const EdgeInsets.only(left: 20, right: 20, top: 30, bottom: 120),
      child: Column(
        children: [
          // Kepala Tiket
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFF1C1C1E),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        activeTicket['status'],
                        style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    Text(
                      "#${activeTicket['order_id']}",
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  activeTicket['shop_name'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  activeTicket['address'],
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),

          // Garis Putus-putus Tiket
          Container(
            color: const Color(0xFF1C1C1E),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Color(0xFF121212),
                    borderRadius: BorderRadius.horizontal(
                      right: Radius.circular(20),
                    ),
                  ),
                ),
                Expanded(child: _buildDashedLine()),
                Container(
                  width: 10,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Color(0xFF121212),
                    borderRadius: BorderRadius.horizontal(
                      left: Radius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Badan Tiket
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFF1C1C1E),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Info Grid
                Row(
                  children: [
                    Expanded(
                      child: _buildTicketInfo(
                        Icons.calendar_month,
                        "Tanggal",
                        activeTicket['date'],
                      ),
                    ),
                    Expanded(
                      child: _buildTicketInfo(
                        Icons.access_time,
                        "Jam",
                        activeTicket['time'],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildTicketInfo(
                        Icons.face,
                        "Kapster",
                        activeTicket['barber'],
                      ),
                    ),
                    Expanded(
                      child: _buildTicketInfo(
                        Icons.content_cut,
                        "Layanan",
                        activeTicket['service'],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                const Divider(color: Colors.white10, thickness: 1),
                const SizedBox(height: 20),

                // QR Code Dummy
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.qr_code_2,
                    size: 80,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  "Tunjukkan QR Code atau ID Pesanan ini\nkepada kasir saat tiba di lokasi.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // WIDGET: TAB RIWAYAT
  // ==========================================
  Widget _buildHistoryTab() {
    return ListView.builder(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 120),
      itemCount: pastHistories.length,
      itemBuilder: (context, index) {
        var history = pastHistories[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    history['date'],
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  Text(
                    history['status'],
                    style: TextStyle(
                      color: history['color'],
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                history['shop_name'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                history['service'],
                style: const TextStyle(color: Colors.amber, fontSize: 12),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Rp ${history['price']}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Tombol Pesan Lagi hanya aktif jika status SELESAI
                  if (history['status'] == "SELESAI")
                    ElevatedButton(
                      onPressed: () {
                        // Nanti diarahkan ke BookingPage dengan data toko ini
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2C2C2E),
                        foregroundColor: Colors.amber,
                        minimumSize: const Size(60, 30),
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                      ),
                      child: const Text(
                        "PESAN LAGI",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // --- HELPER UNTUK DESAIN TIKET ---
  Widget _buildTicketInfo(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.amber, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.grey, fontSize: 10),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDashedLine() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 5.0;
        const dashHeight = 1.5;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return const SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: Colors.white24),
              ),
            );
          }),
        );
      },
    );
  }
}
