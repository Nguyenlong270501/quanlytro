import 'package:cloud_firestore/cloud_firestore.dart';

enum PendingUpdateStatus { pending, approved, rejected }

class PendingPropertyUpdate {
  const PendingPropertyUpdate({
    this.status = PendingUpdateStatus.pending,
    this.changedFields = const [],
    this.data = const {},
    this.roomChanges = const {},
    this.roomDeletes = const [],
    this.roomCreates = const [],
    this.requestedAt,
    this.requestedBy = '',
    this.reviewedAt,
    this.reviewedBy,
    this.rejectReason,
  });

  final PendingUpdateStatus status;
  final List<String> changedFields;
  final Map<String, dynamic> data;
  final Map<String, Map<String, dynamic>> roomChanges;
  final List<String> roomDeletes;
  final List<Map<String, dynamic>> roomCreates;
  final DateTime? requestedAt;
  final String requestedBy;
  final DateTime? reviewedAt;
  final String? reviewedBy;
  final String? rejectReason;

  PendingPropertyUpdate copyWith({
    PendingUpdateStatus? status,
    List<String>? changedFields,
    Map<String, dynamic>? data,
    Map<String, Map<String, dynamic>>? roomChanges,
    List<String>? roomDeletes,
    List<Map<String, dynamic>>? roomCreates,
    DateTime? requestedAt,
    String? requestedBy,
    DateTime? reviewedAt,
    String? reviewedBy,
    String? rejectReason,
    bool clearRejectReason = false,
  }) {
    return PendingPropertyUpdate(
      status: status ?? this.status,
      changedFields: changedFields ?? this.changedFields,
      data: data ?? this.data,
      roomChanges: roomChanges ?? this.roomChanges,
      roomDeletes: roomDeletes ?? this.roomDeletes,
      roomCreates: roomCreates ?? this.roomCreates,
      requestedAt: requestedAt ?? this.requestedAt,
      requestedBy: requestedBy ?? this.requestedBy,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      rejectReason: clearRejectReason
          ? null
          : (rejectReason ?? this.rejectReason),
    );
  }

  /// Map ghi Firestore (có Timestamp / FieldValue).
  Map<String, dynamic> toMap() {
    return {
      'status': status.name,
      'changedFields': changedFields,
      'data': data,
      'roomChanges': roomChanges,
      'roomDeletes': roomDeletes,
      'roomCreates': roomCreates,
      'requestedAt': requestedAt != null
          ? Timestamp.fromDate(requestedAt!)
          : FieldValue.serverTimestamp(),
      'requestedBy': requestedBy,
      if (reviewedAt != null) 'reviewedAt': Timestamp.fromDate(reviewedAt!),
      if (reviewedBy != null) 'reviewedBy': reviewedBy,
      if (rejectReason != null) 'rejectReason': rejectReason,
    };
  }

  /// Map an toàn cho Hive queue (không FieldValue / Timestamp).
  Map<String, dynamic> toHiveMap() {
    return {
      'status': status.name,
      'changedFields': changedFields,
      'data': data,
      'roomChanges': roomChanges,
      'roomDeletes': roomDeletes,
      'roomCreates': roomCreates,
      'requestedAt': (requestedAt ?? DateTime.now()).toUtc().toIso8601String(),
      'requestedBy': requestedBy,
      if (reviewedAt != null)
        'reviewedAt': reviewedAt!.toUtc().toIso8601String(),
      if (reviewedBy != null) 'reviewedBy': reviewedBy,
      if (rejectReason != null) 'rejectReason': rejectReason,
    };
  }

  factory PendingPropertyUpdate.fromMap(Map<String, dynamic>? map) {
    if (map == null || map.isEmpty) {
      return const PendingPropertyUpdate();
    }

    final statusRaw = (map['status'] ?? 'pending').toString();
    final status = PendingUpdateStatus.values.firstWhere(
      (e) => e.name == statusRaw,
      orElse: () => PendingUpdateStatus.pending,
    );

    final roomChangesRaw = map['roomChanges'];
    final roomChanges = <String, Map<String, dynamic>>{};
    if (roomChangesRaw is Map) {
      roomChangesRaw.forEach((key, value) {
        if (key is String && value is Map) {
          roomChanges[key] = Map<String, dynamic>.from(value);
        }
      });
    }

    final roomCreatesRaw = map['roomCreates'];
    final roomCreates = roomCreatesRaw is List
        ? roomCreatesRaw
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList()
        : const <Map<String, dynamic>>[];

    return PendingPropertyUpdate(
      status: status,
      changedFields: List<String>.from(map['changedFields'] ?? const []),
      data: Map<String, dynamic>.from(map['data'] ?? const {}),
      roomChanges: roomChanges,
      roomDeletes: List<String>.from(map['roomDeletes'] ?? const []),
      roomCreates: roomCreates,
      requestedAt: _parseDate(map['requestedAt']),
      requestedBy: (map['requestedBy'] ?? '').toString(),
      reviewedAt: _parseDate(map['reviewedAt']),
      reviewedBy: map['reviewedBy']?.toString(),
      rejectReason: map['rejectReason']?.toString(),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
