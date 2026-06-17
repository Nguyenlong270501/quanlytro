import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/app_enums.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/route/app_routes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_style.dart';
import '../../blocs/admin_users_feed/admin_users_feed_cubit.dart';
import '../../blocs/admin_users_feed/admin_users_feed_state.dart';
import '../../blocs/admin_user_management_tab/admin_user_management_tab_state.dart';
import 'admin_user_card.dart';

class AdminUsersListBody extends StatelessWidget {
  const AdminUsersListBody({super.key, required this.role});

  final UserRole role;

  AdminUserRoleTab get _tab => switch (role) {
    UserRole.landlord => AdminUserRoleTab.landlord,
    UserRole.tenant => AdminUserRoleTab.tenant,
    UserRole.admin => AdminUserRoleTab.admin,
  };

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminUsersFeedCubit, AdminUsersFeedState>(
      buildWhen: (prev, curr) {
        final tab = _tab;
        return prev.itemsForTab(tab) != curr.itemsForTab(tab) ||
            prev.displayItemsForTab(tab) != curr.displayItemsForTab(tab) ||
            prev.isLoadingForTab(tab) != curr.isLoadingForTab(tab) ||
            prev.searchQuery != curr.searchQuery ||
            prev.errorMessage != curr.errorMessage;
      },
      builder: (context, state) {
        if (state.isLoadingForTab(_tab) && state.itemsForTab(_tab).isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final error = state.errorMessage;
        if (error != null && state.itemsForTab(_tab).isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Text(
                error,
                textAlign: TextAlign.center,
                style: AppTypography.medium14(color: AppColors.danger),
              ),
            ),
          );
        }

        final allItems = state.itemsForTab(_tab);
        if (allItems.isEmpty) {
          return Center(
            child: Text(
              'Chưa có người dùng',
              style: AppTypography.medium14(color: AppColors.textMuted),
            ),
          );
        }

        final items = state.displayItemsForTab(_tab);
        if (items.isEmpty && state.searchQuery.trim().isNotEmpty) {
          return Center(
            child: Text(
              'Không tìm thấy người dùng',
              style: AppTypography.medium14(color: AppColors.textMuted),
            ),
          );
        }

        return ListView.separated(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
          itemCount: items.length,
          separatorBuilder: (context, index) {
            if (index >= items.length - 1) {
              return const SizedBox.shrink();
            }
            return AppSizes.gapH12;
          },
          itemBuilder: (context, index) {
            final user = items[index];
            return AdminUserCard(
              user: user,
              onTap: () => context.push(
                RouteNames.adminUserDetail,
                extra: user,
              ),
            );
          },
        );
      },
    );
  }
}
