import 'package:flutter/material.dart';

class PopularServiceCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const PopularServiceCard({super.key, required this.data});

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
