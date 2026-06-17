import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_style.dart';

class ApprovalsHeader extends StatelessWidget {
  const ApprovalsHeader({
    super.key,
    required this.title,
    this.onSearchTap,
  });

  final String title;
  final VoidCallback? onSearchTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 40.w),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: AppTypography.bold20(color: AppColors.textPrimary),
          ),
        ),
        _CircleIconButton(icon: Icons.search, onTap: onSearchTap),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        width: 40.w,
        height: 40.w,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowSoft,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 20.sp, color: AppColors.textPrimary),
      ),
    );
  }
}
