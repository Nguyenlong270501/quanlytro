import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_style.dart';

enum AdminPostStatus { displaying, pending, rejected }

class AdminPostData {
  const AdminPostData({
    required this.title,
    required this.address,
    required this.priceLabel,
    required this.ownerName,
    required this.ownerInitials,
    required this.status,
  });

  final String title;
  final String address;
  final String priceLabel;
  final String ownerName;
  final String ownerInitials;
  final AdminPostStatus status;
}

class AdminPostCard extends StatelessWidget {
  const AdminPostCard({super.key, required this.data});

  final AdminPostData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeaderRow(data: data),
          AppSizes.gapH12,
          Divider(height: 1, color: AppColors.divider),
          AppSizes.gapH12,
          _FooterRow(data: data),
        ],
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({required this.data});

  final AdminPostData data;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44.w,
          height: 44.w,
          decoration: BoxDecoration(
            color: AppColors.successSoft,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.home_rounded,
            color: AppColors.primary,
            size: 24.sp,
          ),
        ),
        AppSizes.gapW12,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bold14(color: AppColors.textPrimary),
              ),
              AppSizes.gapH4,
              Text(
                data.address,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.medium12(color: AppColors.textMuted),
              ),
              AppSizes.gapH8,
              Text(
                data.priceLabel,
                style: AppTypography.bold14(color: AppColors.primary),
              ),
            ],
          ),
        ),
        AppSizes.gapW8,
        _StatusBadge(status: data.status),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final AdminPostStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (status) {
      AdminPostStatus.displaying => (
          'Hiển thị',
          AppColors.successSoft,
          AppColors.primary,
        ),
      AdminPostStatus.pending => (
          'Chờ duyệt',
          AppColors.warningSoft,
          AppColors.warning,
        ),
      AdminPostStatus.rejected => (
          'Từ chối',
          AppColors.errorSoft,
          AppColors.error,
        ),
    };
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: AppTypography.bold10(color: fg)),
    );
  }
}

class _FooterRow extends StatelessWidget {
  const _FooterRow({required this.data});

  final AdminPostData data;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _OwnerChip(initials: data.ownerInitials, name: data.ownerName),
        AppSizes.gapW8,
        Expanded(child: _ActionButtons(status: data.status)),
      ],
    );
  }
}

class _OwnerChip extends StatelessWidget {
  const _OwnerChip({required this.initials, required this.name});

  final String initials;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28.w,
          height: 28.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.successSoft,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            initials,
            style: AppTypography.bold10(color: AppColors.primary),
          ),
        ),
        AppSizes.gapW8,
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 80.w),
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.medium12(color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.status});

  final AdminPostStatus status;

  @override
  Widget build(BuildContext context) {
    final buttons = switch (status) {
      AdminPostStatus.displaying => const [
          _ActionData('Xem', _ActionStyle.outline),
          _ActionData('Sửa', _ActionStyle.outline),
          _ActionData('Ẩn', _ActionStyle.outline),
        ],
      AdminPostStatus.pending => const [
          _ActionData('Duyệt', _ActionStyle.filled),
          _ActionData('Từ chối', _ActionStyle.outline),
        ],
      AdminPostStatus.rejected => const [
          _ActionData('Xem', _ActionStyle.outline),
          _ActionData('Lý do', _ActionStyle.outline),
          _ActionData('Khôi phục', _ActionStyle.outline),
        ],
    };

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        for (int i = 0; i < buttons.length; i++) ...[
          if (i > 0) AppSizes.gapW6,
          Flexible(child: _ActionButton(data: buttons[i])),
        ],
      ],
    );
  }
}

enum _ActionStyle { filled, outline }

class _ActionData {
  const _ActionData(this.label, this.style);
  final String label;
  final _ActionStyle style;
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.data});

  final _ActionData data;

  @override
  Widget build(BuildContext context) {
    final isFilled = data.style == _ActionStyle.filled;
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isFilled ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isFilled ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          data.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.bold12(
            color: isFilled ? AppColors.surface : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
