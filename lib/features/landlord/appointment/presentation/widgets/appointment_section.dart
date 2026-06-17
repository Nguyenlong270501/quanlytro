import 'package:flutter/material.dart';

import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_style.dart';

class AppointmentSection extends StatelessWidget {
  const AppointmentSection({
    super.key,
    required this.label,
    required this.child,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: AppTypography.bold14(
              color: AppColors.textPrimary,
            ).copyWith(letterSpacing: 0.8),
          ),
          AppSizes.gapH10,
          child,
        ],
      ),
    );
  }
}

class AppointmentDivider extends StatelessWidget {
  const AppointmentDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(18, 14, 18, 0),
      child: Divider(height: 0.5, thickness: 0.5, color: AppColors.border),
    );
  }
}
