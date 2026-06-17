import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';

import '../../../../core/value_objects/conf_password.dart';
import '../../../../core/value_objects/password.dart';

final class ChangePasswordFormState extends Equatable {
  const ChangePasswordFormState({
    this.currentPassword = const Password.pure(),
    this.newPassword = const Password.pure(),
    this.confirmPassword = const ConfirmPassword.pure(),
    this.isCurrentPasswordObscure = true,
    this.isNewPasswordObscure = true,
    this.isConfirmPasswordObscure = true,
    this.isValid = false,
    this.status = FormzSubmissionStatus.initial,
    this.errorMessage,
    this.successMessage,
  });

  final Password currentPassword;
  final Password newPassword;
  final ConfirmPassword confirmPassword;
  final bool isCurrentPasswordObscure;
  final bool isNewPasswordObscure;
  final bool isConfirmPasswordObscure;
  final bool isValid;
  final FormzSubmissionStatus status;
  final String? errorMessage;
  final String? successMessage;

  ChangePasswordFormState copyWith({
    Password? currentPassword,
    Password? newPassword,
    ConfirmPassword? confirmPassword,
    bool? isCurrentPasswordObscure,
    bool? isNewPasswordObscure,
    bool? isConfirmPasswordObscure,
    bool? isValid,
    FormzSubmissionStatus? status,
    String? errorMessage,
    bool clearError = false,
    String? successMessage,
    bool clearSuccess = false,
  }) {
    return ChangePasswordFormState(
      currentPassword: currentPassword ?? this.currentPassword,
      newPassword: newPassword ?? this.newPassword,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      isCurrentPasswordObscure:
          isCurrentPasswordObscure ?? this.isCurrentPasswordObscure,
      isNewPasswordObscure: isNewPasswordObscure ?? this.isNewPasswordObscure,
      isConfirmPasswordObscure:
          isConfirmPasswordObscure ?? this.isConfirmPasswordObscure,
      isValid: isValid ?? this.isValid,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
    currentPassword,
    newPassword,
    confirmPassword,
    isCurrentPasswordObscure,
    isNewPasswordObscure,
    isConfirmPasswordObscure,
    isValid,
    status,
    errorMessage,
    successMessage,
  ];
}
