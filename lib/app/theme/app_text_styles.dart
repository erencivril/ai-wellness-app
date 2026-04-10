import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract final class AppTextStyles {
  static TextStyle displayLarge({Color color = AppColors.cream}) =>
      GoogleFonts.playfairDisplay(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
        color: color,
        height: 1.1,
        letterSpacing: -1.0,
      );

  static TextStyle displayMedium({Color color = AppColors.cream}) =>
      GoogleFonts.playfairDisplay(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
        color: color,
        height: 1.15,
        letterSpacing: -0.5,
      );

  static TextStyle headlineMedium({Color color = AppColors.cream}) =>
      GoogleFonts.playfairDisplay(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.2,
      );

  static TextStyle titleLarge({Color color = AppColors.cream}) =>
      GoogleFonts.playfairDisplay(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.italic,
        color: color,
      );

  static TextStyle bodyLarge({Color color = AppColors.cream}) =>
      GoogleFonts.dmSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.6,
      );

  static TextStyle bodyMedium({Color color = AppColors.cream}) =>
      GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.55,
      );

  static TextStyle bodySmall({Color color = AppColors.creamMuted}) =>
      GoogleFonts.dmSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.4,
      );

  static TextStyle labelMedium({Color color = AppColors.sage}) =>
      GoogleFonts.dmSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: color,
        letterSpacing: 0.5,
      );

  static TextStyle labelSmall({Color color = AppColors.creamMuted}) =>
      GoogleFonts.dmSans(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: color,
        letterSpacing: 0.3,
      );
}
