import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/constants/app_sizes.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_style.dart';

class PropertyQuotasSection extends StatelessWidget {
  const PropertyQuotasSection({super.key, required this.numberOfRooms});

  final List<int> numberOfRooms;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hạn mức phòng trọ đăng ký',
          style: AppTypography.bold14(color: AppColors.textPrimary),
        ),
        AppSizes.gapH8,
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: AppColors.accentSoft,
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: numberOfRooms.isEmpty
              ? Text(
                  '—',
                  style: AppTypography.medium14(color: AppColors.textPrimary),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: numberOfRooms.asMap().entries.map((entry) {
                    final index = entry.key;
                    final rooms = entry.value;
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index == numberOfRooms.length - 1 ? 0 : 8.h,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.door_front_door_outlined,
                            size: 20.sp,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Khu trọ ${index + 1}: ',
                            style: AppTypography.medium14(
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '$rooms phòng',
                            style: AppTypography.bold14(
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }
}
