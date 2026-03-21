// lib/home_screen.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';

/// The WreckLog wordmark — WRECK in white, LOG in orange, bold italic.
class WreckLogLogo extends StatelessWidget {
  final double fontSize;
  const WreckLogLogo({super.key, this.fontSize = 52});

  @override
  Widget build(BuildContext context) {
    const shadow = [
      Shadow(offset: Offset(0, 3), blurRadius: 12, color: Colors.black),
      Shadow(offset: Offset(0, 1), blurRadius: 3, color: Colors.black87),
    ];
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontFamily: 'Arial Black',
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          fontStyle: FontStyle.italic,
          letterSpacing: -1.5,
          shadows: shadow,
        ),
        children: const [
          TextSpan(text: 'WRECK', style: TextStyle(color: Colors.white)),
          TextSpan(text: 'LOG',   style: TextStyle(color: Color(0xFFE8700A))),
        ],
      ),
    );
  }
}

/// Radial orange glow painted behind the logo area.
class _GlowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFE8700A).withValues(alpha: 0.18),
          const Color(0xFFE8700A).withValues(alpha: 0.06),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: size.width * 0.6));
    canvas.drawCircle(center, size.width * 0.6, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// One full-width button in the vertical stack.
class _GridButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _GridButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF252525), Color(0xFF1A1A1A)],
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Orange accent bar on left
              Container(
                width: 4,
                height: 64,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.horizontal(left: Radius.circular(16)),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFE8700A), Color(0xFFC45A06)],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Icon in circle
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE8700A).withValues(alpha: 0.12),
                ),
                child: Icon(icon, color: const Color(0xFFE8700A), size: 24),
              ),
              const SizedBox(width: 16),
              // Label
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
              const Spacer(),
              // Chevron
              Icon(
                Icons.chevron_right,
                color: Colors.white.withValues(alpha: 0.25),
                size: 20,
              ),
              const SizedBox(width: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final VoidCallback onAddVehicle;
  final VoidCallback onViewVehicles;
  final VoidCallback onSearchParts;
  final VoidCallback onStats;
  final VoidCallback onSettings;

  const HomeScreen({
    super.key,
    required this.onAddVehicle,
    required this.onViewVehicles,
    required this.onSearchParts,
    required this.onStats,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // ── Gradient background ──────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0F1318),
                  Color(0xFF0B0D10),
                  Color(0xFF090B0E),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // ── Subtle diagonal texture lines ────────────────────────
          CustomPaint(
            size: Size.infinite,
            painter: _DiagonalTexturePainter(),
          ),

          // ── Leather grain texture ─────────────────────────────────
          CustomPaint(
            size: Size.infinite,
            painter: LeatherGrainPainter(),
          ),

          // ── Main content ─────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),

                // ── Logo area with glow ────────────────────────────
                SizedBox(
                  width: screenWidth,
                  height: 220,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Radial glow behind logo
                      CustomPaint(
                        size: Size(screenWidth, 220),
                        painter: _GlowPainter(),
                      ),
                      Image.asset(
                        'assets/icon/icon_fg.png',
                        width: screenWidth * 0.90,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 2),

                // ── Button stack ────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      _GridButton(
                        icon: Icons.add_circle_outline,
                        label: 'Add Vehicle',
                        onTap: onAddVehicle,
                      ),
                      const SizedBox(height: 12),
                      _GridButton(
                        icon: Icons.directions_car_outlined,
                        label: 'View Vehicles',
                        onTap: onViewVehicles,
                      ),
                      const SizedBox(height: 12),
                      _GridButton(
                        icon: Icons.search,
                        label: 'Search Parts',
                        onTap: onSearchParts,
                      ),
                      const SizedBox(height: 12),
                      _GridButton(
                        icon: Icons.bar_chart_rounded,
                        label: 'Stats',
                        onTap: onStats,
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 2),

                // ── Settings link ──────────────────────────────────
                TextButton.icon(
                  onPressed: onSettings,
                  icon: const Icon(Icons.settings_outlined, size: 15, color: Colors.white30),
                  label: const Text(
                    'Settings',
                    style: TextStyle(color: Colors.white30, fontSize: 13),
                  ),
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Very subtle diagonal lines for background texture.
class _DiagonalTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.015)
      ..strokeWidth = 1;

    const spacing = 32.0;
    final count = (size.width + size.height) ~/ spacing;
    for (int i = 0; i < count; i++) {
      final x = i * spacing;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x - size.height * math.tan(math.pi / 6), size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Leather grain — pebbled dots + short curved grain strokes.
class LeatherGrainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(7);

    // ── Pebble layer: tiny irregular dots ──────────────────────────────────
    final dotPaint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 2800; i++) {
      final x  = rng.nextDouble() * size.width;
      final y  = rng.nextDouble() * size.height;
      final r  = rng.nextDouble() * 1.4 + 0.3;
      // Alternate very slightly lighter / darker for embossed feel
      final a  = rng.nextBool()
          ? 0.055 + rng.nextDouble() * 0.03
          : 0.0;
      if (a == 0.0) continue;
      dotPaint.color = Colors.white.withValues(alpha: a);
      canvas.drawCircle(Offset(x, y), r, dotPaint);
    }

    // ── Shadow side of each pebble: tiny dark offset dot ───────────────────
    final shadowPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.black.withValues(alpha: 0.06);
    final rng2 = math.Random(7); // same seed → same positions
    for (int i = 0; i < 2800; i++) {
      final x = rng2.nextDouble() * size.width;
      final y = rng2.nextDouble() * size.height;
      final r = rng2.nextDouble() * 1.4 + 0.3;
      rng2.nextBool(); rng2.nextDouble(); // consume same calls as above
      canvas.drawCircle(Offset(x + 0.8, y + 0.8), r * 0.7, shadowPaint);
    }

    // ── Grain strokes: short, slightly curved lines in a loose direction ───
    final grainPaint = Paint()
      ..style  = PaintingStyle.stroke
      ..strokeWidth = 0.7
      ..strokeCap = StrokeCap.round;
    final rng3 = math.Random(13);
    for (int i = 0; i < 520; i++) {
      final x   = rng3.nextDouble() * size.width;
      final y   = rng3.nextDouble() * size.height;
      final len = rng3.nextDouble() * 22 + 5;
      // Grain runs mostly horizontal with ±30° variation
      final angle = (rng3.nextDouble() - 0.5) * math.pi / 3;
      final dx  = math.cos(angle) * len / 2;
      final dy  = math.sin(angle) * len / 2;
      // Slight bow in the middle
      final bx  = x + (rng3.nextDouble() - 0.5) * 5;
      final by  = y + (rng3.nextDouble() - 0.5) * 5;
      final alpha = 0.025 + rng3.nextDouble() * 0.025;
      grainPaint.color = Colors.white.withValues(alpha: alpha);
      final path = Path()
        ..moveTo(x - dx, y - dy)
        ..quadraticBezierTo(bx, by, x + dx, y + dy);
      canvas.drawPath(path, grainPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
