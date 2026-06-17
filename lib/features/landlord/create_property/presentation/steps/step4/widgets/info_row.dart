import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../../core/theme/app_colors.dart';
import '../../../../../../../core/theme/app_style.dart';

class InfoRow extends StatelessWidget {
  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.highlight = false,
    this.maxLines,
  });

  final String label;
  final String value;
  final bool highlight;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: RichText(
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        text: TextSpan(
          style: AppTypography.medium12(
            color: AppColors.textSecondary,
          ).copyWith(height: 1.5),
          children: [
            TextSpan(
              text: '$label ',
              style: highlight
                  ? AppTypography.bold14(color: AppColors.textPrimary)
                  : AppTypography.bold14(color: AppColors.textPrimary),
            ),
            TextSpan(
              text: value,
              style: highlight
                  ? AppTypography.bold14(color: AppColors.primary)
                  : AppTypography.medium14(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoRowList extends StatelessWidget {
  const InfoRowList({
    super.key,
    this.label,
    this.maxLines,
    this.overflow = TextOverflow.clip,
    required this.value,
    this.highlight = false,
  });

  final String? label;
  final List<String> value;
  final bool highlight;
  final int? maxLines;
  final TextOverflow overflow;

  @override
  Widget build(BuildContext context) {
    return RichText(
      maxLines: maxLines,
      overflow: overflow,
      text: TextSpan(
        style: AppTypography.medium14(
          color: AppColors.textSecondary,
        ).copyWith(height: 1.5),
        children: [
          TextSpan(
            text: label == null ? '' : '$label ',
            style: AppTypography.bold14(color: AppColors.textPrimary),
          ),
          TextSpan(
            text: value.isEmpty ? '—' : value.join(', '),
            style: highlight
                ? AppTypography.bold14(color: AppColors.primary)
                : AppTypography.medium14(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
