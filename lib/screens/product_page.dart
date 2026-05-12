import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api.dart';

class ProductPage extends StatefulWidget {
  // 🔥 INI DIA KUNCI JAWABANNYA! Sekarang dia menerima 'shopData'
  final Map<String, dynamic> shopData;

  const ProductPage({super.key, required this.shopData});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  List<dynamic> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    try {
      // Ambil ID Barber dari data toko yang diklik
      String barberId = widget.shopData['user_id'].toString();
      var response = await http.get(
        Uri.parse('${Api.baseUrl}/products/$barberId'),
      );

      if (response.statusCode == 200) {
        setState(() {
          products = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("Error Fetch Products: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ambil nama toko dari data yang dikirim HomePage
    String shopName = widget.shopData['shop_name'].toString().toUpperCase();

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFFE5C07B),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            const Text(
              "AMUNISI PERAWATAN",
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              shopName,
              style: const TextStyle(color: Colors.grey, fontSize: 10),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFE5C07B)),
            )
          : products.isEmpty
          ? _buildEmptyState(shopName)
          : _buildProductGrid(),
    );
  }

  // 🔥 TAMPILAN ANIMASI & KALIMAT JIKA BARBER TIDAK JUALAN PRODUK
  Widget _buildEmptyState(String shopName) {
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
              "Saat ini, $shopName belum menyediakan amunisi perawatan rambut (Gatsby, Powder, dll) di etalase digital mereka.\n\nSilakan cek kembali di lain waktu!",
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

  // Tampilan Jika Produk Tersedia
  Widget _buildProductGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        var product = products[index];
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
                      ? const Center(
                          child: Icon(Icons.image, color: Colors.grey),
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
      },
    );
  }
}
