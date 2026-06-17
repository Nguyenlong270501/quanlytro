import 'package:cloud_firestore/cloud_firestore.dart';

class PropertyReviewModel {
  const PropertyReviewModel({
    required this.reviewId,
    required this.propertyId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.avatarUrl,
  });

  final String reviewId;
  final String propertyId;
  final String userId;
  final String userName;
  final int rating;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? avatarUrl;

  factory PropertyReviewModel.fromMap(
    Map<String, dynamic> map, {
    required String reviewId,
  }) {
    return PropertyReviewModel(
      reviewId: reviewId,
      propertyId: (map['propertyId'] ?? '').toString(),
      userId: (map['userId'] ?? '').toString(),
      userName: (map['userName'] ?? '').toString(),
      rating: (map['rating'] ?? 0).toInt(),
      content: (map['content'] ?? '').toString(),
      createdAt: _parseDateTime(map['createdAt']),
      updatedAt: _parseDateTime(map['updatedAt']),
      avatarUrl: map['avatarUrl']?.toString(),
    );
  }


  static DateTime _parseDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    return DateTime.now(); 
  }
}