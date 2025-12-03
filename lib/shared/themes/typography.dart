import 'package:flutter/material.dart';
import 'package:peach_iq/shared/themes/Appcolors.dart';

class AppTypography {
  // Font Families
  static const String _headingFont = 'DMSerifDisplay';
  static const String _bodyFont = 'NunitoSans';

  static const TextStyle h1 = TextStyle(
    fontFamily: _headingFont,
    fontSize: 32,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: _headingFont,
    fontSize: 28,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: _headingFont,
    fontSize: 24,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle h4 = TextStyle(
    fontFamily: _headingFont,
    fontSize: 20,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle h5 = TextStyle(
    fontFamily: _headingFont,
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle h6 = TextStyle(
    fontFamily: _headingFont,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  // Body Text Styles (Nunito Sans)
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _bodyFont,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _bodyFont,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: _bodyFont,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  // Label Styles (Nunito Sans)
  static const TextStyle labelLarge = TextStyle(
    fontFamily: _bodyFont,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: _bodyFont,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: _bodyFont,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  // Button Styles (DM Serif Display for prominence)
  static const TextStyle buttonLarge = TextStyle(
    fontFamily: _headingFont,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.white,
    height: 1.2,
  );

  static const TextStyle buttonMedium = TextStyle(
    fontFamily: _headingFont,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.white,
    height: 1.2,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontFamily: _bodyFont,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
    height: 1.2,
  );

  // Caption and Overline (Nunito Sans)
  static const TextStyle caption = TextStyle(
    fontFamily: _bodyFont,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textLight,
    height: 1.3,
  );

  static const TextStyle overline = TextStyle(
    fontFamily: _bodyFont,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    height: 1.3,
    letterSpacing: 1.2,
  );

  // Utility Methods
  static TextStyle heading({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
  }) {
    return TextStyle(
      fontFamily: _headingFont,
      fontSize: fontSize ?? 18,
      fontWeight: fontWeight ?? FontWeight.w400,
      color: color ?? AppColors.textPrimary,
      height: height ?? 1.4,
    );
  }

  static TextStyle body({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
  }) {
    return TextStyle(
      fontFamily: _bodyFont,
      fontSize: fontSize ?? 14,
      fontWeight: fontWeight ?? FontWeight.w400,
      color: color ?? AppColors.textPrimary,
      height: height ?? 1.5,
    );
  }
}