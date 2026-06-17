import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_style.dart';

class MenuItem extends StatelessWidget {
  const MenuItem({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
    this.grouped = false,
    this.iconColor,
    this.titleColor,
    this.showTrailing = true,
  });

  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final bool grouped;
  final Color? iconColor;
  final Color? titleColor;
  final bool showTrailing;

  static const Color _defaultIcon = Color(0xFF5E5CA8);
  static const Color _defaultTitle = Color(0xFF4A4A8B);

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = iconColor ?? _defaultIcon;
    final effectiveTitleColor = titleColor ?? _defaultTitle;
    final bgColor = grouped ? Colors.white : const Color(0xFFF1F1F5);
    final radius = grouped ? 0.0 : 20.r;

    return Container(
      margin: grouped ? EdgeInsets.zero : EdgeInsets.only(bottom: 12.h),
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(radius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
            child: Row(
              children: [
                Container(
                  width: 28.w,
                  height: 28.w,
                  decoration: BoxDecoration(
                    color: grouped ? const Color(0xFFF1F1F5) : Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: AppSizes.iconSizeSmall,
                    color: effectiveIconColor,
                  ),
                ),
                AppSizes.gapW12,
                Expanded(
                  child: Text(
                    title,
                    style: AppTypography.medium18(color: effectiveTitleColor),
                  ),
                ),
                if (showTrailing)
                  Icon(
                    Icons.chevron_right_rounded,
                    size: AppSizes.iconSizeSmall,
                    color: Colors.black38,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
