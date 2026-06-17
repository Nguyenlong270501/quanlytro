import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/mixins/notification_permission_lifecycle_mixin.dart';
import '../../auth/blocs/authentication/auth_cubit.dart';
import '../../auth/blocs/authentication/auth_state.dart';
import '../../../core/services/upload_worker_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_alerts.dart';
import '../../profile/presentation/screens/profile_screen.dart';
import '../create_property/data/repositories/create_property_repository.dart';
import '../create_property/presentation/screens/create_property_screen.dart';
import '../messages_tab/presentation/screens/messages_screen.dart';
import '../property_tab/blocs/property_list/property_list_cubit.dart';
import '../property_tab/presentation/property_screen/screens/property_screen.dart';
import '../home_tab/blocs/landlord_navigation_cubit.dart';
import '../home_tab/presentation/landlord_home_tab.dart';
import 'landlord_bottom_nav.dart';

class LandlordLayoutScreen extends StatelessWidget {
  const LandlordLayoutScreen({super.key, this.initialTab});

  final LandlordTab? initialTab;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          LandlordNavigationCubit(initialTab: initialTab ?? LandlordTab.home),
      child: const _LandlordLayoutView(),
    );
  }
}

class _LandlordLayoutView extends StatefulWidget {
  const _LandlordLayoutView();

  @override
  State<_LandlordLayoutView> createState() => _LandlordLayoutViewState();
}

class _LandlordLayoutViewState extends State<_LandlordLayoutView>
    with NotificationPermissionLifecycleMixin<_LandlordLayoutView> {
  DateTime? _lastPressedAt;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final authState = context.read<AuthenticationCubit>().state;

      if (authState is AuthenticationSuccessState) {
        final userId = authState.user.userId.trim();

        if (userId.isNotEmpty) {
          context.read<PropertyListCubit>().fetchProperties(userId);
        }
      }
    });

    final propertyRepo = context.read<CreatePropertyRepository>();

    UploadWorkerService.checkAndUploadDraft(
      propertyRepo,
      onSuccess: (title) {
        if (!mounted) return;

        Alerts.of(
          context,
        ).showSuccess('Bài đăng "$title" đã tải lên thành công! 🎉');
      },
    );
  }

  static const List<NavItemData> _items = [
    NavItemData(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Trang chủ',
    ),
    NavItemData(
      icon: Icons.article_outlined,
      activeIcon: Icons.article,
      label: 'Bài đăng',
    ),
    NavItemData(
      icon: Icons.add,
      activeIcon: Icons.add,
      label: 'Đăng tin',
      isCenter: true,
    ),
    NavItemData(
      icon: Icons.chat_bubble_outline,
      activeIcon: Icons.chat_bubble,
      label: 'Tin nhắn',
      badgeCount: 3,
    ),
    NavItemData(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Tài khoản',
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        final navigationCubit = context.read<LandlordNavigationCubit>();
        final currentTab = navigationCubit.state.currentTab;

        if (currentTab == LandlordTab.createPost) {
          navigationCubit.changeTab(LandlordTab.home);
          return;
        }

        if (currentTab != LandlordTab.home) {
          navigationCubit.changeTab(LandlordTab.home);
          return;
        }

        final now = DateTime.now();
        final maxDuration = const Duration(seconds: 2);

        if (_lastPressedAt == null ||
            now.difference(_lastPressedAt!) > maxDuration) {
          _lastPressedAt = now;

          Alerts.of(
            context,
          ).showInfo('Nhấn trở lại lần nữa để thoát ứng dụng.');
        } else {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        body: BlocBuilder<LandlordNavigationCubit, LandlordNavigationState>(
          buildWhen: (prev, curr) => prev.currentTab != curr.currentTab,
          builder: (context, state) {
            return IndexedStack(
              index: state.currentIndex,
              children: [
                LandlordHomeTab(),
                PropertyScreen(),
                CreatePropertyScreen(),
                MessagesScreen(),
                ProfileScreen(
                  onOpenNotificationSettings:
                      markShouldRecheckNotificationOnResume,
                ),
              ],
            );
          },
        ),
        bottomNavigationBar:
            BlocBuilder<LandlordNavigationCubit, LandlordNavigationState>(
              buildWhen: (prev, curr) => prev.currentTab != curr.currentTab,
              builder: (context, state) {
                if (state.currentTab == LandlordTab.createPost) {
                  return const SizedBox.shrink();
                }
                return LandlordBottomNav(items: _items);
              },
            ),
      ),
    );
  }
}
