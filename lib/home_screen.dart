// lib/home_screen.dart
import 'package:flutter/material.dart';

/// The WreckLog wordmark — WRECK in white, LOG in orange, bold italic.
class WreckLogLogo extends StatelessWidget {
  final double fontSize;
  const WreckLogLogo({super.key, this.fontSize = 52});

  @override
  Widget build(BuildContext context) {
    const shadow = [
      Shadow(offset: Offset(0, 3), blurRadius: 8, color: Colors.black),
      Shadow(offset: Offset(0, 1), blurRadius: 2, color: Colors.black54),
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
      color: const Color(0xFF1A1A1A),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: const Color(0xFFE8700A), size: 32),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
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
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F14),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),

            // ── App icon ────────────────────────────────────────────
            Image.asset('assets/icon/icon_fg.png', width: 80, height: 80),
            const SizedBox(height: 14),

            // ── Wordmark ────────────────────────────────────────────
            const WreckLogLogo(),
            const SizedBox(height: 8),
            Text(
              'Track Every Part. Track Real Profit.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 13,
                letterSpacing: 0.3,
              ),
            ),

            const Spacer(flex: 2),

            // ── 2×2 Button grid ─────────────────────────────────────
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

            // ── Settings link ───────────────────────────────────────
            TextButton.icon(
              onPressed: onSettings,
              icon: const Icon(Icons.settings_outlined, size: 15, color: Colors.white38),
              label: const Text(
                'Settings',
                style: TextStyle(color: Colors.white38, fontSize: 13),
              ),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
