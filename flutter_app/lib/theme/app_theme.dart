import 'package:flutter/material.dart';

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

class AppTheme {
  static ThemeData get lightTheme {
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
      fontFamily: 'Inter',
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.85),
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
        hintStyle: TextStyle(color: AppColors.outlineVariant, fontSize: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          elevation: 4,
          shadowColor: AppColors.primary.withValues(alpha: 0.35),
        ),
      ),
    );
  }

  static Color get primaryColor => AppColors.primary;
  
  static TextStyle get headlineStyle => const TextStyle(
    fontFamily: 'Inter',
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.onBackground,
    letterSpacing: -0.5,
  );

  static Color get surfaceColor => AppColors.surface;

  static BoxDecoration get glassDecoration => BoxDecoration(
    color: Colors.white.withValues(alpha: 0.85),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: Colors.white.withValues(alpha: 0.9), width: 1.5),
    boxShadow: [
      BoxShadow(
        color: AppColors.primary.withValues(alpha: 0.05),
        blurRadius: 15,
        offset: const Offset(0, 4),
      ),
    ],
  );
}
