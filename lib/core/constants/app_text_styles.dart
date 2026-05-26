import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

// All text styles are static getters (not const) because GoogleFonts
// returns runtime-constructed TextStyle objects.
class AppTextStyles {
  // ── Display (Sora — large game moments) ────────────────────────────────────

  static TextStyle get displayHero => GoogleFonts.sora(
        fontSize: 40,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
        letterSpacing: -1.0,
        height: 1.1,
      );

  static TextStyle get displayTitle => GoogleFonts.sora(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.5,
      );

  // ── Headings (Nunito) ───────────────────────────────────────────────────────

  static TextStyle get h1 => GoogleFonts.nunito(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      );

  static TextStyle get h2 => GoogleFonts.nunito(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  static TextStyle get h3 => GoogleFonts.nunito(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  // ── Body (Nunito) ───────────────────────────────────────────────────────────

  static TextStyle get bodyLarge => GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.5,
      );

  static TextStyle get body => GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        height: 1.5,
      );

  static TextStyle get caption => GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textMuted,
        letterSpacing: 0.3,
      );

  // ── Special ─────────────────────────────────────────────────────────────────

  static TextStyle get buttonLabel => GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.3,
        color: AppColors.textOnGold,
      );

  static TextStyle get moneyDisplay => GoogleFonts.sora(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
        letterSpacing: -0.5,
      );

  // ── Backward-compatibility aliases (used by existing screens) ───────────────

  static TextStyle get heading1 => displayTitle;
  static TextStyle get heading2 => h1;
  static TextStyle get heading3 => h2;

  static TextStyle get bodySecondary => GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        height: 1.5,
      );

  static TextStyle get button => GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.3,
        color: AppColors.textPrimary,
      );

  static TextStyle get money => moneyDisplay;
}
