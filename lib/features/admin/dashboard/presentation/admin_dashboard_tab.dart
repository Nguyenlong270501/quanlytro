import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_style.dart';
import '../../approvals/blocs/approval_tab/approval_tab_cubit.dart';
import '../../approvals/blocs/approval_tab/approval_tab_state.dart';
import '../../home/blocs/admin_navigation_cubit.dart';
import '../blocs/admin_dashboard_cubit.dart';
import '../blocs/admin_dashboard_state.dart';
import 'widgets/admin_header.dart';
import 'widgets/area_distribution_section.dart';
import 'widgets/dashboard_stats_error.dart';
import 'widgets/dashboard_stats_loading.dart';
import 'widgets/pending_approvals_alert_banner.dart';
import 'widgets/post_stats_grid_live.dart';
import 'widgets/recent_posts_empty.dart';
import 'widgets/recent_posts_header.dart';
import 'widgets/recent_posts_list.dart';
import 'widgets/user_stats_grid_live.dart';

class AdminDashboardTab extends StatelessWidget {
  const AdminDashboardTab({super.key});

  @override
  Widget build(BuildContext context) => const _AdminDashboardBody();
}

class _AdminDashboardBody extends StatelessWidget {
  const _AdminDashboardBody();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AdminHeader(adminName: 'Admin'),
            AppSizes.gapH16,
            const PendingApprovalsAlertBanner(),
            AppSizes.gapH16,
            const _SectionTitle('Thống kê người dùng'),
            AppSizes.gapH12,
            BlocBuilder<AdminDashboardCubit, AdminDashboardState>(
              buildWhen: (prev, curr) =>
                  prev.status != curr.status ||
                  prev.counts != curr.counts ||
                  prev.errorMessage != curr.errorMessage,
              builder: (context, state) {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 240),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: switch (state.status) {
                    AdminDashboardStatus.initial ||
                    AdminDashboardStatus.loading => const DashboardStatsLoading(
                      key: ValueKey('user_stats_loading'),
                    ),
                    AdminDashboardStatus.failure => DashboardStatsError(
                      key: const ValueKey('user_stats_error'),
                      message: state.errorMessage ?? 'Không thể tải thống kê.',
                      onRetry: () =>
                          context.read<AdminDashboardCubit>().loadUserStats(),
                    ),
                    AdminDashboardStatus.loaded => UserStatsGridLive(
                      key: const ValueKey('user_stats_loaded'),
                      counts: state.counts!,
                    ),
                  },
                );
              },
            ),
            AppSizes.gapH16,
            const _SectionTitle('Thống kê bài đăng'),
            AppSizes.gapH12,
            BlocBuilder<AdminDashboardCubit, AdminDashboardState>(
              buildWhen: (prev, curr) =>
                  prev.status != curr.status ||
                  prev.counts != curr.counts ||
                  prev.errorMessage != curr.errorMessage,
              builder: (context, state) {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 240),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: switch (state.status) {
                    AdminDashboardStatus.initial ||
                    AdminDashboardStatus.loading => const DashboardStatsLoading(
                      key: ValueKey('post_stats_loading'),
                    ),
                    AdminDashboardStatus.failure => DashboardStatsError(
                      key: const ValueKey('post_stats_error'),
                      message:
                          state.errorMessage ??
                          'Không thể tải thống kê bài đăng.',
                      onRetry: () =>
                          context.read<AdminDashboardCubit>().loadUserStats(),
                    ),
                    AdminDashboardStatus.loaded => PostStatsGridLive(
                      key: const ValueKey('post_stats_loaded'),
                      counts: state.counts!,
                    ),
                  },
                );
              },
            ),
            AppSizes.gapH20,
            RecentPostsHeader(
              onViewAllTap: () {
                context.read<AdminNavigationCubit>().changeTab(AdminTab.review);
                context.read<ApprovalTabCubit>().changeTab(ApprovalSubTab.post);
              },
            ),
            AppSizes.gapH12,
            BlocBuilder<AdminDashboardCubit, AdminDashboardState>(
              buildWhen: (prev, curr) =>
                  prev.recentStatus != curr.recentStatus ||
                  prev.recentProperties != curr.recentProperties ||
                  prev.recentLandlordSummaries !=
                      curr.recentLandlordSummaries ||
                  prev.recentErrorMessage != curr.recentErrorMessage,
              builder: (context, state) {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 240),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: switch (state.recentStatus) {
                    AdminDashboardRecentStatus.initial ||
                    AdminDashboardRecentStatus.loading =>
                      const DashboardStatsLoading(
                        key: ValueKey('recent_posts_loading'),
                      ),
                    AdminDashboardRecentStatus.failure => DashboardStatsError(
                      key: const ValueKey('recent_posts_error'),
                      message:
                          state.recentErrorMessage ??
                          'Không thể tải bài đăng gần đây.',
                      onRetry: () =>
                          context.read<AdminDashboardCubit>().loadRecentPosts(),
                    ),
                    AdminDashboardRecentStatus.loaded =>
                      state.recentProperties.isEmpty
                          ? const RecentPostsEmpty(
                              key: ValueKey('recent_posts_empty'),
                            )
                          : RecentPostsList(
                              key: const ValueKey('recent_posts_loaded'),
                              properties: state.recentProperties,
                              landlordSummaries: state.recentLandlordSummaries,
                            ),
                  },
                );
              },
            ),
            AppSizes.gapH20,
            const AreaDistributionSection(areas: _mockAreas),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text, style: AppTypography.bold16(color: AppColors.textPrimary));
}

const List<AreaStatData> _mockAreas = [
  AreaStatData(name: 'Cầu Giấy', percent: 72),
  AreaStatData(name: 'Đống Đa', percent: 58),
  AreaStatData(name: 'Thanh Xuân', percent: 45),
  AreaStatData(name: 'Tây Hồ', percent: 31),
  AreaStatData(name: 'Khác', percent: 20),
];
