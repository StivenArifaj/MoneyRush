import 'package:flutter/material.dart';
import '../core/constants/app_text_styles.dart';

/// Animates smoothly between numeric values instead of jumping.
/// Apply to any number that changes: bank balance, scores, net worth.
class AnimatedNumber extends StatelessWidget {
  final double value;
  final String Function(double) formatter;
  final TextStyle? style;
  final Duration duration;
  final Curve curve;

  const AnimatedNumber({
    super.key,
    required this.value,
    required this.formatter,
    this.style,
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.easeOutCubic,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: value),
      duration: duration,
      curve: curve,
      builder: (context, animatedValue, _) {
        return Text(
          formatter(animatedValue),
          style: style ?? AppTextStyles.moneyDisplay,
        );
      },
    );
  }
}

/// Convenience variant for money values: formats as "$1,234.56"
class AnimatedMoney extends StatelessWidget {
  final double value;
  final TextStyle? style;
  final Duration duration;

  const AnimatedMoney({
    super.key,
    required this.value,
    this.style,
    this.duration = const Duration(milliseconds: 600),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedNumber(
      value: value,
      duration: duration,
      style: style,
      formatter: (v) {
        final abs = v.abs();
        final formatted = abs >= 1000
            ? '\$${(abs / 1000).toStringAsFixed(1)}k'
            : '\$${abs.toStringAsFixed(2)}';
        return v < 0 ? '-$formatted' : formatted;
      },
    );
  }
}

/// Convenience variant for score values: formats as integer "72"
class AnimatedScore extends StatelessWidget {
  final int value;
  final TextStyle? style;
  final Duration duration;

  const AnimatedScore({
    super.key,
    required this.value,
    this.style,
    this.duration = const Duration(milliseconds: 800),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedNumber(
      value: value.toDouble(),
      duration: duration,
      style: style,
      formatter: (v) => v.round().toString(),
    );
  }
}
