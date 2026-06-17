import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_enums.dart';
import '../../../../core/theme/app_colors.dart';
import '../blocs/admin_user_management_tab/admin_user_management_tab_cubit.dart';
import '../blocs/admin_user_management_tab/admin_user_management_tab_state.dart';
import 'widgets/admin_users_header.dart';
import 'widgets/admin_users_list_body.dart';
import 'widgets/admin_users_sub_tabs.dart';

class AdminUserManagementTab extends StatelessWidget {
  const AdminUserManagementTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 12.h),
              child: const AdminUsersHeader(),
            ),
            BlocBuilder<
              AdminUserManagementTabCubit,
              AdminUserManagementTabState
            >(
              buildWhen: (prev, curr) => prev.currentTab != curr.currentTab,
              builder: (context, tabState) {
                return AdminUsersSubTabs(
                  currentIndex: tabState.currentIndex,
                  onChanged: context
                      .read<AdminUserManagementTabCubit>()
                      .changeTabByIndex,
                );
              },
            ),
            Expanded(
              child:
                  BlocBuilder<
                    AdminUserManagementTabCubit,
                    AdminUserManagementTabState
                  >(
                    buildWhen: (prev, curr) =>
                        prev.currentTab != curr.currentTab,
                    builder: (context, state) {
                      return IndexedStack(
                        index: state.currentIndex,
                        children: const [
                          AdminUsersListBody(role: UserRole.landlord),
                          AdminUsersListBody(role: UserRole.tenant),
                          AdminUsersListBody(role: UserRole.admin),
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
