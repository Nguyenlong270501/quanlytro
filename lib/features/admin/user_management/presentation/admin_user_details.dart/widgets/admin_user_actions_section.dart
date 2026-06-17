import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/constants/app_sizes.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_style.dart';

class AdminUserActionsSection extends StatelessWidget {
  const AdminUserActionsSection({
    super.key,
    required this.isBusy,
    required this.hasChanges,
    required this.isSaving,
    required this.isResettingPassword,
    required this.onSave,
    required this.onResetPassword,
  });

  final bool isBusy;
  final bool hasChanges;
  final bool isSaving;
  final bool isResettingPassword;
  final VoidCallback onSave;
  final VoidCallback onResetPassword;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ActionButton(
          icon: Icons.save_outlined,
          text: 'Lưu thay đổi',
          isLoading: isSaving,
          isEnabled: hasChanges && !isBusy,
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.surface,
          onPressed: onSave,
        ),
        AppSizes.gapH10,
        _ActionButton(
          icon: Icons.lock_reset,
          text: 'Reset password',
          isLoading: isResettingPassword,
          isEnabled: !isBusy,
          backgroundColor: AppColors.errorSoft,
          foregroundColor: AppColors.danger,
          borderColor: AppColors.danger.withValues(alpha: 0.35),
          onPressed: onResetPassword,
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.text,
    required this.isLoading,
    required this.isEnabled,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onPressed,
    this.borderColor,
  });

  final IconData icon;
  final String text;
  final bool isLoading;
  final bool isEnabled;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color? borderColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final effectiveBackground = isEnabled
        ? backgroundColor
        : AppColors.surfaceMuted;
    final effectiveForeground = isEnabled
        ? foregroundColor
        : AppColors.textDisabled;
    final border = borderColor;
    return SizedBox(
      width: double.infinity,
      height: 40.h,
      child: Material(
        color: effectiveBackground,
        borderRadius: BorderRadius.circular(14.r),
        child: InkWell(
          onTap: isEnabled ? onPressed : null,
          borderRadius: BorderRadius.circular(14.r),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14.r),
              border: border == null ? null : Border.all(color: border),
            ),
            child: isLoading
                ? SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: effectiveForeground,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, color: effectiveForeground, size: 20.sp),
                      AppSizes.gapW8,
                      Text(
                        text,
                        style: AppTypography.bold14(color: effectiveForeground),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
