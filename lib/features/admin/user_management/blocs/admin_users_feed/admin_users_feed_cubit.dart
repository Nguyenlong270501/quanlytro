import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../auth/data/models/user.dart';
import '../../data/repositories/admin_user_management_repository.dart';
import '../admin_user_management_tab/admin_user_management_tab_state.dart';
import 'admin_users_feed_state.dart';

class AdminUsersFeedCubit extends Cubit<AdminUsersFeedState> {
  AdminUsersFeedCubit({required AdminUserManagementRepository repository})
    : _repository = repository,
      super(const AdminUsersFeedState());

  final AdminUserManagementRepository _repository;
  StreamSubscription<Either<String, List<UserModel>>>? _landlordSubscription;
  StreamSubscription<Either<String, List<UserModel>>>? _tenantSubscription;
  StreamSubscription<Either<String, List<UserModel>>>? _adminSubscription;

  void subscribe() {
    _subscribeLandlord(isInitialLoad: true);
    _subscribeTenant(isInitialLoad: true);
    _subscribeAdmin(isInitialLoad: true);
  }

  void enterSearch() => emit(state.copyWith(isSearchActive: true));

  void exitSearch() => emit(
    state.copyWith(
      isSearchActive: false,
      clearSearchQuery: true,
    ),
  );

  void updateSearchQuery(String query) =>
      emit(state.copyWith(searchQuery: query));

  void _subscribeLandlord({bool isInitialLoad = false}) {
    if (isInitialLoad) {
      emit(state.copyWith(isLoadingLandlord: true, clearError: true));
    }
    _landlordSubscription?.cancel();
    _landlordSubscription = _repository
        .watchUsersByRole(
          role: AdminUsersFeedState.roleForTab(AdminUserRoleTab.landlord),
        )
        .listen(_onLandlordResult);
  }

  void _subscribeTenant({bool isInitialLoad = false}) {
    if (isInitialLoad) {
      emit(state.copyWith(isLoadingTenant: true, clearError: true));
    }
    _tenantSubscription?.cancel();
    _tenantSubscription = _repository
        .watchUsersByRole(
          role: AdminUsersFeedState.roleForTab(AdminUserRoleTab.tenant),
        )
        .listen(_onTenantResult);
  }

  void _subscribeAdmin({bool isInitialLoad = false}) {
    if (isInitialLoad) {
      emit(state.copyWith(isLoadingAdmin: true, clearError: true));
    }
    _adminSubscription?.cancel();
    _adminSubscription = _repository
        .watchUsersByRole(
          role: AdminUsersFeedState.roleForTab(AdminUserRoleTab.admin),
        )
        .listen(_onAdminResult);
  }

  void _onLandlordResult(Either<String, List<UserModel>> result) {
    result.fold(
      (message) => emit(
        state.copyWith(
          isLoadingLandlord: false,
          errorMessage: message,
        ),
      ),
      (items) => emit(
        state.copyWith(
          isLoadingLandlord: false,
          landlordItems: items,
          clearError: true,
        ),
      ),
    );
  }

  void _onTenantResult(Either<String, List<UserModel>> result) {
    result.fold(
      (message) => emit(
        state.copyWith(
          isLoadingTenant: false,
          errorMessage: message,
        ),
      ),
      (items) => emit(
        state.copyWith(
          isLoadingTenant: false,
          tenantItems: items,
          clearError: true,
        ),
      ),
    );
  }

  void _onAdminResult(Either<String, List<UserModel>> result) {
    result.fold(
      (message) => emit(
        state.copyWith(
          isLoadingAdmin: false,
          errorMessage: message,
        ),
      ),
      (items) => emit(
        state.copyWith(
          isLoadingAdmin: false,
          adminItems: items,
          clearError: true,
        ),
      ),
    );
  }

  @override
  Future<void> close() async {
    await _landlordSubscription?.cancel();
    await _tenantSubscription?.cancel();
    await _adminSubscription?.cancel();
    return super.close();
  }
}
