import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/constants/app_enums.dart';
import '../../../../../../core/constants/app_sizes.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_style.dart';
import '../../../../../auth/data/models/user.dart';

class UserMetadataSection extends StatelessWidget {
  const UserMetadataSection({super.key, required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(
            icon: Icons.person_outline,
            label: 'Vai trò:',
            customValue: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                _roleLabel(user.role),
                style: AppTypography.medium12(
                  color: AppColors.info.withValues(alpha: 0.8),
                ),
              ),
            ),
          ),
          _buildInfoRow(
            icon: Icons.shield_outlined,
            label: 'Provider:',
            customValue: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                _providerLabel(user.authProvider),
                style: AppTypography.medium12(color: AppColors.info),
              ),
            ),
          ),

          Divider(height: 1, color: AppColors.border.withValues(alpha: 0.5)),

          _buildInfoRow(
            icon: Icons.calendar_month_outlined,
            label: 'Ngày tạo:',
            value: _formatDateTime(user.createdAt),
          ),

          Divider(height: 1, color: AppColors.border.withValues(alpha: 0.5)),

          _buildInfoRow(
            icon: Icons.update_outlined,
            label: 'Cập nhật gần nhất:',
            value: _formatDateTime(user.updatedAt),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    String? value,
    Widget? customValue,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        children: [
          Icon(icon, size: 20.sp, color: AppColors.textMuted),
          AppSizes.gapW12,
          Text(
            label,
            style: AppTypography.medium14(color: AppColors.textMuted),
          ),
          const Spacer(),
          customValue ??
              Text(
                value ?? '',
                style: AppTypography.bold14(color: AppColors.textPrimary),
              ),
        ],
      ),
    );
  }

  String _roleLabel(UserRole role) {
    return switch (role) {
      UserRole.admin => 'Quản trị viên',
      UserRole.landlord => 'Chủ nhà',
      UserRole.tenant => 'Người thuê',
    };
  }

  String _providerLabel(AuthProvider provider) {
    return switch (provider) {
      AuthProvider.email => 'Email / Password',
      AuthProvider.google => 'Google',
      AuthProvider.facebook => 'Facebook',
    };
  }

  String _formatDateTime(DateTime value) {
    final local = value.toLocal();
    final day = _twoDigits(local.day);
    final month = _twoDigits(local.month);
    final year = local.year.toString();
    final hour = _twoDigits(local.hour);
    final minute = _twoDigits(local.minute);
    return '$day/$month/$year • $hour:$minute';
  }

  String _twoDigits(int value) => value.toString().padLeft(2, '0');
}
