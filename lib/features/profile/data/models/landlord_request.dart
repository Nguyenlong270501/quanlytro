import 'package:cloud_firestore/cloud_firestore.dart';

enum LandlordRequestStatus { pending, approved, rejected }

extension LandlordRequestStatusX on LandlordRequestStatus {
  String get firestoreValue {
    switch (this) {
      case LandlordRequestStatus.pending:
        return 'pending';
      case LandlordRequestStatus.approved:
        return 'approved';
      case LandlordRequestStatus.rejected:
        return 'rejected';
    }
  }

  static LandlordRequestStatus fromString(String? raw) {
    switch (raw) {
      case 'approved':
        return LandlordRequestStatus.approved;
      case 'rejected':
        return LandlordRequestStatus.rejected;
      default:
        return LandlordRequestStatus.pending;
    }
  }
}

class LandlordRequest {
  const LandlordRequest({
    required this.userId,
    required this.fullName,
    required this.phone,
    required this.address,
    required this.numOfRoomsList,
    required this.cccdFrontUrl,
    required this.cccdBackUrl,
    required this.optionalDocumentUrls,
    this.status = LandlordRequestStatus.pending,
    this.rejectionReason,
    this.createdAt,
    this.updatedAt,
  });

  final String userId;
  final String fullName;
  final String phone;
  final String address;
  final List<int> numOfRoomsList;
  final String cccdFrontUrl;
  final String cccdBackUrl;
  final List<String> optionalDocumentUrls;
  final LandlordRequestStatus status;
  final String? rejectionReason;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Map<String, dynamic> toFirestoreMap() {
    return {
      'userId': userId,
      'fullName': fullName,
      'phone': phone,
      'address': address,
      'numOfRoomsList': numOfRoomsList,
      'cccdFrontUrl': cccdFrontUrl,
      'cccdBackUrl': cccdBackUrl,
      'optionalDocumentUrls': optionalDocumentUrls,
      'status': status.firestoreValue,
      'rejectionReason': rejectionReason,
    };
  }

  factory LandlordRequest.fromFirestore(
    Map<String, dynamic> map, {
    String? documentId,
  }) {
    final uid = (map['userId'] ?? documentId ?? '') as String;
    final urls = map['optionalDocumentUrls'];
    return LandlordRequest(
      userId: uid,
      fullName: (map['fullName'] ?? '') as String,
      phone: (map['phone'] ?? '') as String,
      address: (map['address'] ?? '') as String,
      numOfRoomsList: (map['numOfRoomsList'] as List?)
              ?.map((e) => int.tryParse(e.toString()) ?? 0)
              .toList() ??
          [],
      cccdFrontUrl: (map['cccdFrontUrl'] ?? '') as String,
      cccdBackUrl: (map['cccdBackUrl'] ?? '') as String,
      optionalDocumentUrls: urls is List
          ? urls.map((e) => e.toString()).toList()
          : const [],
      status: LandlordRequestStatusX.fromString(map['status'] as String?),
      rejectionReason: map['rejectionReason'] as String?,
      createdAt: _parseTimestamp(map['createdAt']),
      updatedAt: _parseTimestamp(map['updatedAt']),
    );
  }

  static DateTime? _parseTimestamp(dynamic v) {
    if (v is Timestamp) return v.toDate();
    if (v is String) return DateTime.tryParse(v);
    return null;
  }
}
