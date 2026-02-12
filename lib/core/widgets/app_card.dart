import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

enum CardVariant { defaultCard, elevated, outlined }

class AppCard extends StatelessWidget {
  final Widget child;
  final CardVariant variant;
  final VoidCallback? onPress;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const AppCard({
    super.key,
    required this.child,
    this.variant = CardVariant.defaultCard,
    this.onPress,
    this.padding,
    this.margin,
  });

  double get _elevation {
    switch (variant) {
      case CardVariant.defaultCard:
        return 1;
      case CardVariant.elevated:
        return 4;
      case CardVariant.outlined:
        return 0;
    }
  }

  ShapeBorder get _shape {
    if (variant == CardVariant.outlined) {
      return RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.xl),
        side: const BorderSide(color: AppColors.border),
      );
    }
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppBorderRadius.xl),
    );
  }

  @override
  Widget build(BuildContext context) {
    final card = Card(
      elevation: _elevation,
      shape: _shape,
      color: AppColors.surface,
      margin: margin ?? EdgeInsets.zero,
      child: Padding(
        padding: padding ?? const EdgeInsets.all(AppSpacing.md),
        child: child,
      ),
    );

    if (onPress != null) {
      return GestureDetector(
        onTap: onPress,
        child: card,
      );
    }

    return card;
  }
}
