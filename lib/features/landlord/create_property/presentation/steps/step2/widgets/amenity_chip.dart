import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../../core/theme/app_colors.dart';
import '../../../../../../../core/theme/app_style.dart';

class AmenityChip extends StatelessWidget {
  const AmenityChip({
    super.key,
    required this.emoji,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color bg =
        active ? AppColors.successSoft : AppColors.scaffoldBackground;
    final Color borderColor = active ? AppColors.primary : AppColors.border;
    final Color textColor =
        active ? AppColors.primary : AppColors.textSecondary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: TextStyle(fontSize: 14.sp)),
            SizedBox(width: 6.w),
            Text(
              label,
              style: AppTypography.medium12(color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}
