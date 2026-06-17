import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_style.dart';

class AdminStatData {
  const AdminStatData({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.value,
    required this.label,
    required this.subLabel,
    required this.subColor,
    this.subBg,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String value;
  final String label;
  final String subLabel;
  final Color subColor;
  final Color? subBg;
}

class AdminStatsGrid extends StatelessWidget {
  const AdminStatsGrid({super.key, required this.stats});

  final List<AdminStatData> stats;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12.w,
      mainAxisSpacing: 12.h,
      childAspectRatio: 1.15,
      children: stats.map((stat) => _AdminStatCard(data: stat)).toList(),
    );
  }
}

class _AdminStatCard extends StatelessWidget {
  const _AdminStatCard({required this.data});

  final AdminStatData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: data.iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(data.icon, color: data.iconColor, size: 20.sp),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.value,
                style: AppTypography.bold26(
                  color: AppColors.textPrimary,
                ),
              ),
              AppSizes.gapH4,
              Text(
                data.label,
                style: AppTypography.medium12(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          _SubBadge(
            text: data.subLabel,
            color: data.subColor,
            background: data.subBg,
          ),
        ],
      ),
    );
  }
}

class _SubBadge extends StatelessWidget {
  const _SubBadge({
    required this.text,
    required this.color,
    this.background,
  });

  final String text;
  final Color color;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    if (background != null) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          text,
          style: AppTypography.bold10(color: color),
        ),
      );
    }
    return Text(
      text,
      style: AppTypography.medium12(color: color),
    );
  }
}
