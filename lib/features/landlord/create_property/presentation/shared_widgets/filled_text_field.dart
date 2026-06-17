import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_style.dart';

class FilledTextField extends StatelessWidget {
  const FilledTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.hintText,
    this.keyboardType,
    this.inputFormatters,
    this.maxLines = 1,
    this.minLines,
    this.onChanged,
    this.suffix,
    this.readOnly = false,
    this.onTap,
    this.hasError = false,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hintText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final int? minLines;
  final ValueChanged<String>? onChanged;
  final Widget? suffix;
  final bool readOnly;
  final VoidCallback? onTap;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final idleColor = hasError ? AppColors.danger : AppColors.border;
    final focusColor = hasError ? AppColors.danger : AppColors.primary;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: idleColor),
    );
    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      minLines: minLines,
      onChanged: onChanged,
      readOnly: readOnly,
      onTap: onTap,
      style: AppTypography.medium14(color: AppColors.textPrimary),
      cursorColor: AppColors.primary,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTypography.medium14(color: AppColors.textDisabled),
        isDense: true,
        filled: true,
        fillColor: AppColors.scaffoldBackground,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        suffixIcon: suffix,
        suffixIconConstraints: BoxConstraints(minHeight: 0, minWidth: 0),
        enabledBorder: border,
        border: border,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: focusColor, width: 1.4),
        ),
      ),
    );
  }
}
