import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  const NotificationModel({
    required this.notificationId,
    required this.receiverId,
    required this.title,
    required this.content,
    required this.type,
    required this.relatedType,
    required this.relatedId,
    required this.isRead,
    required this.createdAt,
    this.appointmentId,
    this.propertyId,
    this.status,
    this.audience,
    this.expiresAt,
  });

  final String notificationId;
  final String receiverId;
  final String title;
  final String content;
  final String type;
  final String relatedType;
  final String relatedId;
  final bool isRead;
  final DateTime createdAt;
  final String? appointmentId;
  final String? propertyId;
  final String? status;
  final String? audience;

  /// TTL trên Firestore (Cloud Functions `notifyUser`); có thể null với doc cũ.
  final DateTime? expiresAt;

  bool get isAppointmentNotification =>
      type == 'appointment' || relatedType == 'appointment';

  String? get resolvedAppointmentId {
    final fromField = appointmentId?.trim();
    if (fromField != null && fromField.isNotEmpty) {
      return fromField;
    }
    if (relatedType == 'appointment') {
      final id = relatedId.trim();
      return id.isNotEmpty ? id : null;
    }
    return null;
  }

  bool get isLandlordRequestNotification =>
      type == 'landlord_request' || relatedType == 'landlord_request';

  String? get resolvedLandlordRequestUserId {
    if (!isLandlordRequestNotification) {
      return null;
    }
    final id = relatedId.trim();
    return id.isNotEmpty ? id : null;
  }

  bool get isPropertyApprovalNotification =>
      type == 'property' || relatedType == 'property';

  String? get resolvedPropertyId {
    final fromField = propertyId?.trim();
    if (fromField != null && fromField.isNotEmpty) {
      return fromField;
    }
    if (relatedType == 'property') {
      final id = relatedId.trim();
      return id.isNotEmpty ? id : null;
    }
    return null;
  }

  factory NotificationModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return NotificationModel.fromMap(data, notificationId: doc.id);
  }

  factory NotificationModel.fromMap(
    Map<String, dynamic> map, {
    required String notificationId,
  }) {
    return NotificationModel(
      notificationId: notificationId,
      receiverId: (map['receiverId'] ?? '').toString(),
      title: (map['title'] ?? '').toString(),
      content: (map['content'] ?? '').toString(),
      type: (map['type'] ?? '').toString(),
      relatedType: (map['relatedType'] ?? '').toString(),
      relatedId: (map['relatedId'] ?? '').toString(),
      isRead: map['isRead'] == true,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ??
          DateTime.fromMillisecondsSinceEpoch(0),
      appointmentId: map['appointmentId']?.toString(),
      propertyId: map['propertyId']?.toString(),
      status: map['status']?.toString(),
      audience: map['audience']?.toString(),
      expiresAt: (map['expiresAt'] as Timestamp?)?.toDate(),
    );
  }
}
