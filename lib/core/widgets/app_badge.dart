import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';

enum BadgeVariant { primary, success, warning, error, neutral }

enum BadgeSize { small, medium }

class AppBadge extends StatelessWidget {
  final String label;
  final BadgeVariant variant;
  final BadgeSize size;

  const AppBadge({
    super.key,
    required this.label,
    this.variant = BadgeVariant.neutral,
    this.size = BadgeSize.medium,
  });

  Color get _backgroundColor {
    switch (variant) {
      case BadgeVariant.primary:
        return AppColors.primary.withValues(alpha: 0.12);
      case BadgeVariant.success:
        return AppColors.successLight;
      case BadgeVariant.warning:
        return AppColors.warningLight;
      case BadgeVariant.error:
        return AppColors.errorLight;
      case BadgeVariant.neutral:
        return AppColors.gray100;
    }
  }

  Color get _textColor {
    switch (variant) {
      case BadgeVariant.primary:
        return AppColors.primary;
      case BadgeVariant.success:
        return AppColors.success;
      case BadgeVariant.warning:
        return AppColors.warning;
      case BadgeVariant.error:
        return AppColors.error;
      case BadgeVariant.neutral:
        return AppColors.textSecondary;
    }
  }

  EdgeInsets get _padding {
    switch (size) {
      case BadgeSize.small:
        return const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 2,
        );
      case BadgeSize.medium:
        return const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        );
    }
  }

  double get _fontSize {
    switch (size) {
      case BadgeSize.small:
        return AppTypography.xs;
      case BadgeSize.medium:
        return AppTypography.sm;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: _padding,
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(AppBorderRadius.full),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: _textColor,
          fontSize: _fontSize,
          fontWeight: AppTypography.medium,
        ),
      ),
    );
  }
}
