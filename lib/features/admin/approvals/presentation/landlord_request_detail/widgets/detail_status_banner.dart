import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/constants/app_sizes.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_style.dart';

class DetailStatusBanner extends StatelessWidget {
  const DetailStatusBanner({
    super.key,
    required this.isApproved,
    required this.statusTitle,
    this.rejectionReason,
  });

  final bool isApproved;
  final String statusTitle;
  final String? rejectionReason;

  @override
  Widget build(BuildContext context) {
    final accent = isApproved ? AppColors.primary : AppColors.error;
    final softBg = isApproved ? AppColors.successSoft : AppColors.errorSoft;
    final icon = isApproved
        ? Icons.verified_outlined
        : Icons.cancel_outlined;
    final reason = rejectionReason?.trim() ?? '';
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: softBg,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: accent.withValues(alpha: 0.25)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: accent, size: 20.sp),
            AppSizes.gapW10,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    statusTitle,
                    style: AppTypography.bold14(color: accent),
                  ),
                  if (!isApproved && reason.isNotEmpty) ...[
                    AppSizes.gapH4,
                    Text(
                      'Lý do: $reason',
                      style: AppTypography.medium12(
                        color: AppColors.textSecondary,
                      ).copyWith(height: 1.4),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
