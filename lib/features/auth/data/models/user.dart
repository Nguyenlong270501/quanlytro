import 'dart:convert';
import 'package:quanlytro/core/utils/extension.dart';

import '../../../../core/constants/app_enums.dart';

class UserModel {
  final String userId;
  final String userName;
  final String email;
  final String? phoneNumber;
  final String? avatarUrl;
  final AuthProvider authProvider;
  final UserRole role;
  final UserStatus status;
  final List<String> fcmTokens;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.userId,
    required this.userName,
    required this.email,
    this.phoneNumber,
    this.avatarUrl,
    this.authProvider = AuthProvider.email,
    this.role = UserRole.tenant,
    this.status = UserStatus.active,
    this.fcmTokens = const <String>[],
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'email': email,
      'phoneNumber': phoneNumber,
      'avatarUrl': avatarUrl,
      'authProvider': authProvider.firestoreValue,
      'role': role.firestoreValue,
      'status': status.firestoreValue,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'fcmTokens': fcmTokens,
    };
  }

  static List<String> _parseFcmTokens(dynamic raw) {
    if (raw is! List) {
      return const <String>[];
    }
    final seen = <String>{};
    final result = <String>[];
    for (final item in raw) {
      final token = (item ?? '').toString().trim();
      if (token.isEmpty || !seen.add(token)) {
        continue;
      }
      result.add(token);
    }
    return List<String>.unmodifiable(result);
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: (map['userId'] ?? '') as String,
      userName: (map['userName'] ?? '') as String,
      email: (map['email'] ?? '') as String,
      phoneNumber: map['phoneNumber'] as String?,
      avatarUrl: map['avatarUrl'] as String?,
      authProvider: AuthProvider.fromString(map['authProvider'] as String?),
      role: UserRole.fromString(map['role'] as String?),
      status: UserStatus.fromString(map['status'] as String?),
      fcmTokens: _parseFcmTokens(map['fcmTokens']),
      createdAt: Extension.parseTimestamp(map['createdAt']) ?? DateTime.now(),
      updatedAt: Extension.parseTimestamp(map['updatedAt']) ?? DateTime.now(),
    );
  }

  UserModel copyWith({
    String? userId,
    String? userName,
    String? email,
    String? phoneNumber,
    String? avatarUrl,
    AuthProvider? authProvider,
    UserRole? role,
    UserStatus? status,
    List<String>? fcmTokens,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      authProvider: authProvider ?? this.authProvider,
      role: role ?? this.role,
      status: status ?? this.status,
      fcmTokens: fcmTokens ?? this.fcmTokens,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserModel(userId: $userId, userName: $userName, email: $email, phoneNumber: $phoneNumber, avatarUrl: $avatarUrl, authProvider: ${authProvider.firestoreValue}, role: ${role.firestoreValue}, status: ${status.firestoreValue}, fcmTokens: $fcmTokens, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
