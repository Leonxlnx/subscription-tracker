import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ═══════════════════════════════════════════
  //  SOFT DARK PALETTE — True Neumorphism
  // ═══════════════════════════════════════════
  static const Color background   = Color(0xFF0D0D0D);
  static const Color surface      = Color(0xFF151515);
  static const Color surfaceHigh  = Color(0xFF1A1A1A);
  static const Color surfaceLight = Color(0xFF222222);
  static const Color surfaceBright = Color(0xFF2A2A2A);
  
  static const Color textPrimary   = Color(0xFFEAEAEA);
  static const Color textSecondary = Color(0xFF9E9E9E);
  static const Color textMuted     = Color(0xFF5E5E5E);
  static const Color textSubtle    = Color(0xFF363636);
  
  // Single clean accent — soft warm tone
  static const Color accent       = Color(0xFFC9A87C);
  static const Color accentDim    = Color(0xFF7A6B52);
  
  // Status (muted, sophisticated)
  static const Color success = Color(0xFF6BAF7D);
  static const Color warning = Color(0xFFD4A54B);
  static const Color danger  = Color(0xFFB85C5C);
  
  // ═══════════════════════════════════════════
  //  DUAL-SHADOW NEUMORPHISM
  // ═══════════════════════════════════════════
  // Light bloom (top-left) + Dark floor (bottom-right)
  
  static List<BoxShadow> get softShadows => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.5),
      offset: const Offset(6, 6),
      blurRadius: 14,
    ),
    BoxShadow(
      color: Colors.white.withValues(alpha: 0.02),
      offset: const Offset(-4, -4),
      blurRadius: 10,
    ),
  ];
  
  static List<BoxShadow> get softShadowsLight => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.35),
      offset: const Offset(4, 4),
      blurRadius: 10,
    ),
    BoxShadow(
      color: Colors.white.withValues(alpha: 0.018),
      offset: const Offset(-3, -3),
      blurRadius: 8,
    ),
  ];
  
  // ═══════════════════════════════════════════
  //  CATEGORY COLORS — Clean, harmonious
  // ═══════════════════════════════════════════
  static const Map<String, Color> categoryColors = {
    'streaming':    Color(0xFF5B8EC7),   // steel blue
    'music':        Color(0xFF8B7DBC),   // soft violet
    'cloud':        Color(0xFF5BAAB5),   // teal
    'gaming':       Color(0xFFC77D5B),   // warm clay
    'fitness':      Color(0xFF5BB588),   // sage green
    'news':         Color(0xFFB5A05B),   // muted gold
    'productivity': Color(0xFF7198B5),   // slate blue
    'education':    Color(0xFF8B8BC7),   // periwinkle
    'other':        Color(0xFF777777),   // neutral
  };
  
  static Color getCategoryColor(String category) => 
      categoryColors[category.toLowerCase()] ?? textMuted;
  
  // ═══════════════════════════════════════════
  //  DECORATION HELPERS
  // ═══════════════════════════════════════════
  
  /// Raised neumorphic card — the workhorse
  static BoxDecoration softCard({double radius = 24}) => BoxDecoration(
    color: surface,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: Colors.white.withValues(alpha: 0.04), width: 0.5),
    boxShadow: softShadows,
  );
  
  /// Elevated card with brighter surface
  static BoxDecoration softCardElevated({double radius = 24}) => BoxDecoration(
    color: surfaceHigh,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: Colors.white.withValues(alpha: 0.06), width: 0.5),
    boxShadow: softShadows,
  );
  
  /// Recessed / inset field — looks pressed into the surface
  static BoxDecoration softInset({double radius = 18}) => BoxDecoration(
    color: const Color(0xFF0A0A0A),
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: Colors.black.withValues(alpha: 0.5), width: 0.5),
    boxShadow: [
      // Inner-shadow simulation via a subtle top rim
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.3),
        offset: const Offset(0, 2),
        blurRadius: 4,
      ),
    ],
  );
  
  /// Prominent neumorphic button
  static BoxDecoration softButton({double radius = 18, Color? color}) => BoxDecoration(
    color: color ?? accent,
    borderRadius: BorderRadius.circular(radius),
    border: Border(
      top: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 0.5),
      left: BorderSide(color: Colors.white.withValues(alpha: 0.06), width: 0.5),
      right: BorderSide(color: Colors.black.withValues(alpha: 0.15), width: 0.5),
      bottom: BorderSide(color: Colors.black.withValues(alpha: 0.2), width: 0.5),
    ),
    boxShadow: [
      BoxShadow(color: (color ?? accent).withValues(alpha: 0.2), offset: const Offset(0, 4), blurRadius: 16),
      BoxShadow(color: Colors.black.withValues(alpha: 0.4), offset: const Offset(0, 2), blurRadius: 6),
    ],
  );
  
  /// Pressed / active button state
  static BoxDecoration softButtonPressed({double radius = 18, Color? color}) => BoxDecoration(
    color: (color ?? accent).withValues(alpha: 0.85),
    borderRadius: BorderRadius.circular(radius),
    boxShadow: [
      BoxShadow(color: Colors.black.withValues(alpha: 0.3), offset: const Offset(0, 1), blurRadius: 4),
    ],
  );

  /// Accent-glow card for hero elements
  static BoxDecoration accentGlow({double radius = 24}) => BoxDecoration(
    color: surface,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: accent.withValues(alpha: 0.1), width: 0.5),
    boxShadow: [
      BoxShadow(color: accent.withValues(alpha: 0.06), blurRadius: 20, spreadRadius: -4),
      ...softShadowsLight,
    ],
  );
  
  // ═══════════════════════════════════════════
  //  THEME DATA
  // ═══════════════════════════════════════════
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        surface: surface,
        primary: accent,
        secondary: accentDim,
        error: danger,
      ),
      textTheme: GoogleFonts.interTextTheme(
        const TextTheme(
          displayLarge:  TextStyle(fontSize: 42, fontWeight: FontWeight.w800, color: textPrimary, letterSpacing: -1.5, height: 1.1),
          displayMedium: TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: textPrimary, letterSpacing: -1.0, height: 1.15),
          headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: textPrimary, letterSpacing: -0.5),
          headlineMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary),
          titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary),
          titleMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textPrimary),
          bodyLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: textSecondary),
          bodyMedium: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: textSecondary),
          labelLarge: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textMuted, letterSpacing: 1.2),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF0A0A0A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.4)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.04)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: accent.withValues(alpha: 0.35), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        hintStyle: const TextStyle(color: textMuted, fontWeight: FontWeight.w400),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected) ? accent : textMuted),
        trackColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected)
              ? accent.withValues(alpha: 0.25) : surfaceLight),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
    );
  }
}
