import 'package:flutter/material.dart';

// 🔥 IMPORT SERVICE DAN WIDGETS BARU KITA
import '../services/product_service.dart';
import '../widgets/product_widgets.dart';

class ProductPage extends StatefulWidget {
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
    _loadProducts();
  }

  // --- FUNGSI MENGGUNAKAN ASISTEN ---
  Future<void> _loadProducts() async {
    try {
      String barberId = widget.shopData['user_id'].toString();

      // Panggil asisten untuk ambil data
      var data = await ProductService.fetchProductsByBarber(barberId);

      if (mounted) {
        setState(() {
          products = data;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        // Tampilkan pesan error jika butuh
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Gagal memuat produk. Coba lagi nanti."),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
          ? EmptyProductWidget(
              shopName: shopName,
            ) // 🔥 MENGGUNAKAN WIDGET EKSTERNAL
          : GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                return ProductCardWidget(
                  product: products[index],
                ); // 🔥 MENGGUNAKAN WIDGET EKSTERNAL
              },
            ),
    );
  }
}
