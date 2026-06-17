import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import '../../../../core/value_objects/email.dart';

part 'forget_password_form_state.dart';

class ForgetPasswordFormCubit extends Cubit<ForgetPasswordFormState> {
  ForgetPasswordFormCubit() : super(const ForgetPasswordFormState());

  void emailChanged(String value) {
    final email = Email.dirty(value);
    emit(
      state.copyWith(
        email: email,
        isValid: Formz.validate([email]),
      ),
    );
  }
}
