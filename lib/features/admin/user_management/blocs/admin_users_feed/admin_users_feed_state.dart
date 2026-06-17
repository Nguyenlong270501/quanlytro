import 'package:equatable/equatable.dart';

import '../../../../../core/constants/app_enums.dart';
import '../../../../../core/utils/vietnamese_search.dart';
import '../../../../auth/data/models/user.dart';
import '../admin_user_management_tab/admin_user_management_tab_state.dart';

final class AdminUsersFeedState extends Equatable {
  const AdminUsersFeedState({
    this.landlordItems = const <UserModel>[],
    this.tenantItems = const <UserModel>[],
    this.adminItems = const <UserModel>[],
    this.isLoadingLandlord = false,
    this.isLoadingTenant = false,
    this.isLoadingAdmin = false,
    this.isSearchActive = false,
    this.searchQuery = '',
    this.errorMessage,
  });

  final List<UserModel> landlordItems;
  final List<UserModel> tenantItems;
  final List<UserModel> adminItems;
  final bool isLoadingLandlord;
  final bool isLoadingTenant;
  final bool isLoadingAdmin;
  final bool isSearchActive;
  final String searchQuery;
  final String? errorMessage;

  List<UserModel> itemsForTab(AdminUserRoleTab tab) {
    return switch (tab) {
      AdminUserRoleTab.landlord => landlordItems,
      AdminUserRoleTab.tenant => tenantItems,
      AdminUserRoleTab.admin => adminItems,
    };
  }

  List<UserModel> displayItemsForTab(AdminUserRoleTab tab) {
    final items = itemsForTab(tab);
    final query = searchQuery.trim();
    if (query.isEmpty) {
      return items;
    }
    return items
        .where(
          (user) =>
              vietnameseContainsNormalized(user.userName, query) ||
              vietnameseContainsNormalized(user.email, query),
        )
        .toList();
  }

  bool isLoadingForTab(AdminUserRoleTab tab) {
    return switch (tab) {
      AdminUserRoleTab.landlord => isLoadingLandlord,
      AdminUserRoleTab.tenant => isLoadingTenant,
      AdminUserRoleTab.admin => isLoadingAdmin,
    };
  }

  static UserRole roleForTab(AdminUserRoleTab tab) {
    return switch (tab) {
      AdminUserRoleTab.landlord => UserRole.landlord,
      AdminUserRoleTab.tenant => UserRole.tenant,
      AdminUserRoleTab.admin => UserRole.admin,
    };
  }

  AdminUsersFeedState copyWith({
    List<UserModel>? landlordItems,
    List<UserModel>? tenantItems,
    List<UserModel>? adminItems,
    bool? isLoadingLandlord,
    bool? isLoadingTenant,
    bool? isLoadingAdmin,
    bool? isSearchActive,
    String? searchQuery,
    String? errorMessage,
    bool clearError = false,
    bool clearSearchQuery = false,
  }) {
    return AdminUsersFeedState(
      landlordItems: landlordItems ?? this.landlordItems,
      tenantItems: tenantItems ?? this.tenantItems,
      adminItems: adminItems ?? this.adminItems,
      isLoadingLandlord: isLoadingLandlord ?? this.isLoadingLandlord,
      isLoadingTenant: isLoadingTenant ?? this.isLoadingTenant,
      isLoadingAdmin: isLoadingAdmin ?? this.isLoadingAdmin,
      isSearchActive: isSearchActive ?? this.isSearchActive,
      searchQuery: clearSearchQuery ? '' : (searchQuery ?? this.searchQuery),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    landlordItems,
    tenantItems,
    adminItems,
    isLoadingLandlord,
    isLoadingTenant,
    isLoadingAdmin,
    isSearchActive,
    searchQuery,
    errorMessage,
  ];
}
