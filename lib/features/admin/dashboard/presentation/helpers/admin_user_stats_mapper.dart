import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../data/models/admin_user_stats_counts.dart';
import '../widgets/admin_stats_grid.dart';

class AdminUserStatsMapper {
  AdminUserStatsMapper._();

  static List<AdminStatData> buildGridStats(AdminUserStatsCounts c) {
    final total = c.totalUsers;
    final landlordPct =
        total > 0 ? ((c.landlordUsers * 100) / total).round() : 0;
    final tenantPct = total > 0 ? ((c.tenantUsers * 100) / total).round() : 0;

    return [
      AdminStatData(
        icon: Icons.people_alt_outlined,
        iconColor: AppColors.info,
        iconBg: AppColors.infoSoft,
        value: _formatThousands(c.totalUsers),
        label: 'Tổng người dùng',
        subLabel: 'Trên toàn hệ thống',
        subColor: AppColors.primary,
      ),
      AdminStatData(
        icon: Icons.home_work_outlined,
        iconColor: AppColors.primary,
        iconBg: AppColors.successSoft,
        value: _formatThousands(c.landlordUsers),
        label: 'Chủ trọ',
        subLabel: total > 0 ? '$landlordPct% tổng' : '—',
        subColor: AppColors.textMuted,
      ),
      AdminStatData(
        icon: Icons.person_outline,
        iconColor: AppColors.accent,
        iconBg: AppColors.accentSoft,
        value: _formatThousands(c.tenantUsers),
        label: 'Người thuê',
        subLabel: total > 0 ? '$tenantPct% tổng' : '—',
        subColor: AppColors.textMuted,
      ),
      AdminStatData(
        icon: Icons.hourglass_bottom,
        iconColor: AppColors.warning,
        iconBg: AppColors.warningSoft,
        value: _formatThousands(c.pendingLandlordRequests),
        label: 'Chờ duyệt chủ trọ',
        subLabel: 'Cần duyệt hồ sơ',
        subColor: AppColors.warning,
        subBg: AppColors.warningSoft,
      ),
    ];
  }

  static List<AdminStatData> buildPostGridStats(AdminUserStatsCounts c) {
    final total = c.totalPosts;
    final approvedPct =
        total > 0 ? ((c.approvedPosts * 100) / total).round() : 0;

    return [
      AdminStatData(
        icon: Icons.insert_drive_file_outlined,
        iconColor: AppColors.primary,
        iconBg: AppColors.successSoft,
        value: _formatThousands(c.totalPosts),
        label: 'Tổng bài đăng',
        subLabel: 'Trên toàn hệ thống',
        subColor: AppColors.primary,
      ),
      AdminStatData(
        icon: Icons.access_time,
        iconColor: AppColors.warning,
        iconBg: AppColors.warningSoft,
        value: _formatThousands(c.pendingPosts),
        label: 'Chờ duyệt',
        subLabel: 'Cần xử lý',
        subColor: AppColors.warning,
        subBg: AppColors.warningSoft,
      ),
      AdminStatData(
        icon: Icons.check_circle_outline,
        iconColor: AppColors.info,
        iconBg: AppColors.infoSoft,
        value: _formatThousands(c.approvedPosts),
        label: 'Đang hiển thị',
        subLabel: total > 0 ? '$approvedPct% tổng' : '—',
        subColor: AppColors.textMuted,
      ),
      AdminStatData(
        icon: Icons.block,
        iconColor: AppColors.error,
        iconBg: AppColors.errorSoft,
        value: _formatThousands(c.rejectedPosts),
        label: 'Từ chối',
        subLabel: 'Đã bị từ chối',
        subColor: AppColors.error,
      ),
    ];
  }

  /// Định dạng số kiểu 1.248 (phân tách hàng nghìn).
  static String _formatThousands(int n) {
    final digits = n.abs().toString().split('').reversed.toList();
    final buf = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && i % 3 == 0) buf.write('.');
      buf.write(digits[i]);
    }
    final s = buf.toString().split('').reversed.join();
    return n < 0 ? '-$s' : s;
  }
}
