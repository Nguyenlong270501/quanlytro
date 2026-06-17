import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../property_tab/blocs/property_list/property_list_state.dart';
import '../../data/landlord_stat_data.dart';

List<LandlordStatData> landlordHomeStats(PropertyListState state) {
  if (state is! PropertyListLoaded) {
    return _statsRow(valueForAll: '0');
  }

  final approvedOnly = state.approvedItems;
  final hiddenOnly = state.hiddenItems;

  final totalRooms = [
    ...approvedOnly,
    ...hiddenOnly,
  ].fold(0, (sum, p) => sum + (p.rooms ?? []).length);

  final vacantRooms = approvedOnly
      .expand((p) => p.rooms ?? [])
      .where((r) => r.isAvailable)
      .length;

  final approvedListingCount = approvedOnly.length;

  final pendingPosts = state.pendingItems.length;

  return _statsRow(
    totalRooms: totalRooms.toString(),
    vacantRooms: vacantRooms.toString(),
    approvedListings: approvedListingCount.toString(),
    pendingPosts: pendingPosts.toString(),
  );
}

List<LandlordStatData> _statsRow({
  String? valueForAll,
  String totalRooms = '0',
  String vacantRooms = '0',
  String approvedListings = '0',
  String pendingPosts = '0',
}) {
  final v = valueForAll;
  final t = v ?? totalRooms;
  final va = v ?? vacantRooms;
  final d = v ?? approvedListings;
  final p = v ?? pendingPosts;

  return [
    LandlordStatData(
      icon: Icons.apartment,
      iconColor: AppColors.primary,
      iconBg: AppColors.successSoft,
      value: t,
      label: 'Tổng số phòng',
    ),
    LandlordStatData(
      icon: Icons.meeting_room_outlined,
      iconColor: AppColors.warning,
      iconBg: AppColors.warningSoft,
      value: va,
      label: 'Phòng trống',
    ),
    LandlordStatData(
      icon: Icons.visibility_outlined,
      iconColor: AppColors.info,
      iconBg: AppColors.infoSoft,
      value: d,
      label: 'Số bài đăng hiển thị',
    ),
    LandlordStatData(
      icon: Icons.hourglass_bottom,
      iconColor: AppColors.accent,
      iconBg: AppColors.accentSoft,
      value: p,
      label: 'Bài đăng chờ duyệt',
    ),
  ];
}
