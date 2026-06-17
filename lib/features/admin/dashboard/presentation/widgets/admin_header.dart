import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quanlytro/core/widgets/app_alerts.dart';

import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_style.dart';

class AdminHeader extends StatelessWidget {
  const AdminHeader({super.key, required this.adminName, this.onTap});

  final String adminName;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: Text(
                  'Xin chào, $adminName',
                  style: AppTypography.bold24(color: AppColors.textPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              AppSizes.gapW8,
              Text('👋', style: TextStyle(fontSize: 20.sp)),
            ],
          ),
        ),
        _ExportButton(
          onTap: () {
            Alerts.of(context).showInfo('Tính năng đang được phát triển');
          },
        ),
      ],
    );
  }
}

class _ExportButton extends StatelessWidget {
  const _ExportButton({required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        width: 40.w,
        height: 40.w,
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
        child: Center(
          child: Icon(
            Icons.download_rounded,
            size: 24.sp,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
