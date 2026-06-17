enum UserRole { 
  tenant, 
  landlord, 
  admin;

  String get firestoreValue => name;

  static UserRole fromString(String? value) {
    return UserRole.values.firstWhere(
      (e) => e.name == value,
      orElse: () => UserRole.tenant,
    );
  }
}


enum UserStatus { 
  active, 
  blocked;

  String get firestoreValue => name;
  static UserStatus fromString(String? value) {
    return UserStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => UserStatus.active,
    );
  }
}


enum AuthProvider { 
  google, 
  facebook, 
  email;

  String get firestoreValue => name;
  static AuthProvider fromString(String? value) {
    return AuthProvider.values.firstWhere(
      (e) => e.name == value,
      orElse: () => AuthProvider.email,
    );
  }
}
