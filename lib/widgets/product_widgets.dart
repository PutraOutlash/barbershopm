import 'package:flutter/material.dart';

// ==========================================
// 1. WIDGET JIKA RAK PRODUK KOSONG
// ==========================================
class EmptyProductWidget extends StatelessWidget {
  final String shopName;

  const EmptyProductWidget({super.key, required this.shopName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1E),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.production_quantity_limits_rounded,
                size: 80,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 35),
            const Text(
              "Rak Masih Kosong",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              "Saat ini, $shopName belum menyediakan amunisi perawatan rambut (Pomade, Powder, dll) di etalase digital mereka.\n\nSilakan cek kembali di lain waktu!",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 40),
            OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back,
                size: 16,
                color: Color(0xFFE5C07B),
              ),
              label: const Text(
                "KEMBALI KE RADAR",
                style: TextStyle(
                  color: Color(0xFFE5C07B),
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                side: const BorderSide(color: Color(0xFFE5C07B)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 2. WIDGET KARTU PRODUK (SATUAN)
// ==========================================
class ProductCardWidget extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductCardWidget({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2E),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(15),
                ),
                image: product['image_url'] != null
                    ? DecorationImage(
                        image: NetworkImage(product['image_url']),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: product['image_url'] == null
                  ? const Center(child: Icon(Icons.image, color: Colors.grey))
                  : null,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'] ?? 'Nama Produk',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Text(
                  "Rp ${product['price'] ?? '0'}",
                  style: const TextStyle(
                    color: Color(0xFFE5C07B),
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
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
