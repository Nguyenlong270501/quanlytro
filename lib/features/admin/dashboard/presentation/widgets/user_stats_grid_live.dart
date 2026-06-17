import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../approvals/blocs/landlord_requests/landlord_requests_cubit.dart';
import '../../data/models/admin_user_stats_counts.dart';
import '../helpers/admin_user_stats_mapper.dart';
import 'admin_stats_grid.dart';

class UserStatsGridLive extends StatelessWidget {
  const UserStatsGridLive({super.key, required this.counts});

  final AdminUserStatsCounts counts;

  @override
  Widget build(BuildContext context) {
    final pendingLandlord = context
        .watch<LandlordRequestsCubit>()
        .state
        .pendingCount;
    return AdminStatsGrid(
      stats: AdminUserStatsMapper.buildGridStats(
        counts.copyWith(pendingLandlordRequests: pendingLandlord),
      ),
    );
  }
}
