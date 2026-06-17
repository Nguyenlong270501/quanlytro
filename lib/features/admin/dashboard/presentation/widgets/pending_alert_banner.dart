import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_style.dart';

class PendingAlertBanner extends StatelessWidget {
  const PendingAlertBanner({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.warningSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.warningBorder.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 20.sp, color: AppColors.warning),
          AppSizes.gapW10,
          Expanded(
            child: Text(
              'Có $count đơn và bài đăng đang chờ duyệt — cần xử lý ngay!',
              style: AppTypography.medium12(
                color: AppColors.warningStrongText,
              ).copyWith(height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
