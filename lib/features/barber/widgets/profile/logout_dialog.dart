import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Tampilkan logout dialog dengan animasi scale custom.
/// [onLogout] dipanggil ketika user konfirmasi logout.
Future<void> showLogoutDialog(
  BuildContext context, {
  VoidCallback? onLogout,
}) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Logout',
    barrierColor: Colors.black.withOpacity(0.72),
    transitionDuration: const Duration(milliseconds: 280),
    pageBuilder: (_, _, _) => _LogoutDialog(onLogout: onLogout),
    transitionBuilder: (_, anim, _, child) {
      final curved = CurvedAnimation(
        parent: anim,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeIn,
      );
      return ScaleTransition(
        scale: Tween<double>(begin: 0.85, end: 1.0).animate(curved),
        child: FadeTransition(
          opacity: Tween<double>(begin: 0, end: 1).animate(
            CurvedAnimation(parent: anim, curve: Curves.easeOut),
          ),
          child: child,
        ),
      );
    },
  );
}

class _LogoutDialog extends StatelessWidget {
  final VoidCallback? onLogout;
  const _LogoutDialog({this.onLogout});

  static const _gold   = Color(0xFFFFC107);
  static const _card   = Color(0xFF1C1C1E);
  static const _border = Color(0xFF2C2C2E);
  static const _muted  = Color(0xFF8E8E93);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Material(
          color: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(
            maxWidth: 420,
            maxHeight: 360,
          ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              // Glow gold tipis di outline
              boxShadow: [
                BoxShadow(
                  color: _gold.withOpacity(0.12),
                  blurRadius: 28,
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 20,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  // Background card
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E1E1E), Color(0xFF141414)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      border: Border.all(color: _border, width: 1),
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),

                  // Garis gold vertikal di kiri
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 4,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _gold.withOpacity(0.8),
                            _gold.withOpacity(0.2),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),

                  // Konten
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Icon logout dalam lingkaran
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2C2C2E),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _border,
                              width: 1,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.logout_rounded,
                            color: _gold,
                            size: 26,
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Judul
                        const Text(
                          'Keluar dari akun?',
                          style: TextStyle(
                            color: _gold,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Deskripsi
                        const Text(
                          'Anda yakin ingin keluar dari Barber Cave? Sesi Anda akan berakhir.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF8E8E93),
                            fontSize: 13,
                            height: 1.55,
                          ),
                        ),
                        const SizedBox(height: 26),

                        // Tombol Logout
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            Navigator.of(context).pop();
                            onLogout?.call();
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            decoration: BoxDecoration(
                              color: _gold,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: _gold.withOpacity(0.28),
                                  blurRadius: 14,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              'Logout',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Tombol Batal
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFF3A3A3C),
                                width: 1.5,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              'Batal',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
