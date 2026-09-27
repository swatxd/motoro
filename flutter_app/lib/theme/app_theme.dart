import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Aura Drive - Connected Vehicle Telemetry System Color Palette & Theme.
/// This theme is designed to be reused across all screens (Diagnostics,
/// Battery Health, Live GPS, OBD-II Telemetry, and Settings).
class AppColors {
  // Brand Primaries (Cyan Teal)
  static const Color primary = Color(0xFF006A68);
  static const Color primaryContainer = Color(0xFF2BB5B2);
  static const Color primaryFixed = Color(0xFF7BF6F2);
  static const Color primaryFixedDim = Color(0xFF5BD9D6);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFF004140);
  static const Color onPrimaryFixed = Color(0xFF00201F);
  static const Color onSecondaryFixed = Color(0xFF0A1F1F);

  // Secondaries
  static const Color secondary = Color(0xFF4D6262);
  static const Color secondaryContainer = Color(0xFFD0E7E6);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = Color(0xFF536868);

  // Tertiaries
  static const Color tertiary = Color(0xFF006A67);
  static const Color tertiaryContainer = Color(0xFF4EB2AF);
  static const Color tertiaryFixedDim = Color(0xFF75D6D2);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color onTertiaryContainer = Color(0xFF00413F);

  // Surfaces & Backgrounds
  static const Color background = Color(0xFFF4FAFA);
  static const Color onBackground = Color(0xFF161D1D);
  static const Color surface = Color(0xFFF4FAFA);
  static const Color surfaceDim = Color(0xFFD5DBDB);
  static const Color surfaceBright = Color(0xFFF4FAFA);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFEFF5F5);
  static const Color surfaceContainer = Color(0xFFE9EFEF);
  static const Color surfaceContainerHigh = Color(0xFFE3E9E9);
  static const Color surfaceContainerHighest = Color(0xFFDDE4E4);
  static const Color onSurface = Color(0xFF161D1D);
  static const Color onSurfaceVariant = Color(0xFF3D4948);

  // Outlines & Borders
  static const Color outline = Color(0xFF6C7A79);
  static const Color outlineVariant = Color(0xFFBCC9C8);

  // Status & Errors
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFD97706);
  static const Color emerald = Color(0xFF10B981);
  static const Color emeraldDark = Color(0xFF006C4C);
  static const Color electric = Color(0xFF00E5FF);
}

