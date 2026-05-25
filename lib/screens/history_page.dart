import 'package:flutter/material.dart';

// 🔥 IMPORT SERVICE DAN WIDGETS KITA
import '../services/history_service.dart';
import '../widgets/history_widgets.dart'; // Tetap diimport jika HistoryCardWidget (Tab 3) ada di sini
import '../widgets/hst_widgets.dart'; // Import modular buatan kita

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  // Dibuat publik (tanpa underscore) agar bisa direfresh dari MainPage
  State<HistoryPage> createState() => HistoryPageState();
}

class HistoryPageState extends State<HistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool isLoading = true;
  List<Map<String, dynamic>> processTickets = [];
  List<Map<String, dynamic>> activeTickets = [];
  List<Map<String, dynamic>> pastHistories = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadHistoryData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Fungsi publik untuk me-refresh data dari halaman lain (seperti MainPage)
  void refreshData() {
    _loadHistoryData();
  }

  Future<void> _loadHistoryData() async {
    setState(() => isLoading = true);

    try {
      var data = await HistoryService.fetchHistories();

      if (mounted) {
        setState(() {
          processTickets = data['processTickets'] ?? [];
          activeTickets = data['activeTickets'] ?? [];
          pastHistories = data['pastHistories'] ?? [];
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
          indicatorColor: goldAccent,
          labelColor: goldAccent,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
          tabs: const [
            Tab(text: "PROSES"),
            Tab(text: "AKTIF"),
            Tab(text: "SELESAI"),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: goldAccent))
          : TabBarView(
              controller: _tabController,
              children: [
                // ==============================
                // TAB 1: PROSES (Nunggu ACC / Bayar)
                // ==============================
                processTickets.isEmpty
                    ? const HstEmptyState(
                        message: "Belum ada pesanan yang diproses.",
                        icon: Icons.hourglass_empty,
                      )
                    : RefreshIndicator(
                        color: goldAccent,
                        backgroundColor: darkCard,
                        onRefresh: _loadHistoryData,
                        child: ListView.builder(
                          padding: const EdgeInsets.only(
                            left: 20,
                            right: 20,
                            top: 20,
                            bottom: 120,
                          ),
                          itemCount: processTickets.length,
                          itemBuilder: (context, index) {
                            return HstProcessCard(
                              ticket: processTickets[index],
                              onRefresh:
                                  refreshData, // Panggil fungsi refresh setelah bayar
                            );
                          },
                        ),
                      ),

                // ==============================
                // TAB 2: AKTIF (Sudah Lunas)
                // ==============================
                activeTickets.isEmpty
                    ? const HstEmptyState(
                        message: "Belum ada tiket aktif.",
                        icon: Icons.confirmation_number_outlined,
                      )
                    : RefreshIndicator(
                        color: goldAccent,
                        backgroundColor: darkCard,
                        onRefresh: _loadHistoryData,
                        child: ListView.builder(
                          padding: const EdgeInsets.only(
                            left: 20,
                            right: 20,
                            top: 20,
                            bottom: 120,
                          ),
                          itemCount: activeTickets.length,
                          itemBuilder: (context, index) {
                            return HstActiveTicketCard(
                              ticket: activeTickets[index],
                            );
                          },
                        ),
                      ),

                // ==============================
                // TAB 3: SELESAI (Riwayat Lama)
                // ==============================
                pastHistories.isEmpty
                    ? const HstEmptyState(
                        message: "Belum ada riwayat pesanan.",
                        icon: Icons.history,
                      )
                    : RefreshIndicator(
                        color: goldAccent,
                        backgroundColor: darkCard,
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
                            // HistoryCardWidget adalah bawaan asli dari file kamu
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
}
