import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import '../../../../core/value_objects/conf_password.dart';
import '../../../../core/value_objects/password.dart';
import '../../../auth/data/repositories/auth_repository.dart';
import 'change_password_form_state.dart';

class ChangePasswordFormCubit extends Cubit<ChangePasswordFormState> {
  ChangePasswordFormCubit(this._authRepository)
    : super(const ChangePasswordFormState());

  final AuthRepository _authRepository;

  void toggleCurrentPasswordObscure() {
    emit(
      state.copyWith(
        isCurrentPasswordObscure: !state.isCurrentPasswordObscure,
        clearError: true,
      ),
    );
  }

  void toggleNewPasswordObscure() {
    emit(
      state.copyWith(
        isNewPasswordObscure: !state.isNewPasswordObscure,
        clearError: true,
      ),
    );
  }

  void toggleConfirmPasswordObscure() {
    emit(
      state.copyWith(
        isConfirmPasswordObscure: !state.isConfirmPasswordObscure,
        clearError: true,
      ),
    );
  }

  void currentPasswordChanged(String value) {
    final currentPassword = Password.dirty(value);
    emit(
      state.copyWith(
        currentPassword: currentPassword,
        isValid: Formz.validate([
          currentPassword,
          state.newPassword,
          state.confirmPassword,
        ]),
        clearError: true,
      ),
    );
  }

  void newPasswordChanged(String value) {
    final newPassword = Password.dirty(value);
    final confirmPassword = ConfirmPassword.dirty(
      originalPassword: newPassword.value,
      value: state.confirmPassword.value,
    );
    emit(
      state.copyWith(
        newPassword: newPassword,
        confirmPassword: confirmPassword,
        isValid: Formz.validate([
          state.currentPassword,
          newPassword,
          confirmPassword,
        ]),
        clearError: true,
      ),
    );
  }

  void confirmPasswordChanged(String value) {
    final confirmPassword = ConfirmPassword.dirty(
      originalPassword: state.newPassword.value,
      value: value,
    );
    emit(
      state.copyWith(
        confirmPassword: confirmPassword,
        isValid: Formz.validate([
          state.currentPassword,
          state.newPassword,
          confirmPassword,
        ]),
        clearError: true,
      ),
    );
  }

  Future<void> submit() async {
    final currentPassword = Password.dirty(state.currentPassword.value);
    final newPassword = Password.dirty(state.newPassword.value);
    final confirmPassword = ConfirmPassword.dirty(
      originalPassword: newPassword.value,
      value: state.confirmPassword.value,
    );
    final isValid = Formz.validate([
      currentPassword,
      newPassword,
      confirmPassword,
    ]);
    emit(
      state.copyWith(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
        isValid: isValid,
        clearError: true,
        clearSuccess: true,
      ),
    );
    if (!isValid) {
      return;
    }

    emit(
      state.copyWith(
        status: FormzSubmissionStatus.inProgress,
        clearError: true,
        clearSuccess: true,
      ),
    );
    final result = await _authRepository.changePassword(
      currentPassword: currentPassword.value.trim(),
      newPassword: newPassword.value.trim(),
    );
    result.fold(
      (error) => emit(
        state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: error,
          clearSuccess: true,
        ),
      ),
      (_) => emit(
        state.copyWith(
          status: FormzSubmissionStatus.success,
          successMessage: 'Đổi mật khẩu thành công',
          clearError: true,
        ),
      ),
    );
  }

  void clearFeedback() {
    emit(state.copyWith(clearError: true, clearSuccess: true));
  }
}