class AppGradients {
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [AppColors.primaryContainer, AppColors.primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryGlow = LinearGradient(
    colors: [AppColors.primary, AppColors.primaryContainer],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassBorderGradient = LinearGradient(
    colors: [Color(0xD9FFFFFF), Color(0x402BB5B2), Color(0x66FFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundShimmer = LinearGradient(
    colors: [Color(0xEEF4FAFA), Color(0x99F4FAFA), Color(0x307BF6F2)],
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
  );
}

class AppTypography {
  /// Brand / Display Typography (Outfit: geometric, wide-aperture, automotive precision)
  static TextStyle display({
    double fontSize = 28,
    FontWeight fontWeight = FontWeight.w800,
    Color color = AppColors.onSurface,
    double letterSpacing = -0.8,
  }) =>
      GoogleFonts.outfit(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
      );

  /// Section & Card Headings (Outfit)
  static TextStyle heading({
    double fontSize = 20,
    FontWeight fontWeight = FontWeight.w700,
    Color color = AppColors.onSurface,
    double letterSpacing = -0.5,
  }) =>
      GoogleFonts.outfit(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
      );

  /// Subheadings & Important UI Labels (Plus Jakarta Sans: crisp digital UI legibility)
  static TextStyle subheading({
    double fontSize = 15,
    FontWeight fontWeight = FontWeight.w600,
    Color color = AppColors.onSurface,
    double letterSpacing = -0.2,
  }) =>
      GoogleFonts.plusJakartaSans(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
      );

  /// General Body Text (Plus Jakarta Sans)
  static TextStyle body({
    double fontSize = 13,
    FontWeight fontWeight = FontWeight.w400,
    Color color = AppColors.onSurfaceVariant,
    double height = 1.4,
  }) =>
      GoogleFonts.plusJakartaSans(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
      );

  /// Secondary small body & descriptions (Plus Jakarta Sans)
  static TextStyle bodySmall({
    double fontSize = 11,
    FontWeight fontWeight = FontWeight.w400,
    Color color = AppColors.outline,
    double height = 1.35,
  }) =>
      GoogleFonts.plusJakartaSans(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
      );

  /// Badges, Chips & Meta Labels (Plus Jakarta Sans with balanced letter spacing)
  static TextStyle label({
    double fontSize = 11,
    FontWeight fontWeight = FontWeight.w600,
    Color color = AppColors.primary,
    double letterSpacing = 0.3,
  }) =>
      GoogleFonts.plusJakartaSans(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
      );

  /// Micro-caps category tags (e.g. "ODOMETER", "RECOMMENDED")
  static TextStyle tag({
    double fontSize = 9.5,
    FontWeight fontWeight = FontWeight.w700,
    Color color = AppColors.onSurfaceVariant,
    double letterSpacing = 0.6,
  }) =>
      GoogleFonts.plusJakartaSans(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
      );

  /// Telemetry Numbers, Odometer & Currency (Outfit with tabular numbers)
  static TextStyle stat({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w800,
    Color color = AppColors.onSurface,
    double letterSpacing = -0.3,
  }) =>
      GoogleFonts.outfit(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
      );

  /// Monospace Codes (VIN, Plate, Booking Code, Coordinates - JetBrains Mono)
  static TextStyle mono({
    double fontSize = 12,
    FontWeight fontWeight = FontWeight.w600,
    Color color = AppColors.primary,
    double letterSpacing = 0.2,
  }) =>
      GoogleFonts.jetBrainsMono(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
      );
}

class AppTheme {
  static ThemeData get lightTheme {
    final baseTextTheme = ThemeData.light().textTheme;
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onPrimaryContainer,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.onSecondaryContainer,
        tertiary: AppColors.tertiary,
        onTertiary: AppColors.onTertiary,
        error: AppColors.error,
        onError: AppColors.onError,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(baseTextTheme).copyWith(
        displayLarge: GoogleFonts.outfit(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: AppColors.onSurface,
          letterSpacing: -1.0,
        ),
        displayMedium: GoogleFonts.outfit(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: AppColors.onSurface,
          letterSpacing: -0.8,
        ),
        displaySmall: GoogleFonts.outfit(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.onSurface,
          letterSpacing: -0.6,
        ),
        headlineLarge: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: AppColors.onSurface,
          letterSpacing: -0.6,
        ),
        headlineMedium: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.onSurface,
          letterSpacing: -0.5,
        ),
        headlineSmall: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.onSurface,
          letterSpacing: -0.4,
        ),
        titleLarge: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.onSurface,
          letterSpacing: -0.3,
        ),
        titleMedium: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
        titleSmall: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurfaceVariant,
        ),
        bodyLarge: GoogleFonts.plusJakartaSans(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: AppColors.onSurface,
          height: 1.45,
        ),
        bodyMedium: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: AppColors.onSurfaceVariant,
          height: 1.4,
        ),
        bodySmall: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: AppColors.outline,
          height: 1.35,
        ),
        labelLarge: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
        labelMedium: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
        labelSmall: GoogleFonts.plusJakartaSans(
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.9),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppColors.outline.withValues(alpha: 0.25),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppColors.outline.withValues(alpha: 0.25),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 1.4),
        ),
        hintStyle: GoogleFonts.plusJakartaSans(
          color: AppColors.outlineVariant,
          fontSize: 13,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            letterSpacing: 0.2,
          ),
          elevation: 3,
          shadowColor: AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  static Color get primaryColor => AppColors.primary;
  
  static TextStyle get headlineStyle => GoogleFonts.outfit(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: AppColors.onBackground,
    letterSpacing: -0.6,
  );

  static Color get surfaceColor => AppColors.surface;

  static BoxDecoration get glassDecoration => BoxDecoration(
    color: Colors.white.withValues(alpha: 0.88),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: Colors.white.withValues(alpha: 0.95), width: 1.5),
    boxShadow: [
      BoxShadow(
        color: AppColors.primary.withValues(alpha: 0.05),
        blurRadius: 16,
        offset: const Offset(0, 4),
      ),
    ],
  );
}
