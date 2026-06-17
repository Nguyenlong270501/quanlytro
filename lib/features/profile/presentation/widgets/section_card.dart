import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_style.dart';

class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.title,
    required this.child,
    this.emoji,
    this.subtitle,
    this.required = false,
    this.trailing,
  });

  final String title;
  final Widget child;
  final String? emoji;
  final String? subtitle;

  final bool required;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (emoji != null) ...[
                Container(
                  width: 28.w,
                  height: 28.w,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(emoji!, style: TextStyle(fontSize: 14.sp)),
                ),
                AppSizes.gapW8,
              ],
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: AppTypography.bold16(color: AppColors.textPrimary),
                    children: [
                      TextSpan(text: title),
                      if (required)
                        TextSpan(
                          text: ' (*)',
                          style: AppTypography.bold16(color: AppColors.danger),
                        ),
                    ],
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          if (subtitle != null) ...[
            AppSizes.gapH6,
            Text(
              subtitle!,
              style: AppTypography.medium12(
                color: AppColors.textMuted,
              ).copyWith(height: 1.4),
            ),
          ],
          AppSizes.gapH16,
          child,
        ],
      ),
    );
  }
}
