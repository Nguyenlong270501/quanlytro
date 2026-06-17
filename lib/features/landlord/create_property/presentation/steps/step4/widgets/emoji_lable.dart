import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../../core/constants/app_sizes.dart';
import '../../../../../../../core/theme/app_colors.dart';
import '../../../../../../../core/theme/app_style.dart';
import '../../../../data/models/preview_stat.dart';

class EmojiLable extends StatelessWidget {
  const EmojiLable({super.key, required this.stats});

  final List<PreviewStat> stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 10.h),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          for (final stat in stats)
            Expanded(
              child: Column(
                children: [
                  Text(
                    stat.emoji,
                    style: AppTypography.bold16(color: AppColors.primary),
                  ),
                  AppSizes.gapH6,
                  Text(
                    stat.value,
                    style: AppTypography.bold16(color: AppColors.primary),
                  ),
                  AppSizes.gapH4,
                  Text(
                    stat.label,
                    style: AppTypography.medium10(color: AppColors.textMuted),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
