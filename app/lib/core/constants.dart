import 'package:flutter/material.dart';

class AppColors {
  // Primary palette — extracted from logo
  static const Color primary = Color(0xFF1B5E5F);       // Deep emerald (house outline)
  static const Color primaryDark = Color(0xFF0E3D3E);    // Darker emerald
  static const Color accent = Color(0xFFD4A373);         // Warm gold (furniture/stars)
  static const Color accentLight = Color(0xFFE8C9A0);    // Light gold

  // Backgrounds
  static const Color background = Color(0xFFFDF8F3);     // Warm cream
  static const Color cardSurface = Color(0xFFFFFFFF);     // Pure white
  static const Color secondary = Color(0xFFF7F3EF);       // Warm sand

  // Text
  static const Color primaryText = Color(0xFF1A1A2E);     // Rich dark
  static const Color secondaryText = Color(0xFF7C8291);   // Muted grey
  static const Color tertiaryText = Color(0xFFAEB3BE);    // Light grey

  // Utility
  static const Color divider = Color(0xFFE8E6E1);        // Warm divider
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1B5E5F), Color(0xFF0E3D3E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFD4A373), Color(0xFFBF8A5E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [Color(0xFFFDF8F3), Color(0xFFF0EBE3)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

