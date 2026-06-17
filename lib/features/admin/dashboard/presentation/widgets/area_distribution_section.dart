import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_style.dart';

class AreaStatData {
  const AreaStatData({required this.name, required this.percent});

  final String name;
  final double percent;
}

class AreaDistributionSection extends StatelessWidget {
  const AreaDistributionSection({super.key, required this.areas});

  final List<AreaStatData> areas;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phân bố theo khu vực',
          style: AppTypography.bold16(color: AppColors.textPrimary),
        ),
        AppSizes.gapH12,
        for (int i = 0; i < areas.length; i++) ...[
          if (i > 0) AppSizes.gapH12,
          _AreaRow(data: areas[i]),
        ],
      ],
    );
  }
}

class _AreaRow extends StatelessWidget {
  const _AreaRow({required this.data});

  final AreaStatData data;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 80.w,
          child: Text(
            data.name,
            style: AppTypography.medium14(color: AppColors.textSecondary),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: (data.percent / 100).clamp(0.0, 1.0),
              minHeight: 10.h,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
        ),
        AppSizes.gapW12,
        SizedBox(
          width: 40.w,
          child: Text(
            '${data.percent.toStringAsFixed(0)}%',
            textAlign: TextAlign.right,
            style: AppTypography.bold12(color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}
