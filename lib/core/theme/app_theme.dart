import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ═══════════════════════════════════════════
  //  CLEAN MONOCHROME — True Soft UI
  // ═══════════════════════════════════════════
  static const Color background   = Color(0xFF0D0D0D);
  static const Color surface      = Color(0xFF161616);
  static const Color surfaceHigh  = Color(0xFF1C1C1C);
  static const Color surfaceLight = Color(0xFF242424);
  static const Color surfaceBright = Color(0xFF2E2E2E);
  
  static const Color textPrimary   = Color(0xFFF0F0F0);
  static const Color textSecondary = Color(0xFFA0A0A0);
  static const Color textMuted     = Color(0xFF606060);
  static const Color textSubtle    = Color(0xFF3A3A3A);
  
  // Clean white accent — monochrome
  static const Color accent       = Color(0xFFE8E8E8);
  static const Color accentDim    = Color(0xFF8A8A8A);
  
  // Status (desaturated, sophisticated)
  static const Color success = Color(0xFF6BAF7D);
  static const Color warning = Color(0xFFD4A54B);
  static const Color danger  = Color(0xFFBF6060);
  
  // ═══════════════════════════════════════════
  //  DUAL-SHADOW NEUMORPHISM
  // ═══════════════════════════════════════════
  
  static List<BoxShadow> get softShadows => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.45),
      offset: const Offset(5, 5),
      blurRadius: 12,
    ),
    BoxShadow(
      color: Colors.white.withValues(alpha: 0.025),
      offset: const Offset(-3, -3),
      blurRadius: 8,
    ),
  ];
  
  static List<BoxShadow> get softShadowsLight => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.3),
      offset: const Offset(3, 3),
      blurRadius: 8,
    ),
    BoxShadow(
      color: Colors.white.withValues(alpha: 0.02),
      offset: const Offset(-2, -2),
      blurRadius: 6,
    ),
  ];
  
  // ═══════════════════════════════════════════
  //  CATEGORY COLORS — Muted, sophisticated
  // ═══════════════════════════════════════════
  static const Map<String, Color> categoryColors = {
    'streaming':    Color(0xFF6A9EC9),   // steel blue
    'music':        Color(0xFF9489C4),   // soft violet
    'cloud':        Color(0xFF5FB5B5),   // teal
    'gaming':       Color(0xFFC98A6A),   // warm clay
    'fitness':      Color(0xFF6ABF8A),   // sage
    'news':         Color(0xFFB5A570),   // muted sand
    'productivity': Color(0xFF7BA4C0),   // slate
    'education':    Color(0xFF9494C9),   // periwinkle
    'other':        Color(0xFF808080),   // neutral
  };
  
  static Color getCategoryColor(String category) => 
      categoryColors[category.toLowerCase()] ?? textMuted;
  
  // ═══════════════════════════════════════════
  //  DECORATION HELPERS
  // ═══════════════════════════════════════════
  
  /// Raised neumorphic card
  static BoxDecoration softCard({double radius = 24}) => BoxDecoration(
    color: surface,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: Colors.white.withValues(alpha: 0.04), width: 0.5),
    boxShadow: softShadows,
  );
  
  /// Elevated card
  static BoxDecoration softCardElevated({double radius = 24}) => BoxDecoration(
    color: surfaceHigh,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: Colors.white.withValues(alpha: 0.06), width: 0.5),
    boxShadow: softShadows,
  );
  
  /// Recessed / inset field
  static BoxDecoration softInset({double radius = 18}) => BoxDecoration(
    color: const Color(0xFF0A0A0A),
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: Colors.black.withValues(alpha: 0.5), width: 0.5),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.3),
        offset: const Offset(0, 2),
        blurRadius: 4,
      ),
    ],
  );
  
  /// Prominent button — rounded, monochrome white
  static BoxDecoration softButton({double radius = 22, Color? color}) => BoxDecoration(
    color: color ?? accent,
    borderRadius: BorderRadius.circular(radius),
    border: Border(
      top: BorderSide(color: Colors.white.withValues(alpha: 0.15), width: 0.5),
      left: BorderSide(color: Colors.white.withValues(alpha: 0.08), width: 0.5),
      right: BorderSide(color: Colors.black.withValues(alpha: 0.12), width: 0.5),
      bottom: BorderSide(color: Colors.black.withValues(alpha: 0.18), width: 0.5),
    ),
    boxShadow: [
      BoxShadow(color: (color ?? accent).withValues(alpha: 0.08), offset: const Offset(0, 4), blurRadius: 16),
      BoxShadow(color: Colors.black.withValues(alpha: 0.35), offset: const Offset(0, 2), blurRadius: 6),
    ],
  );
  
  /// Pressed button state
  static BoxDecoration softButtonPressed({double radius = 22, Color? color}) => BoxDecoration(
    color: (color ?? accent).withValues(alpha: 0.85),
    borderRadius: BorderRadius.circular(radius),
    boxShadow: [
      BoxShadow(color: Colors.black.withValues(alpha: 0.3), offset: const Offset(0, 1), blurRadius: 4),
    ],
  );

  /// Subtle outline button
  static BoxDecoration outlineButton({double radius = 22}) => BoxDecoration(
    color: Colors.transparent,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
  );

  /// Neumorphic circle
  static BoxDecoration softCircle({double size = 60, Color? color}) => BoxDecoration(
    color: color ?? surface,
    shape: BoxShape.circle,
    boxShadow: softShadowsLight,
    border: Border.all(color: Colors.white.withValues(alpha: 0.04), width: 0.5),
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
          borderSide: BorderSide(color: accent.withValues(alpha: 0.2), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        hintStyle: const TextStyle(color: textMuted, fontWeight: FontWeight.w400),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected) ? accent : textMuted),
        trackColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected)
              ? accent.withValues(alpha: 0.15) : surfaceLight),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
    );
  }
}
