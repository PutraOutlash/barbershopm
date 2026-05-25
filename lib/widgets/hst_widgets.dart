import 'package:flutter/material.dart';
import '../services/hst_service.dart';

const Color goldAccent = Color(0xFFD4AF67);
const Color darkCard = Color(0xFF1C1C1E);
const Color subtleText = Color(0xFF8E8E93);

// ========================================================
// 1. WIDGET KARTU PROSES (MENUNGGU ACC / BAYAR)
// ========================================================
class HstProcessCard extends StatelessWidget {
  final Map<String, dynamic> ticket;
  final VoidCallback onRefresh;

  const HstProcessCard({
    super.key,
    required this.ticket,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    bool isWaitingAcc = ticket['payment_state'] == 'WAITING_ACC';

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: goldAccent.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                ticket['shop_name'].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isWaitingAcc
                      ? Colors.grey.withOpacity(0.2)
                      : Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isWaitingAcc ? "NUNGGU ACC" : "SIAP DIBAYAR",
                  style: TextStyle(
                    color: isWaitingAcc ? Colors.grey : Colors.amber,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white10, height: 25, thickness: 1),
          Row(
            children: [
              const Icon(Icons.content_cut, color: Colors.grey, size: 16),
              const SizedBox(width: 8),
              Text(
                ticket['service'],
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_month, color: Colors.grey, size: 16),
              const SizedBox(width: 8),
              Text(
                "${ticket['date']} • Jam ${ticket['time']}",
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // TOMBOL BAYAR / NUNGGU KAPSTER
          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isWaitingAcc ? Colors.grey[800] : goldAccent,
                foregroundColor: isWaitingAcc ? Colors.grey : Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: isWaitingAcc
                  ? null
                  : () async {
                      String? snapToken = ticket['snap_token'];
                      if (snapToken != null && snapToken.isNotEmpty) {
                        try {
                          await HstService.launchMidtransPayment(snapToken);

                          // Refresh data setelah tutup Midtrans
                          Future.delayed(const Duration(seconds: 2), () {
                            onRefresh();
                          });
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(e.toString()),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Token Midtrans tidak ditemukan."),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
              child: Text(
                isWaitingAcc
                    ? "MENUNGGU KONFIRMASI KAPSTER"
                    : "BAYAR SEKARANG - Rp ${ticket['total']}",
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ========================================================
// 2. WIDGET KARTU AKTIF (DESAIN TIKET BIOSKOP)
// ========================================================
class HstActiveTicketCard extends StatelessWidget {
  final Map<String, dynamic> ticket;

  const HstActiveTicketCard({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: goldAccent.withOpacity(0.5), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // BAGIAN ATAS (INFO PESANAN)
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        ticket['shop_name'].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "LUNAS",
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_month,
                      color: goldAccent,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "${ticket['date']} • Jam ${ticket['time']}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.content_cut, color: goldAccent, size: 18),
                    const SizedBox(width: 10),
                    Text(
                      ticket['service'],
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // GARIS PUTUS-PUTUS (EFEK SOBEKAN TIKET)
          Row(
            children: [
              Container(
                width: 15,
                height: 30,
                decoration: const BoxDecoration(
                  color: Color(0xFF121212),
                  borderRadius: BorderRadius.horizontal(
                    right: Radius.circular(30),
                  ),
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Flex(
                      direction: Axis.horizontal,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(
                        (constraints.constrainWidth() / 10).floor(),
                        (index) => const SizedBox(
                          width: 5,
                          height: 1.5,
                          child: DecoratedBox(
                            decoration: BoxDecoration(color: Colors.white24),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                width: 15,
                height: 30,
                decoration: const BoxDecoration(
                  color: Color(0xFF121212),
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(30),
                  ),
                ),
              ),
            ],
          ),

          // BAGIAN BAWAH (QR CODE)
          Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              children: [
                const Text(
                  "KODE BOOKING",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  ticket['order_id'],
                  style: const TextStyle(
                    color: goldAccent,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 25),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.qr_code_2,
                    size: 100,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Tunjukkan QR Code ini kepada Kapster\nsaat Anda tiba di Barbershop.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: subtleText,
                    fontSize: 11,
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
}

// ========================================================
// 3. WIDGET STATE KOSONG
// ========================================================
class HstEmptyState extends StatelessWidget {
  final String message;
  final IconData icon;

  const HstEmptyState({super.key, required this.message, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey.withOpacity(0.3)),
          const SizedBox(height: 20),
          Text(
            message,
            style: const TextStyle(
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
