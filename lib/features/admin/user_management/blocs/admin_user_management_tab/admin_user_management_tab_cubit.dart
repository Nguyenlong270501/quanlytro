import 'package:flutter_bloc/flutter_bloc.dart';

import 'admin_user_management_tab_state.dart';

class AdminUserManagementTabCubit extends Cubit<AdminUserManagementTabState> {
  AdminUserManagementTabCubit() : super(const AdminUserManagementTabState());

  void changeTab(AdminUserRoleTab tab) => emit(state.copyWith(currentTab: tab));

  void changeTabByIndex(int index) {
    if (index < 0 || index >= AdminUserRoleTab.values.length) {
      return;
    }
    emit(state.copyWith(currentTab: AdminUserRoleTab.values[index]));
  }
}
