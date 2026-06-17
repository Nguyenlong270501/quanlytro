import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../approvals/blocs/admin_property_approvals/admin_property_approvals_cubit.dart';
import '../../../approvals/blocs/landlord_requests/landlord_requests_cubit.dart';
import 'pending_alert_banner.dart';

class PendingApprovalsAlertBanner extends StatelessWidget {
  const PendingApprovalsAlertBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final pendingLandlord = context
        .watch<LandlordRequestsCubit>()
        .state
        .pendingCount;
    final pendingPosts = context
        .watch<AdminPropertyApprovalsCubit>()
        .state
        .pendingCount;
    final pendingUpdateCount = context
        .watch<AdminPropertyApprovalsCubit>()
        .state
        .pendingUpdateCount;
    return PendingAlertBanner(
      count: pendingLandlord + pendingPosts + pendingUpdateCount,
    );
  }
}
