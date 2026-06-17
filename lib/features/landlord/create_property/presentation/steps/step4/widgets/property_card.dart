import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../../core/constants/app_sizes.dart';
import '../../../../../../../core/theme/app_colors.dart';
import '../../../../../../../core/theme/app_style.dart';
import '../../../../../../../core/utils/property_helper.dart';
import '../../../../../../../core/utils/property_image_precache.dart';
import '../../../../data/models/preview_stat.dart';
import '../../../../data/models/property_model.dart';
import 'emoji_lable.dart';
import 'image_carousel.dart';
import 'info_row.dart';

class PropertyCard extends StatelessWidget {
  const PropertyCard({
    super.key,
    required this.imageUrl,
    required this.pricePrefix,
    required this.priceValue,
    required this.name,
    required this.propertyTypes,
    required this.address,
    required this.summary,
    required this.stats,
    this.bottomWidget,
    this.status,
    this.showPendingEditBadge = false,
    this.onTap,
    required this.createdAt,
  });

  final List<String> imageUrl;
  final String pricePrefix;
  final String priceValue;
  final String name;
  final List<String> propertyTypes;
  final String address;
  final String summary;
  final List<PreviewStat> stats;
  final PropertyStatus? status;
  final bool showPendingEditBadge;
  final Widget? bottomWidget;
  final DateTime createdAt;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: onTap == null
              ? null
              : () async {
                  try {
                    precachePropertyCardHeroImage(context, imageUrl);
                  } catch (_) {}

                  if (context.mounted) {
                    onTap!();
                  }
                },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (imageUrl.isNotEmpty) _buildImage(),
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 5.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: AppTypography.bold16(
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (showPendingEditBadge) const _PendingEditBadge(),
                      ],
                    ),
                    AppSizes.gapH8,
                    InfoRowList(
                      label: 'Loại phòng:',
                      value: propertyTypes,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    AppSizes.gapH4,
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14.sp,
                          color: AppColors.textMuted,
                        ),
                        AppSizes.gapW4,
                        Expanded(
                          child: Text(
                            address,
                            style: AppTypography.medium12(
                              color: AppColors.textMuted,
                            ).copyWith(height: 1.3),
                          ),
                        ),
                      ],
                    ),
                    AppSizes.gapH4,
                    InfoRow(label: 'Mô tả:', value: summary, maxLines: 2),
                    AppSizes.gapH6,
                    InfoRow(
                      label: pricePrefix,
                      value: priceValue,
                      highlight: true,
                    ),
                    AppSizes.gapH6,
                    EmojiLable(stats: stats),
                    AppSizes.gapH6,
                    if (bottomWidget != null) ...[
                      AppSizes.gapH4,
                      const Divider(height: 1, color: AppColors.divider),
                      bottomWidget!,
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    return SizedBox(
      height: 200.h,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ImageCarousel(images: imageUrl, enableFullscreenOnTap: false),
          if (status != null)
            Positioned(
              top: 12.h,
              left: 12.w,
              child: _StatusBadge(status: status!),
            ),

          if (PropertyHelper.isNewListing(createdAt))
            Positioned(top: 10.h, right: 10.w, child: const _NewBadge()),
        ],
      ),
    );
  }
}

class _PendingEditBadge extends StatelessWidget {
  const _PendingEditBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.pendingEditSoft,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.pendingEditBorder),
      ),
      child: Text(
        'Chờ duyệt sửa',
        style: AppTypography.bold10(color: AppColors.pendingEditText),
      ),
    );
  }
}

class _NewBadge extends StatelessWidget {
  const _NewBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.orangeSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: 12.sp, color: AppColors.orange),
          SizedBox(width: 4.w),
          Text('MỚI', style: AppTypography.bold10(color: AppColors.orange)),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final PropertyStatus status;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color text;
    String label;

    switch (status) {
      case PropertyStatus.approved:
        bg = AppColors.successSoft;
        text = AppColors.primary;
        label = 'ĐÃ DUYỆT';
        break;
      case PropertyStatus.pending:
        bg = AppColors.warningSoft;
        text = AppColors.warningStrongText;
        label = 'CHỜ DUYỆT';
        break;
      case PropertyStatus.rejected:
        bg = AppColors.errorSoft;
        text = AppColors.danger;
        label = 'TỪ CHỐI';
        break;
      case PropertyStatus.hidden:
        bg = AppColors.mutedSoft;
        text = AppColors.surface;
        label = 'ẨN';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Text(label, style: AppTypography.bold10(color: text)),
    );
  }
}
