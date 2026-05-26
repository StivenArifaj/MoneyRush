import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppSpacing {
  static const double xs  = 4.0;
  static const double sm  = 8.0;
  static const double md  = 16.0;
  static const double lg  = 24.0;
  static const double xl  = 32.0;
  static const double xxl = 48.0;
}

class AppRadius {
  static const sm   = BorderRadius.all(Radius.circular(12));
  static const md   = BorderRadius.all(Radius.circular(16));
  static const lg   = BorderRadius.all(Radius.circular(24));
  static const xl   = BorderRadius.all(Radius.circular(32));
  static const full = BorderRadius.all(Radius.circular(999));
}

// Not const — BoxShadow uses runtime Color.withValues calls.
class AppShadows {
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.3),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get goldGlow => [
        BoxShadow(
          color: AppColors.primaryGlow,
          blurRadius: 24,
          spreadRadius: 0,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get tealGlow => [
        BoxShadow(
          color: AppColors.accentGlow,
          blurRadius: 20,
          spreadRadius: 0,
        ),
      ];
}
