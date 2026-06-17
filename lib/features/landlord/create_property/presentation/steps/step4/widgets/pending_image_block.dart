import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../../core/constants/app_sizes.dart';
import '../../../../../../../core/theme/app_colors.dart';
import '../../../../../../../core/theme/app_style.dart';
import 'image_carousel.dart';

/// Nhãn chờ duyệt + carousel ảnh (carousel nằm dưới khung nhãn).
class PendingImageBlock extends StatelessWidget {
  const PendingImageBlock({
    super.key,
    required this.caption,
    required this.imageUrls,
    this.subtitle,
    this.carouselHeight,
  });

  final String caption;
  final List<String> imageUrls;
  final String? subtitle;
  final double? carouselHeight;

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) return const SizedBox.shrink();

    final height = carouselHeight ?? 200.h;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: AppColors.pendingEditSoft,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: AppColors.pendingEditBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                caption,
                style: AppTypography.bold12(color: AppColors.pendingEditText),
              ),
              if (subtitle != null && subtitle!.isNotEmpty) ...[
                AppSizes.gapH4,
                Text(
                  subtitle!,
                  style: AppTypography.medium14(color: AppColors.textPrimary),
                ),
              ],
            ],
          ),
        ),
        AppSizes.gapH8,
        ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(width: 3, color: AppColors.pendingEditText),
            ),
            height: height,
            width: double.infinity,
            child: ImageCarousel(images: imageUrls),
          ),
        ),
      ],
    );
  }
}
