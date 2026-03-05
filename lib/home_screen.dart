// lib/home_screen.dart
// WreckLog home screen — replaces tab navigation as the entry point.
// Four big buttons navigate into the existing tab screens.

import 'package:flutter/material.dart';

/// The WreckLog wordmark — WRECK in white, LOG in orange, bold italic.
class WreckLogLogo extends StatelessWidget {
  final double fontSize;
  const WreckLogLogo({super.key, this.fontSize = 64});

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

/// One of the four big home screen buttons.
class _HomeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _HomeButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      child: Material(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFFE8700A), size: 28),
                const SizedBox(width: 20),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
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

  const HomeScreen({
    super.key,
    required this.onAddVehicle,
    required this.onViewVehicles,
    required this.onSearchParts,
    required this.onStats,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F14),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),

            // ── Logo ───────────────────────────────────────────────
            const WreckLogLogo(),
            const SizedBox(height: 8),
            Text(
              'Track Every Part. Track Real Profit.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.55),
                fontSize: 14,
                letterSpacing: 0.3,
              ),
            ),

            const Spacer(flex: 2),

            // ── Buttons ────────────────────────────────────────────
            _HomeButton(
              icon: Icons.add,
              label: 'Add Vehicle',
              onTap: onAddVehicle,
            ),
            _HomeButton(
              icon: Icons.directions_car,
              label: 'View Vehicles',
              onTap: onViewVehicles,
            ),
            _HomeButton(
              icon: Icons.search,
              label: 'Search Parts',
              onTap: onSearchParts,
            ),
            _HomeButton(
              icon: Icons.bar_chart,
              label: 'Stats',
              onTap: onStats,
            ),

            const Spacer(flex: 3),
          ],
        ),
      ),
    );
  }
}
