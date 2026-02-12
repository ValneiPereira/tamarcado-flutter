import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final int maxRating;
  final double size;
  final bool showValue;
  final bool showCount;
  final int? count;
  final bool interactive;
  final ValueChanged<int>? onRatingChange;

  const StarRating({
    super.key,
    required this.rating,
    this.maxRating = 5,
    this.size = 20,
    this.showValue = true,
    this.showCount = false,
    this.count,
    this.interactive = false,
    this.onRatingChange,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(maxRating, _buildStar),
        ),
        if (showValue) ...[
          const SizedBox(width: AppSpacing.xs),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: size * 0.7,
              fontWeight: AppTypography.semibold,
              color: AppColors.text,
            ),
          ),
        ],
        if (showCount && count != null) ...[
          const SizedBox(width: AppSpacing.xs),
          Text(
            '($count)',
            style: TextStyle(
              fontSize: size * 0.6,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStar(int index) {
    final filled = index < rating.floor();
    final halfFilled = index == rating.floor() && (rating % 1) >= 0.5;

    IconData iconData;
    Color color;

    if (filled) {
      iconData = Icons.star;
      color = AppColors.star;
    } else if (halfFilled) {
      iconData = Icons.star_half;
      color = AppColors.star;
    } else {
      iconData = Icons.star_outline;
      color = AppColors.gray300;
    }

    final star = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1),
      child: Icon(iconData, size: size, color: color),
    );

    if (interactive) {
      return GestureDetector(
        onTap: () => onRatingChange?.call(index + 1),
        child: star,
      );
    }

    return star;
  }
}
