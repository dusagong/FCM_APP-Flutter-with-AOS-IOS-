import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary Colors - Korail Blue
  static const Color primary = Color(0xFF0066CC);
  static const Color primaryDark = Color(0xFF004C99);
  static const Color primaryLight = Color(0xFF3D8FDB);

  // Secondary Colors - Warm Orange
  static const Color secondary = Color(0xFFFF6B4A);
  static const Color secondaryDark = Color(0xFFE5533A);
  static const Color secondaryLight = Color(0xFFFF8A70);

  // Accent Colors
  static const Color accent = Color(0xFFFFD93D);
  static const Color accentTeal = Color(0xFF00B4A0);

  // Background Colors
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);

  // Text Colors
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Border Colors
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF1F5F9);

  // Status Colors
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFF0066CC),
    Color(0xFF0088FF),
  ];

  static const List<Color> sunriseGradient = [
    Color(0xFFFF6B4A),
    Color(0xFFFFD93D),
  ];

  static const List<Color> twilightGradient = [
    Color(0xFF667EEA),
    Color(0xFF764BA2),
  ];

  // Time-based Course Colors
  static const Color morning = Color(0xFFFFB347);
  static const Color lunch = Color(0xFF87CEEB);
  static const Color afternoon = Color(0xFF98D8C8);
  static const Color evening = Color(0xFF9B59B6);

  // Category Colors
  static const Color cafe = Color(0xFF8B4513);
  static const Color restaurant = Color(0xFFFF6347);
  static const Color tourism = Color(0xFF4CAF50);
  static const Color culture = Color(0xFF9C27B0);
}

class AppTypography {
  static TextStyle get displayLarge => GoogleFonts.notoSansKr(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.2,
        color: AppColors.textPrimary,
      );

  static TextStyle get displayMedium => GoogleFonts.notoSansKr(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.25,
        color: AppColors.textPrimary,
      );

  static TextStyle get displaySmall => GoogleFonts.notoSansKr(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.25,
        height: 1.3,
        color: AppColors.textPrimary,
      );

  static TextStyle get headlineLarge => GoogleFonts.notoSansKr(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 1.35,
        color: AppColors.textPrimary,
      );

  static TextStyle get headlineMedium => GoogleFonts.notoSansKr(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: AppColors.textPrimary,
      );

  static TextStyle get headlineSmall => GoogleFonts.notoSansKr(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: AppColors.textPrimary,
      );

  static TextStyle get titleLarge => GoogleFonts.notoSansKr(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        height: 1.45,
        color: AppColors.textPrimary,
      );

  static TextStyle get titleMedium => GoogleFonts.notoSansKr(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.5,
        color: AppColors.textPrimary,
      );

  static TextStyle get titleSmall => GoogleFonts.notoSansKr(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        height: 1.5,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyLarge => GoogleFonts.notoSansKr(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.6,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyMedium => GoogleFonts.notoSansKr(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.6,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodySmall => GoogleFonts.notoSansKr(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.55,
        color: AppColors.textSecondary,
      );

  static TextStyle get labelLarge => GoogleFonts.notoSansKr(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.4,
        letterSpacing: 0.1,
        color: AppColors.textPrimary,
      );

  static TextStyle get labelMedium => GoogleFonts.notoSansKr(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.4,
        letterSpacing: 0.5,
        color: AppColors.textSecondary,
      );

  static TextStyle get labelSmall => GoogleFonts.notoSansKr(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 1.35,
        letterSpacing: 0.5,
        color: AppColors.textTertiary,
      );

  // Special Styles
  static TextStyle get photoCardQuote => GoogleFonts.nanumMyeongjo(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        height: 1.8,
        letterSpacing: 0.5,
        color: AppColors.textPrimary,
      );

  static TextStyle get hashTag => GoogleFonts.notoSansKr(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        height: 1.4,
        color: AppColors.primary,
      );
}

class AppShadows {
  static List<BoxShadow> get small => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get medium => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get large => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get elevated => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.12),
          blurRadius: 32,
          offset: const Offset(0, 12),
        ),
      ];

  static List<BoxShadow> get colored => [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.25),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];
}

class AppBorderRadius {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double full = 999;
}

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 48;
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        primaryContainer: AppColors.primaryLight,
        secondary: AppColors.secondary,
        secondaryContainer: AppColors.secondaryLight,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: AppColors.textOnPrimary,
        onSecondary: AppColors.textOnPrimary,
        onSurface: AppColors.textPrimary,
        onError: AppColors.textOnPrimary,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        titleTextStyle: AppTypography.headlineSmall,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.lg),
          ),
          textStyle: AppTypography.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          elevation: 0,
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.lg),
          ),
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          textStyle: AppTypography.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTypography.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textTertiary,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceVariant,
        selectedColor: AppColors.primary,
        labelStyle: AppTypography.labelMedium,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.full),
        ),
      ),
    );
  }
}
