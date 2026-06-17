import '../../../../../core/utils/extension.dart';

enum LandlordRequestStatus {
  pending,
  approved,
  rejected;

  String get firestoreValue => name;

  static LandlordRequestStatus fromString(String? raw) {
    return LandlordRequestStatus.values.firstWhere(
      (e) => e.name == raw,
      orElse: () => LandlordRequestStatus.pending,
    );
  }
}

class LandlordRequest {
  const LandlordRequest({
    required this.userId,
    required this.fullName,
    required this.phone,
    required this.address,
    required this.cccdFrontUrl,
    required this.cccdBackUrl,
    required this.optionalDocumentUrls,
    required this.numOfRoomsList,
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
    final roomsRaw = map['numOfRoomsList'];
    return LandlordRequest(
      userId: uid,
      fullName: (map['fullName'] ?? '') as String,
      phone: (map['phone'] ?? '') as String,
      address: (map['address'] ?? '') as String,
      numOfRoomsList: roomsRaw is List 
          ? roomsRaw.map((e) => (e as num).toInt()).toList() 
          : const <int>[],
      cccdFrontUrl: (map['cccdFrontUrl'] ?? '') as String,
      cccdBackUrl: (map['cccdBackUrl'] ?? '') as String,
      optionalDocumentUrls: urls is List
          ? urls.map((e) => e.toString()).toList()
          : const [],
      status: LandlordRequestStatus.fromString(map['status'] as String?),
      rejectionReason: map['rejectionReason'] as String?,
      createdAt: Extension.parseTimestamp(map['createdAt']),
      updatedAt: Extension.parseTimestamp(map['updatedAt']),
    );
  }
}
