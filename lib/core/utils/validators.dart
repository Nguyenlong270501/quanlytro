class Validators {
  static bool isValidEmail(String email) {
    return RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
  }

  static bool isValidPassword(String password) {
    final trimmed = password.trim();
    final hasMinLength = trimmed.length >= 8;
    final hasUppercase = RegExp(r'[A-Z]').hasMatch(trimmed);
    final hasDigit = RegExp(r'\d').hasMatch(trimmed);
    return hasMinLength && hasUppercase && hasDigit;
  }

}
