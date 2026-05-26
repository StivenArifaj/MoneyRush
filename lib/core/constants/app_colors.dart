import 'package:flutter/material.dart';

class AppColors {
  // Primary — MoneyRush Gold
  static const primary        = Color(0xFFFFB800);
  static const primaryDark    = Color(0xFFE6A500);
  static const primaryLight   = Color(0xFFFFD166);
  static const primaryGlow    = Color(0x33FFB800); // ~20% opacity

  // Secondary — Deep Navy
  static const secondary      = Color(0xFF1A1F3A);
  static const secondaryMid   = Color(0xFF252B4A);
  static const secondaryLight = Color(0xFF2F3660);

  // Accent — Electric Teal
  static const accent         = Color(0xFF00D4AA);
  static const accentDark     = Color(0xFF00A882);
  static const accentGlow     = Color(0x2200D4AA); // ~13% opacity

  // Semantic
  static const success        = Color(0xFF2ECC71);
  static const successBg      = Color(0x1A2ECC71);
  static const danger         = Color(0xFFE74C3C);
  static const dangerBg       = Color(0x1AE74C3C);
  static const warning        = Color(0xFFFF6B35);
  static const warningBg      = Color(0x1AFF6B35);
  static const info           = Color(0xFF3498DB);

  // Text
  static const textPrimary    = Color(0xFFFFFFFF);
  static const textSecondary  = Color(0xFFB0B8D4);
  static const textMuted      = Color(0xFF6B7399);
  static const textOnGold     = Color(0xFF1A1F3A);

  // Surfaces
  static const surface         = Color(0xFF1E2340);
  static const surfaceElevated = Color(0xFF252B4A);
  static const surfaceBorder   = Color(0xFF2F3660);
  static const background      = Color(0xFF12162B);

  // Score dimension colors
  static const scoreWealth    = Color(0xFFFFB800);
  static const scoreStability = Color(0xFF00D4AA);
  static const scoreGrowth    = Color(0xFF7C6FCD);
  static const scoreFreedom   = Color(0xFF3498DB);
  static const scoreWellbeing = Color(0xFFFF6B8A);

  // District colors (city map)
  static const residential       = Color(0xFFFF9A3C);
  static const workDistrict      = Color(0xFF2196F3);
  static const marketZone        = Color(0xFFFFB800);
  static const financialDistrict = Color(0xFF7C6FCD);
  static const educationQuarter  = Color(0xFF2ECC71);
  static const socialZone        = Color(0xFFFF6B8A);

  // Backward-compatibility aliases so existing screens keep compiling
  static const primaryDarkAlias = primaryDark;
  static const card              = surfaceBorder;
  static const wealth            = scoreWealth;
  static const stability         = scoreStability;
  static const growth            = scoreGrowth;
  static const freedom           = scoreFreedom;
  static const wellbeing         = scoreWellbeing;
}
