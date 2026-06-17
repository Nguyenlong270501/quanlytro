import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_enums.dart';
import '../../../../auth/data/models/user.dart';
import '../../data/repositories/admin_user_management_repository.dart';
import 'admin_user_detail_state.dart';

class AdminUserDetailCubit extends Cubit<AdminUserDetailState> {
  AdminUserDetailCubit({
    required UserModel user,
    required AdminUserManagementRepository repository,
  }) : _repository = repository,
       super(AdminUserDetailState.initial(user));

  final AdminUserManagementRepository _repository;

  void changeStatus(UserStatus status) {
    emit(
      state.copyWith(
        selectedStatus: status,
        clearSuccess: true,
        clearError: true,
      ),
    );
  }

  Future<void> saveChanges() async {
    if (state.isBusy || !state.hasChanges) {
      return;
    }

    emit(
      state.copyWith(
        isSaving: true,
        clearSuccess: true,
        clearError: true,
      ),
    );

    final result = await _repository.updateUserAccess(
      user: state.user,
      role: state.user.role,
      status: state.selectedStatus,
    );

    result.fold(
      (message) => emit(
        state.copyWith(
          isSaving: false,
          errorMessage: message,
        ),
      ),
      (updatedUser) => emit(
        state.copyWith(
          user: updatedUser,
          selectedStatus: updatedUser.status,
          isSaving: false,
          successMessage: 'Đã lưu thay đổi',
        ),
      ),
    );
  }

  Future<void> resetPassword() async {
    if (state.isBusy) {
      return;
    }

    emit(
      state.copyWith(
        isResettingPassword: true,
        clearSuccess: true,
        clearError: true,
      ),
    );

    final result = await _repository.resetUserPasswordToDefault(state.user);
    result.fold(
      (message) => emit(
        state.copyWith(
          isResettingPassword: false,
          errorMessage: message,
        ),
      ),
      (_) => emit(
        state.copyWith(
          isResettingPassword: false,
          successMessage: 'Đã reset password về mật khẩu mặc định',
        ),
      ),
    );
  }
}
