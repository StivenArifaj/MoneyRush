import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_theme.dart';

class MrCard extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final List<BoxShadow>? shadows;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final bool hasGoldBorder;

  const MrCard({
    super.key,
    required this.child,
    this.backgroundColor,
    this.shadows,
    this.padding,
    this.borderRadius,
    this.hasGoldBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface,
        borderRadius: borderRadius ?? AppRadius.lg,
        border: hasGoldBorder
            ? Border.all(
                color: AppColors.primary.withValues(alpha: 0.4),
                width: 1.5,
              )
            : Border.all(
                color: AppColors.surfaceBorder,
                width: 1,
              ),
        boxShadow: shadows ?? AppShadows.cardShadow,
      ),
      padding: padding ?? const EdgeInsets.all(AppSpacing.md),
      child: child,
    );
  }
}
