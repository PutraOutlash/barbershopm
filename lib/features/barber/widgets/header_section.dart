import 'package:barber_app/features/barber/pages/notification_page.dart';
import 'package:flutter/material.dart';

class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});

  static const _gold = Color(0xFFFFC107);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Avatar inisial
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _gold,
            border: Border.all(color: _gold.withOpacity(0.4), width: 2),
          ),
          alignment: Alignment.center,
          child: const Text(
            'BC',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w800,
              fontSize: 14,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Greeting + nama
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Selamat Pagi,',
                style: TextStyle(
                  color: Color(0xFF8E8E93),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'BARBER CAVE',
                style: TextStyle(
                  color: _gold,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),

        // Ikon notifikasi
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const NotificationScreen(),
              ),
            );
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF1C1C1E),
                  border: Border.all(
                    color: const Color(0xFF2C2C2E),
                    width: 1,
                  ),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.notifications_outlined,
                  color: Color(0xFF8E8E93),
                  size: 20,
                ),
              ),
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: _gold,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
