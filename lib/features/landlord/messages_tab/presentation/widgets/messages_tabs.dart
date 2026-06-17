import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_style.dart';

class MessagesTabs extends StatelessWidget {
  const MessagesTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: SizedBox(
        height: 40.h,
        child: TabBar(
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(10.r),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadowSoft,
                blurRadius: 4,
                offset: Offset(0, 1),
              ),
            ],
          ),
          labelStyle: AppTypography.bold12(
            color: AppColors.surface,
          ).copyWith(height: 1.2),
          unselectedLabelStyle: AppTypography.medium12(
            color: AppColors.textMuted,
          ).copyWith(height: 1.2),
          labelColor: AppColors.surface,
          unselectedLabelColor: AppColors.textMuted,
          dividerColor: Colors.transparent,
          labelPadding: EdgeInsets.zero,
          tabs: const [
            Tab(text: 'Tin nhắn'),
            Tab(text: 'Thông báo'),
            Tab(text: 'Lịch hẹn'),
          ],
        ),
      ),
    );
  }
}
