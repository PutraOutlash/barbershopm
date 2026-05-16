import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage>
    with TickerProviderStateMixin {
  // ── Warna ────────────────────────────────────────────────────────────────────
  static const _gold  = Color(0xFFFFC107);
  static const _green = Color(0xFF4CD964);

  // ── State ─────────────────────────────────────────────────────────────────────
  bool _flashOn        = false;
  bool _scanned        = false; // simulated scan result
  bool _showResultCard = true;

  // ── Controllers ───────────────────────────────────────────────────────────────
  late final AnimationController _scanLineCtrl;
  late final AnimationController _glowCtrl;
  late final AnimationController _pulseCtrl;
  late final AnimationController _resultCtrl;

  late final Animation<double> _scanLineAnim;
  late final Animation<double> _glowAnim;
  late final Animation<double> _pulseAnim;
  late final Animation<double> _resultAnim;

  @override
  void initState() {
    super.initState();

    // Scan line naik-turun
    _scanLineCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _scanLineAnim = CurvedAnimation(
      parent: _scanLineCtrl,
      curve: Curves.easeInOut,
    );

    // Glow pulsing
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.3, end: 0.9).animate(
      CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut),
    );

    // Pulse pada tombol scan di navbar (digunakan dari sini lewat Navigator)
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    // Result card slide in
    _resultCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _resultAnim = CurvedAnimation(
      parent: _resultCtrl,
      curve: Curves.easeOutCubic,
    );

    if (_showResultCard) _resultCtrl.forward();
  }

  @override
  void dispose() {
    _scanLineCtrl.dispose();
    _glowCtrl.dispose();
    _pulseCtrl.dispose();
    _resultCtrl.dispose();
    super.dispose();
  }

  void _toggleFlash() {
    HapticFeedback.lightImpact();
    setState(() => _flashOn = !_flashOn);
  }

  void _simulateScan() {
    HapticFeedback.mediumImpact();
    setState(() {
      _scanned = true;
      _showResultCard = true;
    });
    _resultCtrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final size   = MediaQuery.of(context).size;
    final frameW = size.width * 0.72;
    final frameH = frameW;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Kamera simulasi (background gelap sinematik) ────────────────
          _CameraBackground(),

          // ── Overlay gradient ───────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xCC000000),
                  Color(0x55000000),
                  Color(0x55000000),
                  Color(0xCC000000),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.25, 0.75, 1.0],
              ),
            ),
          ),

          // ── Konten utama ───────────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(context),

                // Result card (slide in)
                if (_showResultCard) _buildResultCard(),

                const SizedBox(height: 12),

                // Instruksi atas
                const Text(
                  'Arahkan kamera ke barcode customer',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.2,
                    shadows: [Shadow(color: Colors.black, blurRadius: 8)],
                  ),
                ),

                const SizedBox(height: 20),

                // Scanner frame
                _buildScannerFrame(frameW, frameH),

                const SizedBox(height: 18),

                // Instruksi bawah
                const Text(
                  'Posisikan barcode di dalam area scan',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xAAFFFFFF),
                    fontSize: 13,
                    shadows: [Shadow(color: Colors.black, blurRadius: 6)],
                  ),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: _simulateScan,
                  child: const Text(
                    'SCAN OTOMATIS',
                    style: TextStyle(
                      color: Color(0xFFFFC107),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Tombol flash & galeri
                _buildActionButtons(),

                const Spacer(),

                // Status card bawah
                _buildStatusCard(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          _GlassCircleButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.of(context).pop(),
          ),
          const Spacer(),
          _GlassCircleButton(
            icon: Icons.info_outline_rounded,
            onTap: () => HapticFeedback.lightImpact(),
          ),
        ],
      ),
    );
  }

  // ── Result card ───────────────────────────────────────────────────────────────
  Widget _buildResultCard() {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, -1),
        end: Offset.zero,
      ).animate(_resultAnim),
      child: FadeTransition(
        opacity: _resultAnim,
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xE0141414),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFFFC107).withOpacity(0.35),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFC107).withOpacity(0.12),
                blurRadius: 16,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _green.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: _green.withOpacity(0.4), width: 1),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.check_rounded, color: _green, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Barcode berhasil dipindai',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Budi Santoso · Classic Fade · Rp 150.000',
                      style: TextStyle(
                        color: Color(0xFFFFC107),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _showResultCard = false),
                child: const Icon(Icons.close_rounded,
                    color: Color(0xFF8E8E93), size: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Scanner frame ─────────────────────────────────────────────────────────────
  Widget _buildScannerFrame(double w, double h) {
    return SizedBox(
      width: w,
      height: h,
      child: Stack(
        children: [
          // Sudut-sudut neon gold
          ..._buildCorners(w, h),

          // Scan line animasi
          AnimatedBuilder(
            animation: _scanLineAnim,
            builder: (_, _) {
              final y = _scanLineAnim.value * (h - 4);
              return Positioned(
                left: 12,
                right: 12,
                top: y,
                child: AnimatedBuilder(
                  animation: _glowAnim,
                  builder: (_, _) => Container(
                    height: 2.5,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          _gold.withOpacity(_glowAnim.value),
                          _gold,
                          _gold.withOpacity(_glowAnim.value),
                          Colors.transparent,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _gold.withOpacity(0.6),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── 4 sudut scanner ───────────────────────────────────────────────────────────
  List<Widget> _buildCorners(double w, double h) {
    const len  = 28.0;
    const thick = 3.5;
    const r    = 6.0;

    Widget corner({
      required Alignment alignment,
      required bool flipX,
      required bool flipY,
    }) {
      return Positioned(
        left: flipX ? null : 0,
        right: flipX ? 0 : null,
        top: flipY ? null : 0,
        bottom: flipY ? 0 : null,
        child: AnimatedBuilder(
          animation: _glowAnim,
          builder: (_, _) => CustomPaint(
            size: Size(len + r, len + r),
            painter: _CornerPainter(
              color: _gold,
              glow: _glowAnim.value,
              flipX: flipX,
              flipY: flipY,
              len: len,
              thick: thick,
              radius: r,
            ),
          ),
        ),
      );
    }

    return [
      corner(alignment: Alignment.topLeft,     flipX: false, flipY: false),
      corner(alignment: Alignment.topRight,    flipX: true,  flipY: false),
      corner(alignment: Alignment.bottomLeft,  flipX: false, flipY: true),
      corner(alignment: Alignment.bottomRight, flipX: true,  flipY: true),
    ];
  }

  // ── Tombol flash & galeri ─────────────────────────────────────────────────────
  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ActionCircleBtn(
          icon: _flashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
          label: 'FLASH',
          active: _flashOn,
          onTap: _toggleFlash,
        ),
        const SizedBox(width: 32),
        _ActionCircleBtn(
          icon: Icons.photo_library_outlined,
          label: 'GALERI',
          onTap: () => HapticFeedback.lightImpact(),
        ),
      ],
    );
  }

  // ── Status card bawah ─────────────────────────────────────────────────────────
  Widget _buildStatusCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xCC1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2C2C2E), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Blinking green dot
          _BlinkingDot(),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SCANNER AKTIF',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Tunggu barcode customer',
                style: TextStyle(
                  color: Color(0xFF8E8E93),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Camera background (simulasi) ──────────────────────────────────────────────
class _CameraBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.2,
          colors: [
            Color(0xFF1A1208),
            Color(0xFF0D0D0D),
            Color(0xFF050505),
          ],
        ),
      ),
      child: Opacity(
        opacity: 0.35,
        child: Image.network(
          'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=400&q=60',
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (_, _, _) => const SizedBox.shrink(),
        ),
      ),
    );
  }
}

// ── Tombol lingkaran kaca header ──────────────────────────────────────────────
class _GlassCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _GlassCircleButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.45),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.18), width: 1),
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: Colors.white, size: 17),
      ),
    );
  }
}

