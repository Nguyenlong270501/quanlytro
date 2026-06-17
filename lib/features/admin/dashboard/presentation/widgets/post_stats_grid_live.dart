import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../approvals/blocs/admin_property_approvals/admin_property_approvals_cubit.dart';
import '../../data/models/admin_user_stats_counts.dart';
import '../helpers/admin_user_stats_mapper.dart';
import 'admin_stats_grid.dart';

class PostStatsGridLive extends StatelessWidget {
  const PostStatsGridLive({super.key, required this.counts});

  final AdminUserStatsCounts counts;

  @override
  Widget build(BuildContext context) {
    final pendingPosts = context
        .watch<AdminPropertyApprovalsCubit>()
        .state
        .pendingCount;
    final pendingUpdateCount = context
        .watch<AdminPropertyApprovalsCubit>()
        .state
        .pendingUpdateCount;
    return AdminStatsGrid(
      stats: AdminUserStatsMapper.buildPostGridStats(
        counts.copyWith(pendingPosts: pendingPosts + pendingUpdateCount),
      ),
    );
  }
}
