import 'package:equatable/equatable.dart';

enum AdminUserRoleTab { landlord, tenant, admin }

class AdminUserManagementTabState extends Equatable {
  const AdminUserManagementTabState({
    this.currentTab = AdminUserRoleTab.landlord,
  });

  final AdminUserRoleTab currentTab;

  int get currentIndex => currentTab.index;

  AdminUserManagementTabState copyWith({AdminUserRoleTab? currentTab}) {
    return AdminUserManagementTabState(
      currentTab: currentTab ?? this.currentTab,
    );
  }

  @override
  List<Object?> get props => [currentTab];
}
