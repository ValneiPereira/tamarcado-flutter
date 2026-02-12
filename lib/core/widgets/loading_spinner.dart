import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';

class LoadingSpinner extends StatelessWidget {
  final bool fullScreen;
  final String? text;
  final Color? color;

  const LoadingSpinner({
    super.key,
    this.fullScreen = false,
    this.text,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(color: color ?? AppColors.primary),
        if (text != null) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            text!,
            style: const TextStyle(
              fontSize: AppTypography.base,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );

    if (fullScreen) {
      return Container(
        color: AppColors.background,
        child: Center(child: content),
      );
    }

    return Center(child: content);
  }
}
