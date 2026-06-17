import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_style.dart';

class PropertyDetailRejectedReasonBanner extends StatelessWidget {
  const PropertyDetailRejectedReasonBanner({
    super.key,
    required this.reason,
  });

  final String reason;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        color: AppColors.warningSoft,
      ),
      padding: EdgeInsets.all(12.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.history,
            color: AppColors.warningStrongText,
            size: 20.sp,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Bài này từng bị từ chối với lý do: ',
                    style: AppTypography.bold12(
                      color: AppColors.warningStrongText,
                    ),
                  ),
                  TextSpan(
                    text: reason,
                    style: AppTypography.medium12(
                      color: AppColors.warningStrongText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
