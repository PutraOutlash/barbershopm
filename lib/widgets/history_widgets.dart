import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

// ==========================================
// 1. WIDGET TIKET AKTIF (QR CODE)
// ==========================================
class ActiveTicketWidget extends StatelessWidget {
  final Map<String, dynamic> ticket;

  const ActiveTicketWidget({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
                        ticket['status'],
                        style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    Text(
                      ticket['order_id'],
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
                  ticket['shop_name'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  ticket['address'],
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),

          // Garis Putus-putus
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

          // Badan Tiket & QR Code
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFF1C1C1E),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildTicketInfo(
                        Icons.calendar_month,
                        "Tanggal",
                        ticket['date'],
                      ),
                    ),
                    Expanded(
                      child: _buildTicketInfo(
                        Icons.access_time,
                        "Jam",
                        ticket['time'],
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
                        ticket['barber'],
                      ),
                    ),
                    Expanded(
                      child: _buildTicketInfo(
                        Icons.content_cut,
                        "Layanan",
                        ticket['service'],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                const Divider(color: Colors.white10, thickness: 1),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: QrImageView(
                    data: ticket['order_id'],
                    version: QrVersions.auto,
                    size: 100.0,
                    backgroundColor: Colors.white,
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
          children: List.generate(
            dashCount,
            (_) => const SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: Colors.white24),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ==========================================
// 2. WIDGET KARTU RIWAYAT LALU
// ==========================================
class HistoryCardWidget extends StatelessWidget {
  final Map<String, dynamic> history;

  const HistoryCardWidget({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
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
          Text(
            "Rp ${history['total']}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
