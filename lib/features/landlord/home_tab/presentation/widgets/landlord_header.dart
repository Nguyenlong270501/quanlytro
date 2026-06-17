import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_style.dart';

class LandlordHeader extends StatelessWidget {
  const LandlordHeader({
    super.key,
    required this.name,
    this.avatarUrl,
  });

  static const String _fallbackAvatarAsset = 'assets/images/profile.png';

  final String name;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final trimmedName = name.trim();
    final greetingName = trimmedName.isEmpty
        ? 'Chủ trọ'
        : 'Chủ trọ $trimmedName';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.textMuted.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          _Avatar(avatarUrl: avatarUrl),
          AppSizes.gapW12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'XIN CHÀO,',
                  style: AppTypography.medium10(color: AppColors.textSecondary),
                ),
                AppSizes.gapH6,
                Text(
                  greetingName,
                  style: AppTypography.bold18(color: AppColors.textPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.avatarUrl});

  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final hasRemoteAvatar = avatarUrl != null && avatarUrl!.trim().isNotEmpty;

    return Container(
      width: 40.w,
      height: 40.w,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: hasRemoteAvatar
          ? Image.network(
              avatarUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _buildAssetFallback(),
            )
          : _buildAssetFallback(),
    );
  }

  Widget _buildAssetFallback() {
    return Image.asset(LandlordHeader._fallbackAvatarAsset, fit: BoxFit.cover);
  }
}


