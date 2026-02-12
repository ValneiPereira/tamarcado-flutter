import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';

enum ButtonVariant { primary, secondary, outline, ghost }

enum ButtonSize { small, medium, large }

class AppButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool loading;
  final bool disabled;
  final Widget? icon;
  final ButtonStyle? style;
  final TextStyle? textStyle;

  const AppButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.loading = false,
    this.disabled = false,
    this.icon,
    this.style,
    this.textStyle,
  });

  bool get _isDisabled => disabled || loading;

  double get _minHeight {
    switch (size) {
      case ButtonSize.small:
        return 36;
      case ButtonSize.medium:
        return 48;
      case ButtonSize.large:
        return 56;
    }
  }

  EdgeInsets get _padding {
    switch (size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(
          vertical: AppSpacing.sm,
          horizontal: AppSpacing.md,
        );
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(
          vertical: AppSpacing.md - 4,
          horizontal: AppSpacing.lg,
        );
      case ButtonSize.large:
        return const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.xl,
        );
    }
  }

  double get _fontSize {
    switch (size) {
      case ButtonSize.small:
        return AppTypography.sm;
      case ButtonSize.medium:
        return AppTypography.base;
      case ButtonSize.large:
        return AppTypography.lg;
    }
  }

  Color get _backgroundColor {
    switch (variant) {
      case ButtonVariant.primary:
        return AppColors.primary;
      case ButtonVariant.secondary:
        return AppColors.secondary;
      case ButtonVariant.outline:
      case ButtonVariant.ghost:
        return Colors.transparent;
    }
  }

  Color get _foregroundColor {
    switch (variant) {
      case ButtonVariant.primary:
      case ButtonVariant.secondary:
        return AppColors.textOnPrimary;
      case ButtonVariant.outline:
      case ButtonVariant.ghost:
        return AppColors.primary;
    }
  }

  BorderSide? get _border {
    if (variant == ButtonVariant.outline) {
      return const BorderSide(color: AppColors.primary, width: 2);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: _isDisabled ? 0.5 : 1.0,
      child: MaterialButton(
        onPressed: _isDisabled ? null : onPressed,
        color: _backgroundColor,
        elevation: 0,
        highlightElevation: 0,
        minWidth: double.infinity,
        height: _minHeight,
        padding: _padding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
          side: _border ?? BorderSide.none,
        ),
        child: loading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: _foregroundColor,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    icon!,
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Text(
                    title,
                    style: (textStyle ?? const TextStyle()).copyWith(
                      color: _foregroundColor,
                      fontSize: _fontSize,
                      fontWeight: AppTypography.semibold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
