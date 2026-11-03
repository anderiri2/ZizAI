import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Paleta de colores inspirada en el otoño de los bosques.
class AutumnColors {
  AutumnColors._();

  // Fondos cálidos y orgánicos
  static const Color parchmentBg = Color(0xFFFBF6EE);
  static const Color creamCard = Color(0xFFF5EBDC);
  static const Color parchmentCard = creamCard;
  static const Color warmSand = Color(0xFFEADBC4);

  // Tonos oscuros de corteza y bosque nocturno
  static const Color barkDark = Color(0xFF23160F);
  static const Color boletusBrown = Color(0xFF4A2C1D);
  static const Color chestnut = Color(0xFF6E3F26);

  // Acentos otoñales (Ziza horia, Esnegorri, Hayedo)
  static const Color ochreGold = Color(0xFFD9822B);
  static const Color amberLeaf = Color(0xFFE8A331);
  static const Color terracotta = Color(0xFFB84A27);
  static const Color rustRed = Color(0xFF9E331E);
  static const Color mossGreen = Color(0xFF3E5C38);
  static const Color fernGreen = Color(0xFF567D46);

  // Textos
  static const Color textPrimary = Color(0xFF261810);
  static const Color textSecondary = Color(0xFF634838);
  static const Color textMuted = Color(0xFF8C705F);

  // Semáforo micológico de comestibilidad
  static const Color edibilityExcellent = Color(0xFF2E6F40);
  static const Color edibilityGood = Color(0xFF558B2F);
  static const Color edibilityCaution = Color(0xFFD97706);
  static const Color cautionOrange = edibilityCaution;
  static const Color edibilityNonEdible = Color(0xFF6B7280);
  static const Color edibilityToxic = Color(0xFFDC2626);
  static const Color dangerRed = edibilityToxic;
  static const Color edibilityDeadly = Color(0xFF7F1D1D);
}

class AutumnTheme {
  AutumnTheme._();

  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme();
    final serifHeading = GoogleFonts.frauncesTextTheme();

    final colorScheme = ColorScheme.fromSeed(
      seedColor: AutumnColors.boletusBrown,
      brightness: Brightness.light,
      primary: AutumnColors.boletusBrown,
      onPrimary: Colors.white,
      secondary: AutumnColors.ochreGold,
      onSecondary: Colors.white,
      tertiary: AutumnColors.mossGreen,
      surface: AutumnColors.parchmentBg,
      onSurface: AutumnColors.textPrimary,
      error: AutumnColors.edibilityToxic,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AutumnColors.parchmentBg,
      textTheme: baseTextTheme.copyWith(
        displayLarge: serifHeading.displayLarge?.copyWith(
          color: AutumnColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
        displayMedium: serifHeading.displayMedium?.copyWith(
          color: AutumnColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
        headlineLarge: serifHeading.headlineLarge?.copyWith(
          color: AutumnColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
        headlineMedium: serifHeading.headlineMedium?.copyWith(
          color: AutumnColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
        headlineSmall: serifHeading.headlineSmall?.copyWith(
          color: AutumnColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          color: AutumnColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: baseTextTheme.titleMedium?.copyWith(
          color: AutumnColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          color: AutumnColors.textPrimary,
          height: 1.45,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          color: AutumnColors.textSecondary,
          height: 1.45,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AutumnColors.parchmentBg.withValues(alpha: 0.92),
        foregroundColor: AutumnColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: serifHeading.headlineSmall?.copyWith(
          color: AutumnColors.boletusBrown,
          fontWeight: FontWeight.w700,
          fontSize: 22,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: AutumnColors.warmSand.withValues(alpha: 0.8),
            width: 1,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AutumnColors.creamCard,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AutumnColors.warmSand.withValues(alpha: 0.9),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AutumnColors.ochreGold,
            width: 1.8,
          ),
        ),
        hintStyle: const TextStyle(color: AutumnColors.textMuted),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AutumnColors.boletusBrown,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AutumnColors.creamCard,
        selectedColor: AutumnColors.ochreGold,
        labelStyle: const TextStyle(
          color: AutumnColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
        secondaryLabelStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AutumnColors.warmSand.withValues(alpha: 0.8)),
        ),
      ),
    );
  }
}
