import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

enum AvatarSize { small, medium, large, xlarge, xxlarge }

class AppAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final String? emoji;
  final AvatarSize size;

  const AppAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.emoji,
    this.size = AvatarSize.medium,
  });

  double get _dimension {
    switch (size) {
      case AvatarSize.small:
        return 32;
      case AvatarSize.medium:
        return 48;
      case AvatarSize.large:
        return 64;
      case AvatarSize.xlarge:
        return 96;
      case AvatarSize.xxlarge:
        return 120;
    }
  }

  double get _fontSize {
    switch (size) {
      case AvatarSize.small:
        return 14;
      case AvatarSize.medium:
        return 18;
      case AvatarSize.large:
        return 24;
      case AvatarSize.xlarge:
        return 36;
      case AvatarSize.xxlarge:
        return 48;
    }
  }

  String _getInitials(String name) {
    return name
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map((part) => part[0])
        .take(2)
        .join()
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _dimension,
      height: _dimension,
      decoration: const BoxDecoration(
        color: AppColors.gray100,
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: imageUrl!,
        width: _dimension,
        height: _dimension,
        fit: BoxFit.cover,
        placeholder: (_, __) => _buildPlaceholder(),
        errorWidget: (_, __, ___) => _buildFallback(),
      );
    }

    if (emoji != null) {
      return Center(
        child: Text(emoji!, style: TextStyle(fontSize: _fontSize * 1.2)),
      );
    }

    if (name != null && name!.isNotEmpty) {
      return Center(
        child: Text(
          _getInitials(name!),
          style: TextStyle(
            fontSize: _fontSize,
            fontWeight: AppTypography.semibold,
            color: AppColors.primary,
          ),
        ),
      );
    }

    return _buildFallback();
  }

  Widget _buildPlaceholder() {
    return const Center(
      child: SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _buildFallback() {
    return Center(
      child: Text(
        '\u{1F464}',
        style: TextStyle(fontSize: _fontSize * 1.2),
      ),
    );
  }
}
