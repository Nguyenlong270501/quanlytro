import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/theme/app_colors.dart';

class ButtonClose extends StatelessWidget {
  const ButtonClose({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        width: 36.w,
        height: 36.w,
        decoration: const BoxDecoration(
          color: AppColors.surfaceMuted,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(Icons.close, size: 18.sp, color: AppColors.textSecondary),
      ),
    );
  }
}