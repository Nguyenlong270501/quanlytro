import 'package:formz/formz.dart';
import '../utils/validators.dart';

enum PasswordValidationError { empty, invalid }

class Password extends FormzInput<String, PasswordValidationError> {
  const Password.pure() : super.pure('');
  const Password.dirty(super.value) : super.dirty();

  @override
  PasswordValidationError? validator(String value) {
    if (value.isEmpty) {
      return PasswordValidationError.empty;
    } else if (!Validators.isValidPassword(value)) {
      return PasswordValidationError.invalid;
    }
    return null;
  }
}