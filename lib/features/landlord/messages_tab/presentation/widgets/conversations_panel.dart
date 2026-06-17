import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_style.dart';

class ConversationsPanel extends StatelessWidget {
  const ConversationsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
      children: const [
        _ConversationItem(
          name: 'Minh Tuấn (Chủ nhà)',
          preview: 'Phòng vẫn còn trống, bạn qua xem lúc 9h nhé',
          time: 'vừa xong',
          unread: true,
        ),
        _ConversationItem(
          name: 'Hương Lan',
          preview: 'Phòng đó có ban công không vậy?',
          time: '14:22',
          unread: true,
        ),
        _ConversationItem(
          name: 'Khánh Duy',
          preview: 'Thứ 6 mình bận, dời sang thứ 7 được không?',
          time: 'Hôm qua',
        ),
      ],
    );
  }
}

class _ConversationItem extends StatelessWidget {
  const _ConversationItem({
    required this.name,
    required this.preview,
    required this.time,
    this.unread = false,
  });

  final String name;
  final String preview;
  final String time;
  final bool unread;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 21.r,
            backgroundColor: AppColors.accent,
            child: Icon(Icons.person, size: 18.sp, color: AppColors.surface),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bold14(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      time,
                      style: AppTypography.medium12(color: AppColors.textMuted),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  preview,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.medium12(
                    color: unread
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
