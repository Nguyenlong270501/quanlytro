import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/constants/app_sizes.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_style.dart';
import '../../../../../../core/utils/property_helper.dart';
import '../../../../create_property/data/models/property_model.dart';
import '../../../../create_property/presentation/shared_widgets/section_card.dart';
import '../../../data/models/property_review_model.dart';

class PropertyReviewsSection extends StatelessWidget {
  const PropertyReviewsSection({
    super.key,
    required this.property,
    required this.reviews,
    this.isLoadingMore = false,
    this.onNearEnd,
  });

  static const double listHeight = 280;

  final PropertyModel property;
  final List<PropertyReviewModel> reviews;
  final bool isLoadingMore;
  final VoidCallback? onNearEnd;

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return const SizedBox.shrink();
    }

    return SectionCard(
      title: 'Đánh giá từ khách thuê (${reviews.length})',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.star_rounded, color: AppColors.starColor, size: 24.sp),
              AppSizes.gapW6,
              Text(
                property.ratingAverage.toStringAsFixed(1),
                style: AppTypography.bold18(color: AppColors.textPrimary),
              ),
              AppSizes.gapW10,
              Text(
                '•  ${reviews.length} bình luận',
                style: AppTypography.medium14(color: AppColors.textMuted),
              ),
            ],
          ),
          AppSizes.gapH16,
          SizedBox(
            height: PropertyReviewsSection.listHeight.h,
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (onNearEnd == null) {
                  return false;
                }
                if (notification is! ScrollUpdateNotification &&
                    notification is! ScrollEndNotification) {
                  return false;
                }
                final metrics = notification.metrics;
                if (metrics.pixels >= metrics.maxScrollExtent - 80) {
                  onNearEnd!();
                }
                return false;
              },
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: reviews.length + (isLoadingMore ? 1 : 0),
                separatorBuilder: (context, index) {
                  if (index >= reviews.length - 1) {
                    return const SizedBox.shrink();
                  }
                  return const Divider(
                    height: 24,
                    color: AppColors.dividerColor,
                  );
                },
                itemBuilder: (context, index) {
                  if (index >= reviews.length) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      child: const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    );
                  }
                  return _ReviewItemTile(review: reviews[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewItemTile extends StatelessWidget {
  const _ReviewItemTile({required this.review});

  final PropertyReviewModel review;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = review.avatarUrl?.trim() ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            avatarUrl.isNotEmpty
                ? CircleAvatar(
                    radius: 18.r,
                    backgroundColor: const Color.fromARGB(255, 17, 18, 19),
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: avatarUrl,
                        width: 36.r,
                        height: 36.r,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) =>
                            Image.asset('assets/images/profile.png'),
                      ),
                    ),
                  )
                : CircleAvatar(
                    radius: 18.r,
                    backgroundColor: AppColors.infoLight,
                    child: ClipOval(
                      child: Image.asset('assets/images/profile.png'),
                    ),
                  ),
            AppSizes.gapW10,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    review.userName,
                    style: AppTypography.bold14(color: AppColors.textPrimary),
                  ),
                  Text(
                    'Đăng ${PropertyHelper.formatTimeAgo(review.updatedAt)}',
                    style: AppTypography.medium12(color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            Row(
              children: List.generate(5, (index) {
                return Icon(
                  index < review.rating
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  color: AppColors.starColor,
                  size: 16.sp,
                );
              }),
            ),
          ],
        ),
        AppSizes.gapH10,
        // Nội dung bình luận
        Text(
          review.content,
          style: AppTypography.medium14(
            color: AppColors.textPrimary,
          ).copyWith(height: 1.35),
        ),
      ],
    );
  }
}
