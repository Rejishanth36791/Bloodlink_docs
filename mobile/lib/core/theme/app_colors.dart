import 'package:flutter/material.dart';

class AppColors {
  // Primary Clinical Palette
  static const Color primaryMain = Color(0xFF0C549C);
  static const Color primaryDark = Color(0xFF073C6E);
  static const Color primaryLight = Color(0xFFE9F2FA);

  // Functional Semantic Tokens
  static const Color aiIntelligence = Color(0xFF14919B);
  static const Color aiLight = Color(0xFFE0F7FA);
  static const Color lifeGreen = Color(0xFF3CB454);
  static const Color lifeGreenLight = Color(0xFFE8F8ED);
  static const Color criticalRed = Color(0xFFD32F2F);
  static const Color criticalRedLight = Color(0xFFFDE8E8);
  static const Color amberWarning = Color(0xFFD97706);
  static const Color amberWarningLight = Color(0xFFFEF3C7);

  // Surfaces & Canvas
  static const Color canvasTint = Color(0xFFF6FAFC);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color cardShadow = Color(0x0D0C549C);

  // Neutral Typography & Borders
  static const Color textHeadline = Color(0xFF1A202C);
  static const Color textBody = Color(0xFF4A5568);
  static const Color textMuted = Color(0xFF718096);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderActive = Color(0xFF0C549C);

  // Status Badges & Indicators
  static const Color badgePendingBg = Color(0xFFEBF4FF);
  static const Color badgePendingText = Color(0xFF2B6CB0);
  static const Color badgeApprovedBg = Color(0xFFDEF7EC);
  static const Color badgeApprovedText = Color(0xFF03543F);
  static const Color badgeCriticalBg = Color(0xFFFDE8E8);
  static const Color badgeCriticalText = Color(0xFF9B1C1C);

  // Semantic Aliases
  static const Color primaryNavy = primaryMain;
  static const Color secondaryNavy = primaryDark;
  static const Color secondaryTeal = aiIntelligence;
  static const Color successGreen = lifeGreen;
  static const Color accentCrimson = criticalRed;
  static const Color backgroundLight = canvasTint;
  static const Color textPrimary = textHeadline;
  static const Color textSecondary = textMuted;
  static const Color surfaceLight = canvasTint;
}
