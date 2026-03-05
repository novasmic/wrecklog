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

/// One tile in the 2×2 grid.
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
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF252525),
                const Color(0xFF1A1A1A),
              ],
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Orange accent bar at top
              Container(
                height: 3,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                  gradient: LinearGradient(
                    colors: [Color(0xFFE8700A), Color(0xFFC45A06)],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon with subtle glow
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFE8700A).withValues(alpha: 0.12),
                      ),
                      child: Icon(icon, color: const Color(0xFFE8700A), size: 28),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
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
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // App icon with glow ring
                          Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF1A1208),
                              border: Border.all(
                                color: const Color(0xFFE8700A).withValues(alpha: 0.35),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFE8700A).withValues(alpha: 0.25),
                                  blurRadius: 24,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(10),
                            child: Image.asset('assets/icon/icon_fg.png'),
                          ),
                          const SizedBox(height: 16),
                          const WreckLogLogo(),
                          const SizedBox(height: 10),

                          // Tagline with dividers
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 28,
                                height: 1,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      const Color(0xFFE8700A).withValues(alpha: 0.6),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Track Every Part. Track Real Profit.',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.45),
                                  fontSize: 12,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                width: 28,
                                height: 1,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFFE8700A).withValues(alpha: 0.6),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 2),

                // ── 2×2 Button grid ────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _GridButton(
                              icon: Icons.add_circle_outline,
                              label: 'Add\nVehicle',
                              onTap: onAddVehicle,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _GridButton(
                              icon: Icons.directions_car_outlined,
                              label: 'View\nVehicles',
                              onTap: onViewVehicles,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _GridButton(
                              icon: Icons.search,
                              label: 'Search\nParts',
                              onTap: onSearchParts,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _GridButton(
                              icon: Icons.bar_chart_rounded,
                              label: 'Stats',
                              onTap: onStats,
                            ),
                          ),
                        ],
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
