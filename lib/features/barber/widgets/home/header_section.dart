import 'package:flutter/material.dart';
import 'package:barber_app/features/barber/view/notification/unified_notification_screen.dart';

class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});

  static const _gold = Color(0xFFFFC107);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
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
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selamat Pagi,',
                style: TextStyle(
                  color: Color(0xFF8E8E93),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.2,
                ),
              ),
              SizedBox(height: 2),
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
        GestureDetector(
          onTap: () => Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (_, anim, _) => const UnifiedNotificationScreen(),
              transitionsBuilder: (_, anim, _, child) => SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
                ),
                child: child,
              ),
              transitionDuration: const Duration(milliseconds: 350),
            ),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF1C1C1E),
                  border: Border.all(color: const Color(0xFF2C2C2E), width: 1),
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
