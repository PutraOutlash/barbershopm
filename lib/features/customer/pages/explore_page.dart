import 'package:flutter/material.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  // --- DUMMY DATA: REKOMENDASI BENTUK WAJAH ---
  final List<Map<String, dynamic>> faceShapes = [
    {
      "shape": "Wajah Bulat",
      "advice": "Butuh volume di atas agar wajah terlihat lebih panjang.",
      "best_styles": "Pompadour, Quiff, Faux Hawk",
      "icon": Icons.face,
      "color": const Color(0xFF4A90E2),
    },
    {
      "shape": "Wajah Kotak",
      "advice": "Rahang tegasmu sangat cocok dengan potongan super pendek.",
      "best_styles": "Buzz Cut, French Crop, Crew Cut",
      "icon": Icons.face_retouching_natural,
      "color": const Color(0xFFE24A4A),
    },
    {
      "shape": "Wajah Oval",
      "advice": "Proporsi paling ideal! Cocok dengan hampir semua gaya rambut.",
      "best_styles": "Comma Hair, Mullet, Slicked Back",
      "icon": Icons.face_6,
      "color": const Color(0xFFE29A4A),
    },
    {
      "shape": "Wajah Segitiga",
      "advice":
          "Seimbangkan area dahi dengan gaya berponi atau bervolume di samping.",
      "best_styles": "Fringe, Textured Crop, Side Part",
      "icon": Icons.face_3,
      "color": const Color(0xFF4AE28A),
    },
  ];

  // --- DUMMY DATA: GALERI GAYA RAMBUT ---
  final List<Map<String, dynamic>> gallery = [
    {
      "name": "Textured French Crop",
      "category": "Pendek",
      "image":
          "https://images.unsplash.com/photo-1502823403499-6ccfcf4fb453?w=500&q=80",
      "isSaved": false,
    },
    {
      "name": "Classic Pompadour",
      "category": "Klasik",
      "image":
          "https://images.unsplash.com/photo-1599351431202-1e0f0137899a?w=500&q=80",
      "isSaved": true,
    },
    {
      "name": "Military Buzz Cut",
      "category": "Sangat Pendek",
      "image":
          "https://images.unsplash.com/photo-1622286342621-4bd786c2447c?w=500&q=80",
      "isSaved": false,
    },
    {
      "name": "Korean Comma Hair",
      "category": "Medium",
      "image":
          "https://images.unsplash.com/photo-1618077360395-f3068be8e001?w=500&q=80",
      "isSaved": false,
    },
    {
      "name": "Modern Mullet",
      "category": "Trend",
      "image":
          "https://images.unsplash.com/photo-1559582930-bb01987cf4dd?w=500&q=80",
      "isSaved": true,
    },
    {
      "name": "Slicked Back Fade",
      "category": "Klasik",
      "image":
          "https://images.unsplash.com/photo-1623588958271-8c019027eca2?w=500&q=80",
      "isSaved": false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        title: const Text(
          "EKSPLOR GAYA",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.amber),
            onPressed: () {
              // Fitur pencarian nantinya
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        // Padding bawah besar agar tidak tertutup Navbar kapsul
        padding: const EdgeInsets.only(bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==========================================
            // 1. REKOMENDASI BENTUK WAJAH
            // ==========================================
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 10),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "PANDUAN BENTUK WAJAH",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              height: 160,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: faceShapes.length,
                itemBuilder: (context, index) {
                  var face = faceShapes[index];
                  return Container(
                    width: 260,
                    margin: const EdgeInsets.only(right: 15),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C1E),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: face['color'].withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                face['icon'],
                                color: face['color'],
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              face['shape'].toString().toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          face['advice'],
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.amber.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Colors.amber,
                                size: 12,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  face['best_styles'],
                                  style: const TextStyle(
                                    color: Colors.amber,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 35),

            // ==========================================
            // 2. KATALOG GAYA (GRID VIEW)
            // ==========================================
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "INSPIRASI GAYA TERBARU",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),

            // Grid Foto
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.builder(
                // Mematikan scroll bawaan grid karena sudah dibungkus SingleChildScrollView
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 kolom menyamping
                  crossAxisSpacing: 15, // Spasi antar kolom
                  mainAxisSpacing: 15, // Spasi atas-bawah
                  childAspectRatio: 0.75, // Rasio ukuran (Tinggi > Lebar)
                ),
                itemCount: gallery.length,
                itemBuilder: (context, index) {
                  var style = gallery[index];
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      image: DecorationImage(
                        image: NetworkImage(style['image']),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        // Gradien hitam dari bawah agar tulisan terbaca
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.9),
                            Colors.transparent,
                            Colors.black.withOpacity(0.4),
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Tombol Bookmark di pojok kanan atas
                          Positioned(
                            top: 10,
                            right: 10,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  style['isSaved'] = !style['isSaved'];
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  style['isSaved']
                                      ? Icons.bookmark
                                      : Icons.bookmark_border,
                                  color: style['isSaved']
                                      ? Colors.amber
                                      : Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                          // Info Nama Gaya di bawah
                          Positioned(
                            bottom: 15,
                            left: 12,
                            right: 12,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.amber,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    style['category'].toString().toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  style['name'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}