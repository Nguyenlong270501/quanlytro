import 'package:equatable/equatable.dart';
import '../../data/models/user.dart';

abstract class AuthenticationState extends Equatable {}

class AuthenticationInitial extends AuthenticationState {
  @override
  List<Object?> get props => [];
}

class AuthenticationLoadingState extends AuthenticationState {
  @override
  List<Object?> get props => [];
}

class AuthenticationSuccessState extends AuthenticationState {
  final UserModel user;

  AuthenticationSuccessState(this.user);

  @override
  List<Object?> get props => [user];
}

class PasswordResetEmailSentState extends AuthenticationState {
  PasswordResetEmailSentState(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class AuthenticationErrorState extends AuthenticationState {
  final String error;

  AuthenticationErrorState(this.error);

  @override
  List<Object?> get props => [error];
}

class UnAuthenticationState extends AuthenticationState {
  @override
  List<Object?> get props => [];
}