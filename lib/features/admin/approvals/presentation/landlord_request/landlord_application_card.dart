import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_style.dart';
import '../approvals_tab/widgets/approval_quick_actions_row.dart';

class LandlordApplication {
  const LandlordApplication({
    required this.name,
    required this.phone,
    this.avatarAsset,
  });

  final String name;
  final String phone;
  final String? avatarAsset;
}

class LandlordApplicationCard extends StatelessWidget {
  const LandlordApplicationCard({
    super.key,
    required this.data,
    this.onReject,
    this.onApprove,
    this.onTap,
  });

  final LandlordApplication data;
  final VoidCallback? onReject;
  final VoidCallback? onApprove;
  final VoidCallback? onTap;

  bool get _showActions => onReject != null && onApprove != null;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(10.w),
            child: Column(
              children: [
                _TopRow(data: data),
                if (_showActions) ...[
                  AppSizes.gapH12,
                  ApprovalQuickActionsRow(
                    onReject: onReject!,
                    onApprove: onApprove!,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopRow extends StatelessWidget {
  const _TopRow({required this.data});

  final LandlordApplication data;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _Avatar(asset: data.avatarAsset),
        AppSizes.gapW12,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bold14(color: AppColors.textPrimary),
              ),
              AppSizes.gapH6,
              Row(
                children: [
                  Icon(Icons.phone, size: 14.sp, color: AppColors.textMuted),
                  AppSizes.gapW6,
                  Flexible(
                    child: Text(
                      data.phone,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.medium12(color: AppColors.textMuted),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        AppSizes.gapW8,
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.asset});

  final String? asset;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 28.r,
      backgroundColor: AppColors.infoSoft,
      child: asset != null
          ? Image.network(
              asset!,
              width: 56.w,
              height: 56.w,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Image.asset('assets/images/profile.png'),
            )
          : Image.asset(
              'assets/images/profile.png',
              width: 56.w,
              height: 56.w,
              fit: BoxFit.cover,
            ),
    );
  }
}

