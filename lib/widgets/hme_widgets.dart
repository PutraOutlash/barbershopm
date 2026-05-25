import 'package:flutter/material.dart';
import '../screens/booking_page.dart';

// ==========================================
// 1. WIDGET KARTU MENU (Katalog & Produk)
// ==========================================
class HmeMenuCardWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const HmeMenuCardWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFF222222),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 15),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 8,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 2. WIDGET KARTU LAYANAN POPULER
// ==========================================
class HmePopularServiceCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const HmePopularServiceCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        color: const Color(0xFF222222),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF333333),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(10),
                ),
                image:
                    (data['image_url'] != null &&
                        data['image_url'].toString().isNotEmpty)
                    ? DecorationImage(
                        image: NetworkImage(data['image_url']),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child:
                  (data['image_url'] == null ||
                      data['image_url'].toString().isEmpty)
                  ? const Center(
                      child: Icon(Icons.cut, color: Colors.grey, size: 40),
                    )
                  : null,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['name'] ?? "Layanan",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  data['shop_name'] ?? "Barbershop",
                  style: const TextStyle(
                    color: Color(0xFFE5C07B),
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  "Rp ${data['price'] ?? '0'}",
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 4. WIDGET DETAIL TOKO DI BAWAH PETA
// ==========================================
class HmeShopInfoWidget extends StatelessWidget {
  final Map<String, dynamic>? selectedShop;
  final VoidCallback onRouteTap;

  const HmeShopInfoWidget({
    super.key,
    required this.selectedShop,
    required this.onRouteTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white10),
      ),
      child: selectedShop == null
          ? const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.radar, color: Colors.amber, size: 35),
                SizedBox(height: 10),
                Text(
                  "Pilih barbershop di peta",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Ketuk icon pin untuk melihat ketersediaan",
                  style: TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: selectedShop!['status'] == 'BUKA'
                            ? Colors.greenAccent
                            : Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      selectedShop!['status'],
                      style: TextStyle(
                        color: selectedShop!['status'] == 'BUKA'
                            ? Colors.greenAccent
                            : Colors.redAccent,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: selectedShop!['live_status'] == 'SEDANG MENCUKUR'
                            ? Colors.orange.withOpacity(0.2)
                            : Colors.blue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        selectedShop!['live_status'],
                        style: TextStyle(
                          color:
                              selectedShop!['live_status'] == 'SEDANG MENCUKUR'
                              ? Colors.orange
                              : Colors.blue,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  selectedShop!['shop_name'].toString().toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFFE5C07B),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Icons.storefront,
                      color: Colors.white54,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Status: ${selectedShop!['status']}",
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      color: Colors.white54,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Jam Operasional: ${selectedShop!['operational_hours']}",
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: selectedShop!['status'] == 'BUKA'
                        ? () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  BookingPage(shopData: selectedShop!),
                            ),
                          )
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE5C07B),
                      disabledBackgroundColor: Colors.white10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      selectedShop!['status'] == 'BUKA'
                          ? "PESAN JADWAL DI SINI"
                          : "TOKO SEDANG TUTUP",
                      style: TextStyle(
                        color: selectedShop!['status'] == 'BUKA'
                            ? Colors.black
                            : Colors.white24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: onRouteTap,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFE5C07B),
                      side: const BorderSide(
                        color: Color(0xFFE5C07B),
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.directions_car, size: 20),
                    label: const Text(
                      "RUTE SEKARANG",
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
