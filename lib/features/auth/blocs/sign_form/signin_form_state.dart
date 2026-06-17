part of 'signin_form_cubit.dart';

final class SignInFormState extends Equatable {
  const SignInFormState({
    this.status = FormzSubmissionStatus.initial,
    this.email = const Email.pure(),
    this.password = const Password.pure(),
    this.isValid = false,
    this.isObscure = true,
    this.error,
  });

  final FormzSubmissionStatus status;
  final Email email;
  final Password password;
  final bool isValid;
  final bool isObscure;
  final String? error;

  SignInFormState copyWith({
    FormzSubmissionStatus? status,
    Email? email,
    Password? password,
    bool? isValid,
    bool? isObscure,
    String? error,
  }) {
    return SignInFormState(
      status: status ?? this.status,
      email: email ?? this.email,
      password: password ?? this.password,
      isValid: isValid ?? this.isValid,
      isObscure: isObscure ?? this.isObscure,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        status,
        email,
        password,
        isValid,
        isObscure,
        error,
      ];
}