// ── Tombol aksi lingkaran kecil ───────────────────────────────────────────────
class _ActionCircleBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;

  const _ActionCircleBtn({
    required this.icon,
    required this.label,
    this.active = false,
    this.onTap,
  });

  static const _gold = Color(0xFFFFC107);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 54, height: 54,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.55),
              shape: BoxShape.circle,
              border: Border.all(
                color: active
                    ? _gold.withOpacity(0.8)
                    : _gold.withOpacity(0.30),
                width: 1.5,
              ),
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: _gold.withOpacity(0.25),
                        blurRadius: 12,
                        spreadRadius: 1,
                      )
                    ]
                  : null,
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              color: active ? _gold : Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: active ? _gold : const Color(0xFF8E8E93),
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Blinking green dot ─────────────────────────────────────────────────────────
class _BlinkingDot extends StatefulWidget {
  @override
  State<_BlinkingDot> createState() => _BlinkingDotState();
}

class _BlinkingDotState extends State<_BlinkingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.3, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Container(
        width: 10, height: 10,
        decoration: const BoxDecoration(
          color: Color(0xFF4CD964),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color(0xFF4CD964),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Custom painter sudut scanner ──────────────────────────────────────────────
class _CornerPainter extends CustomPainter {
  final Color color;
  final double glow;
  final bool flipX;
  final bool flipY;
  final double len;
  final double thick;
  final double radius;

  const _CornerPainter({
    required this.color,
    required this.glow,
    required this.flipX,
    required this.flipY,
    required this.len,
    required this.thick,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.6 + glow * 0.4)
      ..strokeWidth = thick
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final glowPaint = Paint()
      ..color = color.withOpacity(glow * 0.5)
      ..strokeWidth = thick + 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    // Tentukan titik awal berdasarkan flip
    final ox = flipX ? size.width : 0.0;
    final oy = flipY ? size.height : 0.0;
    final xDir = flipX ? -1.0 : 1.0;
    final yDir = flipY ? -1.0 : 1.0;

    final path = Path();
    path.moveTo(ox + xDir * len, oy);
    path.lineTo(ox + xDir * radius, oy);
    path.quadraticBezierTo(ox, oy, ox, oy + yDir * radius);
    path.lineTo(ox, oy + yDir * len);

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CornerPainter old) =>
      old.glow != glow || old.color != color;
}
