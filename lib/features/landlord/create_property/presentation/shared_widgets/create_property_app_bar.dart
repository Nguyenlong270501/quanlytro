import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_style.dart';

class CreatePropertyAppBar extends StatelessWidget {
  const CreatePropertyAppBar({
    super.key,
    required this.title,
    required this.currentStep,
    required this.totalSteps,
    this.onBack,
  });

  final String title;
  final int currentStep;
  final int totalSteps;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final progress = (currentStep / totalSteps).clamp(0.0, 1.0);
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
      child: Column(
        children: [
          Row(
            children: [
              _BackButton(onTap: onBack),
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppTypography.bold16(color: AppColors.textPrimary),
                ),
              ),
              _StepBadge(current: currentStep, total: totalSteps),
            ],
          ),
          AppSizes.gapH12,
          _ProgressBar(progress: progress),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        width: 36.w,
        height: 36.w,
        decoration: const BoxDecoration(
          color: AppColors.surfaceMuted,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.chevron_left,
          size: 22.sp,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _StepBadge extends StatelessWidget {
  const _StepBadge({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.successSoft,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        'Bước $current/$total',
        style: AppTypography.bold12(color: AppColors.primary),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        return Stack(
          children: [
            Container(
              width: maxWidth,
              height: 6.h,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeOutCubic,
              width: maxWidth * progress,
              height: 6.h,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ],
        );
      },
    );
  }
}
