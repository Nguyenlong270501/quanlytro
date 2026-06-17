import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../../core/theme/app_colors.dart';
import '../../../../../../../core/theme/app_style.dart';

class AddRoomButton extends StatelessWidget {
  const AddRoomButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(12);
    return Material(
      color: AppColors.successSoft,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 14.w),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: AppColors.primary, width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, size: 16.sp, color: AppColors.primary),
              SizedBox(width: 6.w),
              Text(
                'Thêm phòng mới',
                style: AppTypography.bold12(color: AppColors.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
