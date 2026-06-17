import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_style.dart';

class RecentPostsHeader extends StatelessWidget {
  const RecentPostsHeader({super.key, required this.onViewAllTap});

  final VoidCallback onViewAllTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Bài đăng gần đây',
            style: AppTypography.bold16(color: AppColors.textPrimary),
          ),
        ),
        TextButton(
          onPressed: onViewAllTap,
          child: Text(
            'Xem tất cả',
            style: AppTypography.bold14(color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}
