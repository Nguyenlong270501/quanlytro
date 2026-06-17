import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_style.dart';

class PrimaryBottomBar extends StatelessWidget {
  const PrimaryBottomBar({
    super.key,
    required this.label,
    required this.onTap,
    this.secondaryLabel,
    this.onSecondaryTap,
  });

  final String label;
  final VoidCallback onTap;
  final String? secondaryLabel;
  final VoidCallback? onSecondaryTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 12.h),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: secondaryLabel != null && onSecondaryTap != null
            ? Row(
                children: [
                  Expanded(
                    child: _SecondaryPillButton(
                      label: secondaryLabel!,
                      onTap: onSecondaryTap!,
                    ),
                  ),
                  SizedBox(width: 40.w),
                  Expanded(
                    flex: 1,
                    child: _PillButton(label: label, onTap: onTap),
                  ),
                ],
              )
            : _PillButton(label: label, onTap: onTap),
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(100);
    return Material(
      color: AppColors.primary,
      borderRadius: radius,
      elevation: 4,
      shadowColor: AppColors.primary.withValues(alpha: 0.35),
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          height: 44.h,
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.bold14(color: AppColors.surface),
          ),
        ),
      ),
    );
  }
}

class _SecondaryPillButton extends StatelessWidget {
  const _SecondaryPillButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(100);
    return Material(
      color: AppColors.surface,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          height: 44.h,
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: AppColors.primary, width: 1.5),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.bold14(color: AppColors.primary),
          ),
        ),
      ),
    );
  }
}
