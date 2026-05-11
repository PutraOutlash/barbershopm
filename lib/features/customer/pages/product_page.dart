import 'package:barber_app/core/services/product_service.dart';
import 'package:flutter/material.dart';

class ProductPage extends StatefulWidget {
  // Menerima data nama toko dari Beranda
  final String? shopName;

  const ProductPage({super.key, this.shopName});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.amber),
        title: Text(
          widget.shopName != null ? "KATALOG PRODUK" : "TOKO PRODUK",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // Pop-up informasi konsep etalase
              _showInfoDialog(context);
            },
          ),
          const SizedBox(width: 10),
        ],
      ),

      body: FutureBuilder<List<dynamic>>(
        future: ProductService.getProducts(),
        builder: (context, snapshot) {
          // 1. Jika masih loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.amber),
            );
          }

          // 2. Jika terjadi error
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.redAccent,
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Gagal memuat produk.\n${snapshot.error}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // 3. Filter produk berdasarkan toko yang dipilih di Peta
          // Asumsi: Databasemu memiliki field 'shop' atau 'barber_name'
          var allProducts = snapshot.data ?? [];
          var products = widget.shopName != null
              ? allProducts.where((p) => p['shop'] == widget.shopName).toList()
              : allProducts; // Jika tidak ada shopName, tampilkan semua (opsional)

          // 4. Jika user belum milih toko di beranda
          if (widget.shopName == null) {
            return _buildEmptyState(
              icon: Icons.storefront_outlined,
              title: "Pilih Barbershop Dulu",
              message:
                  "Kembali ke beranda dan pilih pin barbershop di peta untuk melihat produk yang mereka jual.",
              showBackButton: true,
            );
          }

          // 5. Jika toko tidak punya produk
          if (products.isEmpty) {
            return _buildEmptyState(
              icon: Icons.inventory_2_outlined,
              title: widget.shopName!,
              message:
                  "Barbershop ini belum menambahkan katalog produk ke dalam sistem.",
              showBackButton: false,
            );
          }

          // 6. TAMPILAN NORMAL (Toko punya produk)
          return SingleChildScrollView(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              top: 10,
              bottom: 40,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Banner Info Toko
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1C1E),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.store, color: Colors.amber, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Etalase resmi dari:",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 10,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.shopName!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Grid Produk
                GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio:
                        0.58, // Diubah agar kartu lebih panjang dan tidak overflow
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    return _buildProductCard(products[index], context);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- WIDGET KARTU PRODUK PREMIUM ---
  Widget _buildProductCard(Map<String, dynamic> item, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar Produk
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2E),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(15),
                ),
                image: item['image'] != null
                    ? DecorationImage(
                        image: NetworkImage(item['image']),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: item['image'] == null
                  ? const Center(
                      child: Icon(Icons.image, color: Colors.grey, size: 40),
                    )
                  : null,
            ),
          ),

          // Detail Produk
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kategori (Bisa diganti jika databasemu punya field kategori)
                Text(
                  (item['category'] ?? "Grooming").toString().toUpperCase(),
                  style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 6),

                // Nama Produk
                Text(
                  item['name'] ?? "Produk Tanpa Nama",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // Harga Produk
                Text(
                  "Rp ${item['price'] ?? '0'}",
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),

                // Info Pengganti Keranjang Belanja
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.withOpacity(0.3)),
                  ),
                  child: const Center(
                    child: Text(
                      "TERSEDIA DI KASIR",
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET EMPTY STATE (Jika Kosong) ---
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
    required bool showBackButton,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.grey.withOpacity(0.3)),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 30),
            if (showBackButton)
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  "Kembali ke Peta",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // --- DIALOG INFORMASI ETALASE ---
  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          "Informasi Katalog",
          style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Halaman ini adalah etalase digital. Semua produk yang tampil di sini dapat Anda beli langsung di meja kasir saat Anda datang untuk cukur rambut.",
          style: TextStyle(color: Colors.grey, height: 1.5),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text("Mengerti"),
          ),
        ],
      ),
    );
  }
}