import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/constants/app_sizes.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_style.dart';

class DetailActionBar extends StatelessWidget {
  const DetailActionBar({
    super.key,
    required this.isSubmitting,
    required this.loadingReject,
    required this.loadingApprove,
    required this.onApprove,
    required this.onReject,
  });

  final bool isSubmitting;
  final bool loadingReject;
  final bool loadingApprove;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SizedBox(
        height: 40.h,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _DetailPillButton(
                label: 'Từ chối',
                filled: false,
                loading: loadingReject,
                enabled: !isSubmitting,
                onTap: onReject,
              ),
            ),
            AppSizes.gapW12,
            Expanded(
              child: _DetailPillButton(
                label: 'Đồng ý',
                filled: true,
                loading: loadingApprove,
                enabled: !isSubmitting,
                onTap: onApprove,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailPillButton extends StatelessWidget {
  const _DetailPillButton({
    required this.label,
    required this.filled,
    required this.onTap,
    this.loading = false,
    this.enabled = true,
  });

  final String label;
  final bool filled;
  final bool loading;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bgColor = filled ? AppColors.primary : AppColors.surface;
    final fgColor = filled ? AppColors.surface : AppColors.textSecondary;
    return Material(
      color: enabled ? bgColor : bgColor.withValues(alpha: 0.6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100),
        side: filled ? BorderSide.none : BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(100),
        child: Center(
          child: loading
              ? SizedBox(
                  width: 18.w,
                  height: 18.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: fgColor,
                  ),
                )
              : Text(label, style: AppTypography.bold14(color: fgColor)),
        ),
      ),
    );
  }
}
