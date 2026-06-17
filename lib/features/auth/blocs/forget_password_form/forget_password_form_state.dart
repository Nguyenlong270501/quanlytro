part of 'forget_password_form_cubit.dart';

final class ForgetPasswordFormState extends Equatable {
  const ForgetPasswordFormState({
    this.email = const Email.pure(),
    this.isValid = false,
  });

  final Email email;
  final bool isValid;

  ForgetPasswordFormState copyWith({
    Email? email,
    bool? isValid,
  }) {
    return ForgetPasswordFormState(
      email: email ?? this.email,
      isValid: isValid ?? this.isValid,
    );
  }

  @override
  List<Object?> get props => [email, isValid];
}
