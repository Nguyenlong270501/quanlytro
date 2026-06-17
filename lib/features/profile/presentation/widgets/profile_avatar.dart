import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_style.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.name,
    required this.email,
    required this.isLandlord,
    required this.avatarUrl,
  });

  final String name;
  final String email;
  final bool isLandlord;
  final String avatarUrl;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          AppSizes.gapH8,
          CircleAvatar(
            radius: 50.r,
            backgroundImage: avatarUrl.isEmpty
                ? const AssetImage('assets/images/profile.png')
                : NetworkImage(avatarUrl),
          ),
          AppSizes.gapH4,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                name,
                style: AppTypography.bold24(color: const Color(0xFF4A4A8B)),
                textAlign: TextAlign.center,
              ),
              AppSizes.gapW4,
              if (isLandlord)
                Icon(
                  Icons.gpp_good,
                  color: Colors.green,
                  size: AppSizes.iconSizeSmall,
                ),
            ],
          ),
          AppSizes.gapH8,
          Text(
            email,
            style: AppTypography.medium18(color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
