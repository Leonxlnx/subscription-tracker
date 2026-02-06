import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // === PREMIUM ZINC-DARK PALETTE ===
  static const Color background = Color(0xFF050505);
  static const Color surface = Color(0xFF0F0F0F);
  static const Color surfaceElevated = Color(0xFF161616);
  static const Color surfaceLight = Color(0xFF1E1E1E);
  static const Color surfaceBright = Color(0xFF262626);
  
  static const Color textPrimary = Color(0xFFE8E8E8);
  static const Color textSecondary = Color(0xFFA0A0A0);
  static const Color textMuted = Color(0xFF6B6B6B);
  static const Color textSubtle = Color(0xFF3A3A3A);
  
  // Warm accent — muted amber/gold (premium, not flashy)
  static const Color accent = Color(0xFFD4A574);
  static const Color accentMuted = Color(0xFF8B7355);
  static const Color accentSubtle = Color(0xFF3D2E1F);
  
  // Status
  static const Color success = Color(0xFF5CB97A);
  static const Color warning = Color(0xFFE0A84D);
  static const Color danger = Color(0xFFCF6565);
  
  // Soft borders & shadows
  static Color border = Colors.white.withValues(alpha: 0.05);
  static Color borderLight = Colors.white.withValues(alpha: 0.08);
  static Color shadowDeep = Colors.black.withValues(alpha: 0.6);
  static Color shadowSoft = Colors.black.withValues(alpha: 0.3);
  static Color glow = const Color(0xFFD4A574).withValues(alpha: 0.05);
  
  // Category palette — muted, sophisticated tones
  static const Map<String, Color> categoryColors = {
    'streaming': Color(0xFFC75B5B),
    'music': Color(0xFF8B6BB5),
    'cloud': Color(0xFF5B8EC7),
    'gaming': Color(0xFFC75B7A),
    'fitness': Color(0xFF5BB58B),
    'news': Color(0xFFB5985B),
    'productivity': Color(0xFF5B9EC7),
    'education': Color(0xFF7A8BC7),
    'other': Color(0xFF707070),
  };
  
  static Color getCategoryColor(String category) {
    return categoryColors[category.toLowerCase()] ?? textMuted;
  }
  
  // === NEUMORPHIC CARDS ===
  static BoxDecoration softCard({double radius = 28}) {
    return BoxDecoration(
      color: surface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: border, width: 0.5),
      boxShadow: [
        BoxShadow(color: shadowDeep, offset: const Offset(0, 6), blurRadius: 20),
        BoxShadow(color: Colors.white.withValues(alpha: 0.015), offset: const Offset(0, -1), blurRadius: 2),
      ],
    );
  }
  
  static BoxDecoration softCardElevated({double radius = 28}) {
    return BoxDecoration(
      color: surfaceElevated,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderLight, width: 0.5),
      boxShadow: [
        BoxShadow(color: shadowDeep, offset: const Offset(0, 10), blurRadius: 32),
        BoxShadow(color: Colors.white.withValues(alpha: 0.02), offset: const Offset(0, -1), blurRadius: 4),
      ],
    );
  }

  static BoxDecoration softInset({double radius = 20}) {
    return BoxDecoration(
      color: const Color(0xFF0A0A0A),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: Colors.black.withValues(alpha: 0.4), width: 0.5),
    );
  }
  
  static BoxDecoration accentGlow({double radius = 28}) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [accentSubtle, accentSubtle.withValues(alpha: 0.3)],
      ),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: accent.withValues(alpha: 0.12), width: 0.5),
      boxShadow: [
        BoxShadow(color: accent.withValues(alpha: 0.06), blurRadius: 24, spreadRadius: -4),
      ],
    );
  }
  
  // === THEME DATA ===
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        surface: surface,
        primary: accent,
        secondary: accentMuted,
        error: danger,
      ),
      textTheme: GoogleFonts.interTextTheme(
        const TextTheme(
          displayLarge: TextStyle(fontSize: 48, fontWeight: FontWeight.w800, color: textPrimary, letterSpacing: -2, height: 1.05),
          displayMedium: TextStyle(fontSize: 34, fontWeight: FontWeight.w700, color: textPrimary, letterSpacing: -1.2, height: 1.1),
          headlineLarge: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: textPrimary, letterSpacing: -0.6),
          headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary, letterSpacing: -0.3),
          titleLarge: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: textPrimary),
          titleMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: textPrimary),
          bodyLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: textSecondary),
          bodyMedium: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: textSecondary),
          labelLarge: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textPrimary, letterSpacing: 0.3),
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(color: border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF0A0A0A),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: accent.withValues(alpha: 0.4), width: 1)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        hintStyle: const TextStyle(color: textMuted, fontWeight: FontWeight.w400),
      ),
    );
  }
}
