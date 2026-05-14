import 'package:flutter/material.dart';

// 🔥 IMPORT SERVICE DAN WIDGETS KITA
import '../services/history_service.dart';
import '../widgets/history_widgets.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool isLoading = true;
  Map<String, dynamic>? activeTicket;
  List<Map<String, dynamic>> pastHistories = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadHistoryData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // --- FUNGSI MENGGUNAKAN ASISTEN ---
  Future<void> _loadHistoryData() async {
    setState(() => isLoading = true);

    try {
      // Panggil asisten untuk ambil & merapikan data
      var data = await HistoryService.fetchHistories();

      if (mounted) {
        setState(() {
          activeTicket = data['activeTicket'];
          pastHistories = data['pastHistories'];
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        debugPrint("Error Fetch History: $e");
      }
    }
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.amber))
          : TabBarView(
              controller: _tabController,
              children: [
                // TAB 1: TIKET AKTIF
                activeTicket == null
                    ? _buildEmptyActiveTicket()
                    : ActiveTicketWidget(ticket: activeTicket!),

                // TAB 2: RIWAYAT LALU
                pastHistories.isEmpty
                    ? const Center(
                        child: Text(
                          "Belum ada riwayat pesanan.",
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : RefreshIndicator(
                        color: Colors.amber,
                        backgroundColor: const Color(0xFF1C1C1E),
                        onRefresh: _loadHistoryData,
                        child: ListView.builder(
                          padding: const EdgeInsets.only(
                            left: 20,
                            right: 20,
                            top: 20,
                            bottom: 120,
                          ),
                          itemCount: pastHistories.length,
                          itemBuilder: (context, index) {
                            return HistoryCardWidget(
                              history: pastHistories[index],
                            );
                          },
                        ),
                      ),
              ],
            ),
    );
  }

  // UI Kecil Jika Tiket Aktif Kosong
  Widget _buildEmptyActiveTicket() {
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
            "Belum ada jadwal aktif nih.",
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
}
