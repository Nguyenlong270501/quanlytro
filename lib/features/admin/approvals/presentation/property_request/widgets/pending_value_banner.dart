import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/constants/app_sizes.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_style.dart';
import '../../../../../landlord/create_property/presentation/steps/step4/widgets/pending_image_block.dart';
import 'pending_update_display_formatter.dart';

/// Gợi ý đầu màn khi có chỉnh sửa chờ duyệt.
class PendingUpdateHintBanner extends StatelessWidget {
  const PendingUpdateHintBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.pendingEditSoft,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.pendingEditBorder),
      ),
      child: Text(
        'Ô xanh dương là nội dung cần kiểm duyệt',
        style: AppTypography.medium12(color: AppColors.pendingEditText),
      ),
    );
  }
}

/// Giá trị chờ duyệt — đặt ngay dưới field live tương ứng.
class PendingValueBanner extends StatelessWidget {
  const PendingValueBanner({
    super.key,
    required this.line,
    this.caption,
  });

  final PendingChangeLine line;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final label = caption ?? line.label;

    if (line.hasImages) {
      return Padding(
        padding: EdgeInsets.only(top: 6.h),
        child: PendingImageBlock(
          caption: label,
          imageUrls: line.imageUrls,
          subtitle: line.newValue.isNotEmpty ? line.newValue : null,
        ),
      );
    }

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 6.h),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: AppColors.pendingEditSoft,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.pendingEditBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.bold12(color: AppColors.pendingEditText),
          ),
          if (line.newValue.isNotEmpty) ...[
            AppSizes.gapH4,
            Text(
              line.newValue,
              style: AppTypography.medium14(color: AppColors.textPrimary),
            ),
          ],
        ],
      ),
    );
  }
}

/// Live content + optional pending banner below.
class PendingFieldBlock extends StatelessWidget {
  const PendingFieldBlock({
    super.key,
    required this.child,
    this.pending,
    this.pendingCaption,
  });

  final Widget child;
  final PendingChangeLine? pending;
  final String? pendingCaption;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        child,
        if (pending != null)
          PendingValueBanner(line: pending!, caption: pendingCaption),
      ],
    );
  }
}
