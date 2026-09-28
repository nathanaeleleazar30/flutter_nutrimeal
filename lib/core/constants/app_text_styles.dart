import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Brand Logo Text
  static TextStyle logoNutri({double fontSize = 34}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      fontWeight: FontWeight.w900,
      color: Colors.black,
      letterSpacing: -0.5,
    );
  }

  static TextStyle logoMeal({double fontSize = 34}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      fontWeight: FontWeight.w900,
      color: AppColors.logoGreen,
      letterSpacing: -0.5,
    );
  }

  // Heading on Login Card
  static TextStyle loginTitle = GoogleFonts.plusJakartaSans(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color: AppColors.textDark,
    height: 1.25,
    letterSpacing: -0.4,
  );

  // Input Field Label
  static TextStyle inputLabel = GoogleFonts.plusJakartaSans(
    fontSize: 11.5,
    fontWeight: FontWeight.w800,
    color: AppColors.textDark,
    letterSpacing: 0.8,
  );

  // Input Field Text & Placeholder
  static TextStyle inputText = GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textDark,
  );

  static TextStyle inputHint = GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );

  // Button Text
  static TextStyle buttonText = GoogleFonts.plusJakartaSans(
    fontSize: 15,
    fontWeight: FontWeight.w800,
    color: AppColors.white,
    letterSpacing: 1.2,
  );

  // Subtle Footer Links
  static TextStyle footerRegular = GoogleFonts.plusJakartaSans(
    fontSize: 11.5,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static TextStyle footerGreenLink = GoogleFonts.plusJakartaSans(
    fontSize: 11.5,
    fontWeight: FontWeight.w700,
    color: AppColors.textGreenLink,
  );

  static TextStyle forgotPassword = GoogleFonts.plusJakartaSans(
    fontSize: 12.5,
    fontWeight: FontWeight.w600,
    color: AppColors.textLinkTeal,
  );

  static TextStyle socialDivider = GoogleFonts.plusJakartaSans(
    fontSize: 11.5,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
  );
}
