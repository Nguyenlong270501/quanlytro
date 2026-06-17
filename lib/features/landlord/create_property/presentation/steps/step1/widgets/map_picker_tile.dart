import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../../core/constants/app_sizes.dart';
import '../../../../../../../core/theme/app_colors.dart';
import '../../../../../../../core/theme/app_style.dart';

class MapPickerTile extends StatelessWidget {
  const MapPickerTile({
    super.key,
    this.coordinateText,
    this.onTap,
    this.required = false,
    this.hasError = false,
  });

  final String? coordinateText;
  final VoidCallback? onTap;
  final bool required;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final hasCoordinate = coordinateText != null && coordinateText!.isNotEmpty;
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.successSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasError
              ? AppColors.danger
              : AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowSoft,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.location_on,
              size: 18.sp,
              color: AppColors.primary,
            ),
          ),
          AppSizes.gapW12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                RichText(
                  text: TextSpan(
                    style: AppTypography.bold12(
                      color: hasError ? AppColors.danger : AppColors.primary,
                    ),
                    children: [
                      const TextSpan(text: 'Tọa độ GPS'),
                      if (required)
                        TextSpan(
                          text: ' *',
                          style: AppTypography.bold12(color: AppColors.danger),
                        ),
                    ],
                  ),
                ),
                AppSizes.gapH4,
                Text(
                  hasCoordinate ? coordinateText! : 'Chưa thả ghim vị trí',
                  style: AppTypography.medium10(
                    color: hasError
                        ? AppColors.danger.withValues(alpha: 0.9)
                        : AppColors.primary.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          AppSizes.gapW8,
          _PinButton(onTap: onTap, hasCoordinate: hasCoordinate),
        ],
      ),
    );
  }
}

class _PinButton extends StatelessWidget {
  const _PinButton({required this.onTap, required this.hasCoordinate});

  final VoidCallback? onTap;
  final bool hasCoordinate;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
          ),
          child: Text(
            hasCoordinate ? 'Đổi vị trí' : 'Ghim vị trí',
            style: AppTypography.bold12(color: AppColors.primary),
          ),
        ),
      ),
    );
  }
}
