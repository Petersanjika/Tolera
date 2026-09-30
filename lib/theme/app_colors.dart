import 'package:flutter/material.dart';

/// Tolera App Color Palette
/// Water-inspired theme: deep blue, aqua, turquoise, teal, soft green
class AppColors {
  AppColors._();

  // ── Primary Blues ──────────────────────────────────────────────────────────
  static const Color deepBlue = Color(0xFF0D47A1);
  static const Color blue = Color(0xFF1565C0);
  static const Color mediumBlue = Color(0xFF1976D2);
  static const Color lightBlue = Color(0xFF42A5F5);

  // ── Aqua / Cyan ────────────────────────────────────────────────────────────
  static const Color aqua = Color(0xFF00BCD4);
  static const Color aquaLight = Color(0xFF4DD0E1);
  static const Color cyan = Color(0xFF00E5FF);

  // ── Teal / Turquoise ───────────────────────────────────────────────────────
  static const Color teal = Color(0xFF009688);
  static const Color tealLight = Color(0xFF26C6DA);
  static const Color turquoise = Color(0xFF00ACC1);

  // ── Greens (accent) ────────────────────────────────────────────────────────
  static const Color green = Color(0xFF43A047);
  static const Color greenLight = Color(0xFF66BB6A);
  static const Color mint = Color(0xFF26A69A);

  // ── Status Colors ──────────────────────────────────────────────────────────
  static const Color success = Color(0xFF2E7D32);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFF57C00);
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color error = Color(0xFFC62828);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color pending = Color(0xFF6A1B9A);
  static const Color pendingLight = Color(0xFFF3E5F5);

  // ── Neutrals ───────────────────────────────────────────────────────────────
  static const Color white = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFF8FEFF);
  static const Color surfaceLight = Color(0xFFECF8FF);
  static const Color divider = Color(0xFFE0E0E0);
  static const Color textPrimary = Color(0xFF0D2137);
  static const Color textSecondary = Color(0xFF546E7A);
  static const Color textHint = Color(0xFF90A4AE);

  // ── Dark Mode ──────────────────────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF0A1628);
  static const Color darkSurface = Color(0xFF112240);
  static const Color darkCard = Color(0xFF172A45);
  static const Color darkDivider = Color(0xFF233554);

  // ── Gradients ─────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [deepBlue, turquoise],
  );

  static const LinearGradient aquaGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [aqua, teal],
  );

  static const LinearGradient tealGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [teal, green],
  );

  static const LinearGradient oceanGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [deepBlue, Color(0xFF006064)],
  );

  static const LinearGradient cardGradientBlue = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1565C0), Color(0xFF0097A7)],
  );

  static const LinearGradient cardGradientGreen = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00695C), Color(0xFF43A047)],
  );

  static const LinearGradient cardGradientOrange = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE65100), Color(0xFFF57C00)],
  );

  static const LinearGradient cardGradientRed = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFB71C1C), Color(0xFFE53935)],
  );

  static const LinearGradient cardGradientPurple = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4A148C), Color(0xFF7B1FA2)],
  );

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.5, 1.0],
    colors: [deepBlue, Color(0xFF006064), turquoise],
  );
}
