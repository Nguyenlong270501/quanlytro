import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/constants/app_enums.dart';
import '../../../../../../core/constants/app_sizes.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_style.dart';

class RoleStatusSection extends StatelessWidget {
  const RoleStatusSection({
    super.key,
    required this.selectedStatus,
    required this.onStatusChanged,
  });

  final UserStatus selectedStatus;
  final ValueChanged<UserStatus> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    return _StatusDropdown(value: selectedStatus, onChanged: onStatusChanged);
  }
}

class _StatusDropdown extends StatelessWidget {
  const _StatusDropdown({required this.value, required this.onChanged});

  final UserStatus value;
  final ValueChanged<UserStatus> onChanged;

  @override
  Widget build(BuildContext context) {
    final color = value == UserStatus.active
        ? AppColors.primary
        : AppColors.danger;
    return DropdownShell(
      icon: value == UserStatus.active
          ? Icons.check_circle_outline
          : Icons.block_outlined,
      iconColor: color,
      label: 'Trạng thái',
      child: DropdownButtonHideUnderline(
        child: DropdownButton<UserStatus>(
          isDense: true,
          value: value,
          isExpanded: true,
          dropdownColor: AppColors.surface,
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.textMuted,
            size: 22.sp,
          ),
          style: AppTypography.bold14(color: AppColors.textPrimary),
          items: UserStatus.values
              .map(
                (status) => DropdownMenuItem<UserStatus>(
                  value: status,
                  child: Text(status.firestoreValue),
                ),
              )
              .toList(),
          onChanged: (status) {
            if (status == null) {
              return;
            }
            onChanged(status);
          },
        ),
      ),
    );
  }
}

class DropdownShell extends StatelessWidget {
  const DropdownShell({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.child,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.6),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: iconColor, size: 22.sp),
          ),
          AppSizes.gapW14,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: AppTypography.medium12(
                    color: AppColors.textMuted,
                  ).copyWith(letterSpacing: 0.3),
                ),
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
