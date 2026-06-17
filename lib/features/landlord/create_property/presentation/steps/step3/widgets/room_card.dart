import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quanlytro/core/utils/review_helper.dart';
import '../../../../../../../core/constants/app_sizes.dart';
import '../../../../../../../core/theme/app_colors.dart';
import '../../../../../../../core/theme/app_style.dart';
import '../../../../data/models/room_model.dart';

class RoomCard extends StatelessWidget {
  const RoomCard({
    super.key, 
    required this.room, 
    this.onEdit, 
    this.onDelete,
    this.onDuplicate, 
  });

  final RoomModel room;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onDuplicate; 

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${room.roomName} - ${room.roomLocation}',
                  style: AppTypography.bold16(color: AppColors.textPrimary),
                ),
                AppSizes.gapH6,
                Row(
                  children: [
                    Text('Giá thuê: ', style: AppTypography.medium14()),
                    Text(
                      '${ReviewHelper.formatPrice(room.price)} đ/tháng',
                      style: AppTypography.bold14(color: AppColors.primary),
                    ),
                  ],
                ),
                AppSizes.gapH2,
                Row(
                  children: [
                    Text('Tiền cọc: ', style: AppTypography.medium14()),
                    Text(
                      '${ReviewHelper.formatPrice(room.priceDeposit)} đ',
                      style: AppTypography.medium14(color: AppColors.primary),
                    ),
                  ],
                ),
                AppSizes.gapH12,
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    _RoomTag(
                      icon: Icons.square_foot,
                      label: '${room.area.toStringAsFixed(0)}m²',
                    ),
                    _RoomTag(
                      icon: Icons.people_outline,
                      label: 'Tối đa ${room.maxTenants} người',
                    ),
                  ],
                ),
              ],
            ),
          ),
          AppSizes.gapW12,
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _IconActionButton(icon: Icons.edit_outlined, onTap: onEdit),
              AppSizes.gapH10,
              if (onDuplicate != null) ...[
                _IconActionButton(
                  icon: Icons.content_copy_outlined,
                  onTap: onDuplicate,
                ),
                AppSizes.gapH10,
              ],
              _IconActionButton(
                icon: Icons.delete_outline,
                onTap: onDelete,
                danger: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoomTag extends StatelessWidget {
  const _RoomTag({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: AppColors.textMuted),
          SizedBox(width: 4.w),
          Text(
            label,
            style: AppTypography.medium10(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _IconActionButton extends StatelessWidget {
  const _IconActionButton({
    required this.icon,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final bg = danger ? AppColors.errorSoft : AppColors.surface;
    final borderColor = danger ? AppColors.errorSoft : AppColors.border;
    final iconColor = danger ? AppColors.danger : AppColors.textSecondary;
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 36.w,
          height: 36.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 16.sp, color: iconColor),
        ),
      ),
    );
  }
}