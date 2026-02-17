import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF4DA8BC);
  static const Color primaryDark = Color(0xFF1A237E);
  static const Color accent = Color(0xFF00BCD4);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF0B0B0C);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color border = Color(0xFFD1D5DB);
  static const Color highlight = Color(0xFFE0F7FA);

  static const Color earnings = Color(0xFF059669);
  static const Color earningsHighlight = Color(0xFFECFDF5);

  static const Color time = Color(0xFFD97706);
  static const Color timeHighlight = Color(0xFFFFFBEB);

  static const Color info = Color(0xFF2563EB);
  static const Color infoHighlight = Color(0xFFEFF6FF);

  static const Color warning = Color(0xFFDC2626);
  static const Color warningHighlight = Color(0xFFFEF2F2);
}

class AppTypography {
  static const TextStyle heroTitle = TextStyle(
    fontSize: 50,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle heroSubtitle = TextStyle(
    fontSize: 50,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle pageTitle = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySecondary = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const TextStyle button = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.surface,
  );

  static const TextStyle link = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );
}

class AppTheme {
  static ThemeData get light => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primaryDark,
      surface: AppColors.surface,
    ),
    scaffoldBackgroundColor: AppColors.surface,
    fontFamily: 'MedigoSans',
    textTheme:
        const TextTheme(
          displayLarge: TextStyle(fontWeight: FontWeight.w600),
          displayMedium: TextStyle(fontWeight: FontWeight.w600),
          titleLarge: TextStyle(fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(fontWeight: FontWeight.w400),
          bodyMedium: TextStyle(fontWeight: FontWeight.w400),
        ).apply(
          bodyColor: AppColors.textPrimary,
          displayColor: AppColors.textPrimary,
        ),
    useMaterial3: true,
  );
}
