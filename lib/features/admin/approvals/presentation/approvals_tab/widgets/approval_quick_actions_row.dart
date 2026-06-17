import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/constants/app_sizes.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_style.dart';

/// Hàng nút [Từ chối] / [Duyệt nhanh] trên thẻ danh sách duyệt (chủ trọ & bài đăng).
class ApprovalQuickActionsRow extends StatelessWidget {
  const ApprovalQuickActionsRow({
    super.key,
    required this.onReject,
    required this.onApprove,
    this.rejectLabel = 'Từ chối',
    this.approveLabel = 'Duyệt nhanh',
  });

  final VoidCallback onReject;
  final VoidCallback onApprove;
  final String rejectLabel;
  final String approveLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ApprovalPillButton(
            label: rejectLabel,
            filled: false,
            onTap: onReject,
          ),
        ),
        AppSizes.gapW10,
        Expanded(
          child: _ApprovalPillButton(
            label: approveLabel,
            filled: true,
            onTap: onApprove,
          ),
        ),
      ],
    );
  }
}

class _ApprovalPillButton extends StatelessWidget {
  const _ApprovalPillButton({
    required this.label,
    required this.filled,
    required this.onTap,
  });

  final String label;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: filled ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.bold12(
            color: filled ? AppColors.surface : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
