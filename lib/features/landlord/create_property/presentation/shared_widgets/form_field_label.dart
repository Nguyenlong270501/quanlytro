import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_style.dart';

class FormFieldLabel extends StatelessWidget {
  const FormFieldLabel({
    super.key,
    required this.label,
    this.required = false,
  });

  final String label;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: AppTypography.medium14(color: AppColors.textSecondary),
        children: [
          TextSpan(text: label),
          if (required)
            TextSpan(
              text: ' *',
              style: AppTypography.medium14(color: AppColors.danger),
            ),
        ],
      ),
    );
  }
}
