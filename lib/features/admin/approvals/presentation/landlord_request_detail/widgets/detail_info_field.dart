import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/constants/app_sizes.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_style.dart';

class DetailInfoField extends StatelessWidget {
  const DetailInfoField({
    super.key,
    required this.label,
    required this.icon,
    required this.value,
  });

  final String label;
  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.bold14(color: AppColors.textPrimary),
        ),
        AppSizes.gapH8,
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: AppColors.accentSoft,
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18.sp, color: AppColors.textSecondary),
              AppSizes.gapW10,
              Expanded(
                child: Text(
                  value,
                  style: AppTypography.medium14(color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
