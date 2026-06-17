import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../../core/theme/app_colors.dart';
import '../../../../../../../core/theme/app_style.dart';

class FilledDropdownField extends StatelessWidget {
  const FilledDropdownField({
    super.key,
    required this.options,
    this.value,
    this.hintText,
    this.onChanged,
    this.hasError = false,
  });

  final List<String> options;
  final String? value;
  final String? hintText;
  final ValueChanged<String?>? onChanged;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final idleColor = hasError ? AppColors.danger : AppColors.border;
    final focusColor = hasError ? AppColors.danger : AppColors.primary;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: idleColor),
    );
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      icon: Icon(
        Icons.keyboard_arrow_down,
        size: 20.sp,
        color: AppColors.textMuted,
      ),
      style: AppTypography.medium14(color: AppColors.textPrimary),
      hint: hintText == null
          ? null
          : Text(
              hintText!,
              style: AppTypography.medium14(color: AppColors.textDisabled),
            ),
      items: options
          .map(
            (option) => DropdownMenuItem<String>(
              value: option,
              child: Text(
                option,
                style: AppTypography.medium14(color: AppColors.textPrimary),
              ),
            ),
          )
          .toList(),
      onChanged: onChanged ?? (_) {},
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: AppColors.scaffoldBackground,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        enabledBorder: border,
        border: border,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: focusColor, width: 1.4),
        ),
      ),
      dropdownColor: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
    );
  }
}
