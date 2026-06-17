import 'package:cloud_firestore/cloud_firestore.dart';

class PropertyQuotaModel {
  final String quotaId;
  final String userId;
  final int maxRooms;
  final int usedRooms;
  final bool isUsed;
  final DateTime? grantedAt;
  final String? requestId;
  final String? propertyId;

  const PropertyQuotaModel({
    required this.quotaId,
    required this.userId,
    required this.maxRooms,
    this.usedRooms = 0,
    this.isUsed = false,
    this.grantedAt,
    this.requestId,
    this.propertyId,
  });

  Map<String, dynamic> toMap() {
    return {
      'quotaId': quotaId,
      'userId': userId,
      'maxRooms': maxRooms,
      'usedRooms': usedRooms,
      'isUsed': isUsed,
      if (grantedAt != null) 'grantedAt': Timestamp.fromDate(grantedAt!),
      'requestId': requestId,
      'propertyId': propertyId,
    };
  }

  Map<String, dynamic> toFirestoreWriteMap() {
    return {
      'quotaId': quotaId,
      'userId': userId,
      'maxRooms': maxRooms,
      'usedRooms': usedRooms,
      'isUsed': isUsed,
      'grantedAt': grantedAt != null
          ? Timestamp.fromDate(grantedAt!)
          : FieldValue.serverTimestamp(),
      'requestId': requestId,
      'propertyId': propertyId,
    };
  }

  factory PropertyQuotaModel.fromMap(
    Map<String, dynamic> map, {
    String? documentId,
  }) {
    final grantedRaw = map['grantedAt'];
    DateTime? granted;
    if (grantedRaw is Timestamp) {
      granted = grantedRaw.toDate();
    }

    return PropertyQuotaModel(
      quotaId: (map['quotaId'] ?? documentId ?? '') as String,
      userId: (map['userId'] ?? '') as String,
      maxRooms: (map['maxRooms'] as num?)?.toInt() ?? 0,
      usedRooms: (map['usedRooms'] as num?)?.toInt() ?? 0,
      isUsed: map['isUsed'] as bool? ?? false,
      grantedAt: granted,
      requestId: map['requestId'] as String?,
      propertyId: map['propertyId'] as String?,
    );
  }
}
