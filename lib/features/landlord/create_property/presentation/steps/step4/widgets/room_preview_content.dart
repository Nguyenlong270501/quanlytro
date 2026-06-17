import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../../core/constants/app_sizes.dart';
import '../../../../../../../core/theme/app_colors.dart';
import '../../../../../../../core/theme/app_style.dart';
import '../../../../../../../core/utils/review_helper.dart';
import '../../../../data/models/preview_stat.dart';
import '../../../../data/models/room_model.dart';
import '../models/room_preview_screen_args.dart';
import 'emoji_lable.dart';
import 'image_carousel.dart';
import 'pending_image_block.dart';
import 'summary_chip.dart';

class RoomPreviewHeader extends StatelessWidget {
  const RoomPreviewHeader({super.key, required this.room, this.onEdit});

  final RoomModel room;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 8.w, 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  room.roomName,
                  style: AppTypography.bold18(color: AppColors.textPrimary),
                ),
                AppSizes.gapH4,
                Row(
                  children: [
                    Text('Giá phòng', style: AppTypography.bold14()),
                    SizedBox(width: 6.w),
                    Text(
                      '${ReviewHelper.formatPrice(room.price)} đ/tháng',
                      style: AppTypography.bold14(color: AppColors.primary),
                    ),
                  ],
                ),
                AppSizes.gapH4,
                Row(
                  children: [
                    Text('Tiền cọc', style: AppTypography.bold14()),
                    SizedBox(width: 6.w),
                    Text(
                      '${ReviewHelper.formatPrice(room.priceDeposit)} đ',
                      style: AppTypography.bold14(color: AppColors.primary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (onEdit != null) ...[
            SizedBox(width: 8.w),
            Material(
              color: AppColors.scaffoldBackground,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: onEdit,
                customBorder: const CircleBorder(),
                child: Padding(
                  padding: EdgeInsets.all(8.w),
                  child: Icon(
                    Icons.edit_rounded,
                    size: 18.sp,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class RoomPreviewContent extends StatelessWidget {
  const RoomPreviewContent({
    super.key,
    required this.room,
    this.isReadOnly = true,
    this.onAvailabilityChanged,
    this.pendingImages,
    this.footerSections = const [],
  });

  final RoomModel room;
  final bool isReadOnly;
  final ValueChanged<bool>? onAvailabilityChanged;
  final RoomPreviewPendingImages? pendingImages;
  final List<Widget> footerSections;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 200.h,
          width: double.infinity,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: ImageCarousel(images: room.imageUrls),
          ),
        ),
        if (pendingImages != null && pendingImages!.imageUrls.isNotEmpty) ...[
          AppSizes.gapH12,
          PendingImageBlock(
            caption: '${pendingImages!.caption} chờ duyệt',
            imageUrls: pendingImages!.imageUrls,
            subtitle: pendingImages!.subtitle,
          ),
        ],
        AppSizes.gapH16,
        _RoomAvailabilityCard(
          isAvailable: room.isAvailable,
          isReadOnly: isReadOnly,
          onChanged: onAvailabilityChanged,
        ),
        AppSizes.gapH16,
        EmojiLable(
          stats: [
            PreviewStat(
              emoji: '📐',
              value: ReviewHelper.formatAreaLabel(room.area.toString()),
              label: 'Diện tích',
            ),
            PreviewStat(
              emoji: '👥',
              value: room.maxTenants.toString(),
              label: 'Số người',
            ),
            PreviewStat(emoji: '🏢', value: room.roomLocation, label: 'Vị trí'),
          ],
        ),
        AppSizes.gapH20,
        const RoomPreviewSectionLabel(emoji: '✨', text: 'Tiện ích nội thất'),
        AppSizes.gapH12,
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: [
            for (final a in room.amenities)
              SummaryChip(emoji: a.emoji, label: a.label),
          ],
        ),
        if (footerSections.isNotEmpty) ...[
          AppSizes.gapH20,
          const RoomPreviewSectionLabel(emoji: '📝', text: 'Chờ duyệt'),
          AppSizes.gapH8,
          ...footerSections,
        ],
      ],
    );
  }
}

class RoomPreviewSectionLabel extends StatelessWidget {
  const RoomPreviewSectionLabel({
    super.key,
    required this.emoji,
    required this.text,
  });

  final String emoji;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(emoji, style: TextStyle(fontSize: 14.sp)),
        SizedBox(width: 6.w),
        Text(text, style: AppTypography.bold14(color: AppColors.textPrimary)),
      ],
    );
  }
}

class _RoomAvailabilityCard extends StatelessWidget {
  const _RoomAvailabilityCard({
    required this.isAvailable,
    required this.isReadOnly,
    this.onChanged,
  });

  final bool isAvailable;
  final bool isReadOnly;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final title = isAvailable ? 'Phòng đang trống' : 'Đã cho thuê';
    final subtitle = isAvailable
        ? 'Hiển thị công khai để tìm khách'
        : 'Tạm ẩn khỏi danh sách cho thuê';
    final titleColor = isAvailable ? AppColors.primary : AppColors.error;
    final subtitleColor = isAvailable
        ? AppColors.primary.withValues(alpha: 0.8)
        : AppColors.error.withValues(alpha: 0.8);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isAvailable ? AppColors.successSoft : AppColors.errorSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAvailable
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.error.withValues(alpha: 0.3),
        ),
      ),
      child: isReadOnly
          ? Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.bold14(color: titleColor)),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: AppTypography.medium12(color: subtitleColor),
                  ),
                ],
              ),
            )
          : SwitchListTile(
              value: isAvailable,
              onChanged: onChanged,
              title: Text(
                title,
                style: AppTypography.bold14(color: titleColor),
              ),
              subtitle: Text(
                subtitle,
                style: AppTypography.medium12(color: subtitleColor),
              ),
              activeThumbColor: AppColors.primary,
              activeTrackColor: AppColors.primary.withValues(alpha: 0.3),
              inactiveThumbColor: AppColors.error,
              inactiveTrackColor: AppColors.error.withValues(alpha: 0.3),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 4.h,
              ),
            ),
    );
  }
}
