import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_style.dart';
import 'filled_text_field.dart';

class TextFieldWithSuffix extends StatelessWidget {
  const TextFieldWithSuffix({
    super.key,
    required this.suffix,
    this.controller,
    this.hintText,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
    this.hasError = false,
  });

  final String suffix;
  final TextEditingController? controller;
  final String? hintText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    return FilledTextField(
      controller: controller,
      hintText: hintText,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      hasError: hasError,
      suffix: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Text(
          suffix,
          style: AppTypography.medium14(color: AppColors.textMuted),
        ),
      ),
    );
  }
}
