import 'package:flutter/material.dart';

class ProductModel {
  final String id;
  final String name;
  final String price;
  final String description;
  final String imageEmoji; // placeholder sebelum ada real asset

  const ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.imageEmoji,
  });
}

// ── Dummy data produk ─────────────────────────────────────────────────────────
final List<ProductModel> dummyProducts = [
  const ProductModel(
    id: 'P001',
    name: 'Pomade Strong Hold',
    price: 'Rp 150.000',
    description: 'Keep your style sharp all day long.',
    imageEmoji: '🫙',
  ),
  const ProductModel(
    id: 'P002',
    name: 'Beard Oil Sandalwood',
    price: 'Rp 120.000',
    description: 'Nourishing oil for a softer beard.',
    imageEmoji: '🧴',
  ),
  const ProductModel(
    id: 'P003',
    name: 'Aftershave Cooling Mist',
    price: 'Rp 95.000',
    description: 'Refreshing finish for a smooth shave.',
    imageEmoji: '💨',
  ),
];

// ── Widget card produk ────────────────────────────────────────────────────────
class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ProductCard({
    super.key,
    required this.product,
    this.onEdit,
    this.onDelete,
  });

  static const _gold   = Color(0xFFFFC107);
  static const _card   = Color(0xFF1C1C1E);
  static const _border = Color(0xFF2C2C2E);
  static const _muted  = Color(0xFF8E8E93);
  static const _red    = Color(0xFFFF453A);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Gambar produk ────────────────────────────────
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF2A2000),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF3A3000), width: 1),
              ),
              alignment: Alignment.center,
              child: Text(
                product.imageEmoji,
                style: const TextStyle(fontSize: 32),
              ),
            ),
            const SizedBox(width: 14),

            // ── Info ─────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    product.price,
                    style: const TextStyle(
                      color: _gold,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.description,
                    style: const TextStyle(
                      color: _muted,
                      fontSize: 12,
                      height: 1.4,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // ── Tombol edit & delete ─────────────────────────
            Column(
              children: [
                _ActionBtn(
                  icon: Icons.edit_outlined,
                  color: const Color(0xFF8E8E93),
                  onTap: onEdit,
                ),
                const SizedBox(height: 8),
                _ActionBtn(
                  icon: Icons.delete_outline_rounded,
                  color: _red,
                  onTap: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _ActionBtn({required this.icon, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.20), width: 1),
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: color, size: 16),
      ),
    );
  }
}
