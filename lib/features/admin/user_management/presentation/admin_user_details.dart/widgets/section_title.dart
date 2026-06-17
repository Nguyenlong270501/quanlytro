import 'package:flutter/material.dart';

import '../../../../../../core/constants/app_sizes.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_style.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title.toUpperCase(),
          style: AppTypography.bold10(color: AppColors.textMuted),
        ),
        AppSizes.gapW10,
        const Expanded(child: Divider(color: AppColors.divider, height: 1)),
      ],
    );
  }
}
