import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/constants/app_enums.dart';
import '../../../../../../core/constants/app_sizes.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_style.dart';
import '../../../../../auth/data/models/user.dart';

class UserSummaryCard extends StatelessWidget {
  const UserSummaryCard({super.key, required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _LargeAvatar(user: user),
          AppSizes.gapH14,
          Text(
            _fallback(user.userName, 'Chưa có tên'),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTypography.bold20(color: AppColors.textPrimary),
          ),
          AppSizes.gapH8,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.mail_outline, size: 16.sp, color: AppColors.textMuted),
              AppSizes.gapW6,
              Flexible(
                child: Text(
                  _fallback(user.email, 'Chưa có email'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.medium14(color: AppColors.textMuted),
                ),
              ),
            ],
          ),
          AppSizes.gapH18,
          const Divider(color: AppColors.divider, height: 1),
          AppSizes.gapH18,
          _UidRow(userId: user.userId),
        ],
      ),
    );
  }

  String _fallback(String value, String placeholder) =>
      value.trim().isEmpty ? placeholder : value.trim();
}

class _LargeAvatar extends StatelessWidget {
  const _LargeAvatar({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = user.avatarUrl?.trim() ?? '';
    return Container(
      width: 110.w,
      height: 110.w,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _roleColor(user.role).withValues(alpha: 0.16),
        border: Border.all(
          color: _roleColor(user.role).withValues(alpha: 0.28),
          width: 2.w,
        ),
      ),
      child: ClipOval(
        child: avatarUrl.isEmpty
            ? Image.asset('assets/images/profile.png')
            : CachedNetworkImage(
                imageUrl: avatarUrl,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) =>
                    Image.asset('assets/images/profile.png'),
              ),
      ),
    );
  }

  Color _roleColor(UserRole role) {
    return switch (role) {
      UserRole.admin => AppColors.warning,
      UserRole.landlord => AppColors.info,
      UserRole.tenant => AppColors.primary,
    };
  }
}

class _UidRow extends StatelessWidget {
  const _UidRow({required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        await Clipboard.setData(ClipboardData(text: userId));
        if (!context.mounted) {
          return;
        }
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                'Đã sao chép UID',
                style: AppTypography.medium14(color: AppColors.surface),
              ),
              backgroundColor: AppColors.info,
              behavior: SnackBarBehavior.floating,
            ),
          );
      },
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'UID:',
              style: AppTypography.medium12(color: AppColors.textMuted),
            ),
            AppSizes.gapW6,
            Flexible(
              child: Text(
                userId,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bold12(color: AppColors.textSecondary),
              ),
            ),
            AppSizes.gapW12,
            Icon(Icons.copy, size: 16.sp, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
