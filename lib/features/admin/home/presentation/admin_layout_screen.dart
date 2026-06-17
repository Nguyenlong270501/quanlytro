import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quanlytro/features/profile/presentation/screens/profile_screen.dart';
import '../../../../core/route/app_routes.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_style.dart';
import '../../approvals/blocs/admin_property_approvals/admin_property_approvals_cubit.dart';
import '../../approvals/blocs/approval_tab/approval_tab_cubit.dart';
import '../../approvals/blocs/landlord_requests/landlord_requests_cubit.dart';
import '../../approvals/data/repositories/admin_property_approvals/admin_property_approval_repository_impl.dart';
import '../../approvals/data/repositories/landlord_request/landlord_request_repository_impl.dart';
import '../../dashboard/data/repositories/admin_dashboard_repository.dart';
import '../../dashboard/blocs/admin_dashboard_cubit.dart';
import '../blocs/admin_navigation_cubit.dart';
import '../../approvals/presentation/approvals_tab/approvals_tab.dart';
import '../../dashboard/presentation/admin_dashboard_tab.dart';
import '../../user_management/data/repositories/admin_user_management_repository.dart';
import '../../user_management/presentation/admin_user_management_tab.dart';
import '../../user_management/blocs/admin_user_management_tab/admin_user_management_tab_cubit.dart';
import '../../user_management/blocs/admin_users_feed/admin_users_feed_cubit.dart';

class AdminLayoutScreen extends StatelessWidget {
  const AdminLayoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AdminNavigationCubit(),
        ),
        BlocProvider(
          create: (context) => LandlordRequestsCubit(
            repository: context.read<LandlordRequestRepositoryImpl>(),
          )..subscribe(),
        ),
        BlocProvider(
          create: (context) => AdminPropertyApprovalsCubit(
            repository: context.read<AdminPropertyApprovalRepositoryImpl>(),
          )..subscribe(),
        ),
        BlocProvider(
          create: (_) => ApprovalTabCubit(),
        ),
        BlocProvider(
          create: (context) => AdminDashboardCubit(
            context.read<AdminDashboardRepository>(),
            approvalRepository: context.read<AdminPropertyApprovalRepositoryImpl>(),
          )
            ..loadUserStats()
            ..loadRecentPosts(),
        ),
        BlocProvider(
          create: (_) => AdminUserManagementTabCubit(),
        ),
        BlocProvider(
          create: (context) => AdminUsersFeedCubit(
            repository: context.read<AdminUserManagementRepository>(),
          )..subscribe(),
        ),
      ],
      child: const _AdminLayoutView(),
    );
  }
}

class _AdminLayoutView extends StatefulWidget {
  const _AdminLayoutView();

  @override
  State<_AdminLayoutView> createState() => _AdminLayoutViewState();
}

class _AdminLayoutViewState extends State<_AdminLayoutView> with RouteAware {
  ModalRoute<dynamic>? _route;

  static const List<_NavItemData> _items = [
    _NavItemData(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
      label: 'Dashboard',
    ),
    _NavItemData(
      icon: Icons.assignment_outlined,
      activeIcon: Icons.assignment,
      label: 'Duyệt đơn',
    ),
    _NavItemData(
      icon: Icons.people_outline,
      activeIcon: Icons.people,
      label: 'Quản lý User',
    ),
    _NavItemData(
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
      label: 'Cài đặt',
    ),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final nextRoute = ModalRoute.of(context);
    if (_route == nextRoute || nextRoute == null) return;
    if (_route != null) {
      appRouteObserver.unsubscribe(this);
    }
    _route = nextRoute;
    appRouteObserver.subscribe(this, nextRoute);
  }

  @override
  void didPopNext() {
    _refreshDashboardData();
  }

  void _refreshDashboardData() {
    final cubit = context.read<AdminDashboardCubit>();
    cubit.loadUserStats(silent: true);
    cubit.loadRecentPosts(silent: true);
  }

  @override
  void dispose() {
    if (_route != null) {
      appRouteObserver.unsubscribe(this);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        body: BlocBuilder<AdminNavigationCubit, AdminNavigationState>(
          buildWhen: (prev, curr) => prev.currentTab != curr.currentTab,
          builder: (context, state) {
            return IndexedStack(
              index: state.currentIndex,
              children: const [
                AdminDashboardTab(),
                ApprovalTab(),
                AdminUserManagementTab(),
                ProfileScreen(),
              ],
            );
          },
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border, width: 1)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 6.h),
              child: BlocBuilder<AdminNavigationCubit, AdminNavigationState>(
                buildWhen: (prev, curr) => prev.currentTab != curr.currentTab,
                builder: (context, state) {
                  return Row(
                    children: List.generate(_items.length, (index) {
                      final item = _items[index];
                      final isActive = state.currentIndex == index;
                      return Expanded(
                        child: InkWell(
                          onTap: () => context
                              .read<AdminNavigationCubit>()
                              .changeTabByIndex(index),
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 6.h),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                index == 1
                                    ? _ApprovalsNavBadgeIcon(
                                        icon: isActive
                                            ? item.activeIcon
                                            : item.icon,
                                        color: isActive
                                            ? AppColors.primary
                                            : AppColors.textDisabled,
                                      )
                                    : _NavIcon(
                                        icon: isActive
                                            ? item.activeIcon
                                            : item.icon,
                                        color: isActive
                                            ? AppColors.primary
                                            : AppColors.textDisabled,
                                      ),
                                AppSizes.gapH4,
                                Text(
                                  item.label,
                                  style: AppTypography.medium12(
                                    color: isActive
                                        ? AppColors.primary
                                        : AppColors.textDisabled,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ApprovalsNavBadgeIcon extends StatelessWidget {
  const _ApprovalsNavBadgeIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

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
    return _NavIcon(
      icon: icon,
      color: color,
      badgeCount: landlordPending + postPending,
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({required this.icon, required this.color, this.badgeCount});

  final IconData icon;
  final Color color;
  final int? badgeCount;

  @override
  Widget build(BuildContext context) {
    final icon = Icon(this.icon, color: color, size: 24.sp);
    if (badgeCount == null || badgeCount == 0) return icon;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        icon,
        Positioned(
          right: -8.w,
          top: -4.h,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: AppColors.danger,
              borderRadius: BorderRadius.circular(10),
            ),
            constraints: BoxConstraints(minWidth: 18.w),
            child: Text(
              '$badgeCount',
              textAlign: TextAlign.center,
              style: AppTypography.bold10(color: AppColors.surface),
            ),
          ),
        ),
      ],
    );
  }
}

class _NavItemData {
  const _NavItemData({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}
