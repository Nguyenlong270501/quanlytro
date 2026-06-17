import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../blocs/approval_filter/approval_filter_cubit.dart';
import '../../blocs/approval_filter/approval_filter_state.dart';
import '../../blocs/approval_tab/approval_tab_cubit.dart';
import '../../blocs/approval_tab/approval_tab_state.dart';
import '../../blocs/approvals_search/approvals_search_cubit.dart';
import '../../blocs/landlord_requests/landlord_requests_cubit.dart';
import '../../blocs/admin_property_approvals/admin_property_approvals_cubit.dart';
import '../property_request/post_approval_section.dart';
import 'widgets/approvals_sub_tabs.dart';
import 'widgets/approvals_tab_header.dart';
import '../landlord_request/landlord_approval_section.dart';

class ApprovalTab extends StatelessWidget {
  const ApprovalTab({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ApprovalFilterCubit>(create: (_) => ApprovalFilterCubit()),
        BlocProvider<ApprovalsSearchCubit>(
          create: (_) => ApprovalsSearchCubit(),
        ),
      ],
      child: const _ApprovalTabView(),
    );
  }
}

class _ApprovalTabView extends StatelessWidget {
  const _ApprovalTabView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 5.h, 16.w, 12.h),
              child: const ApprovalsTabHeader(),
            ),
            BlocBuilder<ApprovalTabCubit, ApprovalTabState>(
              buildWhen: (prev, curr) => prev.currentTab != curr.currentTab,
              builder: (context, tabState) {
                return _ApprovalsPendingTabs(
                  currentIndex: tabState.currentIndex,
                  onChanged: (index) {
                    context.read<ApprovalTabCubit>().changeTabByIndex(index);
                    if (index == ApprovalSubTab.landlord.index) {
                      final filterCubit = context.read<ApprovalFilterCubit>();
                      if (filterCubit.state.currentFilter ==
                          ApprovalFilter.pendingUpdate) {
                        filterCubit.changeFilter(ApprovalFilter.pending);
                      }
                    }
                  },
                );
              },
            ),
            Expanded(
              child: BlocBuilder<ApprovalTabCubit, ApprovalTabState>(
                buildWhen: (prev, curr) => prev.currentTab != curr.currentTab,
                builder: (context, state) {
                  return IndexedStack(
                    index: state.currentIndex,
                    children: const [
                      LandlordApprovalSection(),
                      PostApprovalSection(),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ApprovalsPendingTabs extends StatelessWidget {
  const _ApprovalsPendingTabs({
    required this.currentIndex,
    required this.onChanged,
  });

  final int currentIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final landlordPending = context
        .watch<LandlordRequestsCubit>()
        .state
        .pendingCount;
    final postPending = context
        .watch<AdminPropertyApprovalsCubit>()
        .state
        .postTabBadgeCount;
    return ApprovalsSubTabs(
      currentIndex: currentIndex,
      tabs: [
        ApprovalsSubTab(label: 'Chủ trọ', count: landlordPending),
        ApprovalsSubTab(label: 'Bài đăng', count: postPending),
      ],
      onChanged: onChanged,
    );
  }
}
