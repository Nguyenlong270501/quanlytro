import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_style.dart';

class MessagesTopBar extends StatelessWidget {
  const MessagesTopBar({super.key});

  static const List<String> _titles = <String>[
    'Tin nhắn',
    'Thông báo',
    'Lịch hẹn',
  ];

  @override
  Widget build(BuildContext context) {
    final tabController = DefaultTabController.of(context);

    return AnimatedBuilder(
      animation: tabController.animation!,
      builder: (context, _) {
        final index = tabController.index.clamp(0, _titles.length - 1);
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 4.h),
          child: Container(
            height: 50.h,
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.textMuted.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            alignment: Alignment.centerLeft,
            child: Text(
              _titles[index],
              style: AppTypography.bold20(color: AppColors.textPrimary),
            ),
          ),
        );
      },
    );
  }
}

