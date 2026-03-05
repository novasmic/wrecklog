import 'package:flutter/material.dart';

/// WreckLog - Dark Pro Theme
/// Drop-in theme you can apply in MaterialApp(theme: WreckTheme.darkTheme)
class WreckTheme {
  // ── Static colour constants (used across components) ───────────────────────
  static const Color accent   = Color(0xFFE8700A); // WreckLog orange
  static const Color ok       = Color(0xFF4ADE80); // green  — in stock / profit
  static const Color info     = Color(0xFF60A5FA); // blue   — sold / neutral
  static const Color warn     = Color(0xFFFBBF24); // amber  — not listed / warning
  static const Color bad      = Color(0xFFFB7185); // red    — scrap / loss
  static const Color surface  = Color(0xFF111826); // card background
  static const Color border   = Color(0xFF223047); // card border / outline
  static const Color text0    = Colors.white;
  static const Color text1    = Color(0xFFB0BEC5); // muted white

  // ── Spacing constants ──────────────────────────────────────────────────────
  static const double s12 = 12.0;
  static const double s20 = 20.0;

  // ── Radius constants ───────────────────────────────────────────────────────
  static const double r12 = 12.0;

  // ── Theme ──────────────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    const bg       = Color(0xFF0B0F14);
    const surface2 = Color(0xFF0E1522);
    const outline  = border;
    const primary  = Color(0xFF2DD4BF); // teal accent
    const secondary = Color(0xFF60A5FA); // blue accent
    const danger   = bad;

    final cs = const ColorScheme.dark().copyWith(
      primary: primary,
      secondary: secondary,
      surface: surface,
      error: danger,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: bg,

      appBarTheme: const AppBarTheme(
        backgroundColor: bg,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),

      cardTheme: const CardThemeData(
        color: surface2,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(18)),
          side: BorderSide(color: outline, width: 1),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: outline,
        thickness: 1,
        space: 1,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface2,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.55)),
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.85)),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide(color: outline),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide(color: danger),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide(color: danger, width: 1.5),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: outline),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: surface2,
        selectedColor: primary.withValues(alpha: 0.18),
        side: const BorderSide(color: outline),
        labelStyle: const TextStyle(color: Colors.white),
        secondaryLabelStyle: const TextStyle(color: Colors.white),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        shape: const StadiumBorder(),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: bg,
        selectedItemColor: primary,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
      ),

      textTheme: const TextTheme(
        headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        bodyMedium: TextStyle(fontSize: 14),
        bodySmall: TextStyle(fontSize: 12, color: Colors.white70),
      ),
    );
  }
}
