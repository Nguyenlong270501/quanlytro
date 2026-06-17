import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/constants/app_enums.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_style.dart';
import '../../../../../core/utils/property_helper.dart';
import '../../../../auth/data/models/user.dart';

class AdminUserCard extends StatelessWidget {
  const AdminUserCard({super.key, required this.user, this.onTap});

  final UserModel user;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          padding: EdgeInsets.all(12.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _UserAvatar(user: user),
              AppSizes.gapW12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.userName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bold14(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    AppSizes.gapH4,
                    Text(
                      user.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.medium12(
                        color: AppColors.textMuted,
                      ),
                    ),
                    AppSizes.gapH8,
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 6.h,
                      children: [
                        _StatusChip(
                          label: _roleLabel(user.role),
                          backgroundColor: AppColors.infoSoft,
                          foregroundColor: AppColors.infoDark,
                        ),
                        _StatusChip(
                          label: _statusLabel(user.status),
                          backgroundColor: user.status == UserStatus.active
                              ? AppColors.successSoft
                              : AppColors.errorSoft,
                          foregroundColor: user.status == UserStatus.active
                              ? AppColors.primary
                              : AppColors.danger,
                        ),
                      ],
                    ),
                    AppSizes.gapH6,
                    Text(
                      'Tham gia ${PropertyHelper.formatTimeAgo(user.createdAt)}',
                      style: AppTypography.medium12(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              AppSizes.gapW8,
              Icon(
                Icons.chevron_right,
                color: AppColors.textDisabled,
                size: 22.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _roleLabel(UserRole role) {
    return switch (role) {
      UserRole.landlord => 'Chủ trọ',
      UserRole.tenant => 'Người thuê',
      UserRole.admin => 'Admin',
    };
  }

  static String _statusLabel(UserStatus status) {
    return switch (status) {
      UserStatus.active => 'Hoạt động',
      UserStatus.blocked => 'Đã khóa',
    };
  }
}

class _UserAvatar extends StatelessWidget {
  const _UserAvatar({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = user.avatarUrl?.trim() ?? '';

    if (avatarUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 18.r,
        backgroundColor: AppColors.surfaceMuted,
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: avatarUrl,
            width: 36.r,
            height: 36.r,
            fit: BoxFit.cover,
            errorWidget: (context, url, error) =>
                Image.asset('assets/images/profile.png'),
          ),
        ),
      );
    }

    return CircleAvatar(
      radius: 18.r,
      backgroundColor: AppColors.infoLight,
      child: ClipOval(child: Image.asset('assets/images/profile.png')),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: AppTypography.medium12(color: foregroundColor)),
    );
  }
}
