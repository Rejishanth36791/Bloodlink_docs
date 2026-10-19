import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Hero Titles (Headline-LG: 24px SemiBold)
  static TextStyle headlineLg = GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textHeadline,
    height: 1.25,
  );

  // Card Headers & Section Titles (Title-MD: 18px SemiBold)
  static TextStyle titleMd = GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textHeadline,
    height: 1.3,
  );

  // Subheaders (Title-SM: 16px SemiBold)
  static TextStyle titleSm = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textHeadline,
  );

  // Narrative Copy & Form Inputs (Body-MD: 14px Regular)
  static TextStyle bodyMd = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textBody,
    height: 1.45,
  );

  // Secondary Body & Labels (Body-SM: 13px Regular/Medium)
  static TextStyle bodySm = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
  );

  // Telemetry, Timestamps & Badges (Caption: 11px Medium)
  static TextStyle caption = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.textMuted,
    letterSpacing: 0.3,
  );

  // Button Labels (15px SemiBold)
  static TextStyle button = GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.2,
  );

  // M3 Aliases
  static TextStyle get headlineLarge => headlineLg;
  static TextStyle get headlineMedium => headlineLg;
  static TextStyle get titleMedium => titleMd;
  static TextStyle get titleSmall => titleSm;
  static TextStyle get bodyMedium => bodyMd;
  static TextStyle get bodySmall => bodySm;
}
