import 'package:cloud_firestore/cloud_firestore.dart';

class LandlordSummaryModel {
  const LandlordSummaryModel({
    required this.userName,
    this.email,
    this.avatarUrl,
    this.phoneNumber,
    required this.createdAt,
  });

  final String userName;
  final String? email;
  final String? avatarUrl;
  final String? phoneNumber;
  final DateTime createdAt;

  LandlordSummaryModel copyWith({
    String? userName,
    String? email,
    bool clearEmail = false,
    String? avatarUrl,
    String? phoneNumber,
    DateTime? createdAt,
  }) {
    return LandlordSummaryModel(
      userName: userName ?? this.userName,
      email: clearEmail ? null : (email ?? this.email),
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userName': userName,
      'email': email,
      'avatarUrl': avatarUrl,
      'phoneNumber': phoneNumber,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory LandlordSummaryModel.fromMap(Map<String, dynamic> map) {
    return LandlordSummaryModel(
      userName: (map['userName'] ?? map['displayName'] ?? '').toString(),
      email: map['email']?.toString(),
      avatarUrl: map['avatarUrl']?.toString(),
      phoneNumber: (map['phoneNumber'] ?? map['phone'])?.toString(),
      createdAt: _parseDateTime(map['createdAt']),
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.now();
  }
}
