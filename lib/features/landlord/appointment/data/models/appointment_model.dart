import 'package:cloud_firestore/cloud_firestore.dart';

final class AppointmentStatus {
  static const String pending = 'pending';
  static const String accepted = 'accepted';
  static const String rejected = 'rejected';
  static const String success = 'success';
  static const String cancelled = 'cancelled';
  static const String rescheduled = 'rescheduled';

  static const Set<String> values = <String>{
    pending,
    accepted,
    rejected,
    success,
    cancelled,
    rescheduled,
  };

  static const Set<String> pendingFeedStatuses = <String>{pending, rescheduled};

  static const Set<String> historyTerminalStatuses = <String>{
    rejected,
    cancelled,
  };
}

int comparePendingFeedAppointments(AppointmentModel a, AppointmentModel b) {
  final aRescheduled = a.status == AppointmentStatus.rescheduled;
  final bRescheduled = b.status == AppointmentStatus.rescheduled;
  if (aRescheduled != bRescheduled) {
    return aRescheduled ? 1 : -1;
  }
  return a.appointmentDate.compareTo(b.appointmentDate);
}

class AppointmentModel {
  const AppointmentModel({
    required this.appointmentId,
    required this.propertyId,
    required this.tenantId,
    required this.landlordId,
    required this.appointmentDate,
    required this.purpose,
    required this.note,
    this.landlordCancelReason,
    this.tenantCancelReason,
    this.cancelledBy,
    this.acceptedBy,
    required this.status,
    this.createdAt,
    required this.propertyTitle,
    required this.propertyAddress,
    required this.tenantName,
    required this.tenantPhone,
  });

  final String appointmentId;
  final String propertyId;
  final String tenantId;
  final String landlordId;
  final DateTime appointmentDate;
  final String purpose;
  final String note;
  final String? landlordCancelReason;
  final String? tenantCancelReason;
  final String? cancelledBy;
  final String? acceptedBy;
  final String status;
  final DateTime? createdAt;
  final String propertyTitle;
  final String propertyAddress;
  final String tenantName;
  final String tenantPhone;

  AppointmentModel copyWith({
    String? appointmentId,
    String? propertyId,
    String? tenantId,
    String? landlordId,
    DateTime? appointmentDate,
    String? purpose,
    String? note,
    String? landlordCancelReason,
    String? tenantCancelReason,
    String? cancelledBy,
    String? acceptedBy,
    String? status,
    DateTime? createdAt,
    String? propertyTitle,
    String? propertyAddress,
    String? tenantName,
    String? tenantPhone,
    bool clearLandlordCancelReason = false,
    bool clearTenantCancelReason = false,
    bool clearCancelledBy = false,
    bool clearAcceptedBy = false,
    bool clearCreatedAt = false,
  }) {
    return AppointmentModel(
      appointmentId: appointmentId ?? this.appointmentId,
      propertyId: propertyId ?? this.propertyId,
      tenantId: tenantId ?? this.tenantId,
      landlordId: landlordId ?? this.landlordId,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      purpose: purpose ?? this.purpose,
      note: note ?? this.note,
      landlordCancelReason: clearLandlordCancelReason
          ? null
          : (landlordCancelReason ?? this.landlordCancelReason),
      tenantCancelReason: clearTenantCancelReason
          ? null
          : (tenantCancelReason ?? this.tenantCancelReason),
      cancelledBy: clearCancelledBy ? null : (cancelledBy ?? this.cancelledBy),
      acceptedBy: clearAcceptedBy ? null : (acceptedBy ?? this.acceptedBy),
      status: status ?? this.status,
      createdAt: clearCreatedAt ? null : (createdAt ?? this.createdAt),
      propertyTitle: propertyTitle ?? this.propertyTitle,
      propertyAddress: propertyAddress ?? this.propertyAddress,
      tenantName: tenantName ?? this.tenantName,
      tenantPhone: tenantPhone ?? this.tenantPhone,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'appointmentId': appointmentId,
      'propertyId': propertyId,
      'tenantId': tenantId,
      'landlordId': landlordId,
      'appointmentDate': appointmentDate,
      'purpose': purpose,
      'note': note,
      'landlordCancelReason': landlordCancelReason,
      'tenantCancelReason': tenantCancelReason,
      'cancelledBy': cancelledBy,
      'acceptedBy': acceptedBy,
      'status': status,
    'createdAt': createdAt != null
        ? Timestamp.fromDate(createdAt!)
        : FieldValue.serverTimestamp(),
      'propertyTitle': propertyTitle,
      'propertyAddress': propertyAddress,
      'tenantName': tenantName,
      'tenantPhone': tenantPhone,
    };
  }

  factory AppointmentModel.fromMap(Map<String, dynamic> map) {
    final rawStatus = (map['status'] ?? '').toString().trim().toLowerCase();
    final normalizedStatus = AppointmentStatus.values.contains(rawStatus)
        ? rawStatus
        : AppointmentStatus.pending;

    return AppointmentModel(
      appointmentId: (map['appointmentId'] ?? '').toString(),
      propertyId: (map['propertyId'] ?? '').toString(),
      tenantId: (map['tenantId'] ?? '').toString(),
      landlordId: (map['landlordId'] ?? '').toString(),
      appointmentDate: _parseDateTime(map['appointmentDate']),
      purpose: (map['purpose'] ?? '').toString(),
      note: (map['note'] ?? '').toString(),
      landlordCancelReason: _parseOptionalString(map['landlordCancelReason']),
      tenantCancelReason: _parseOptionalString(map['tenantCancelReason']),
      cancelledBy: _parseOptionalString(map['cancelledBy']),
      acceptedBy: _parseOptionalString(map['acceptedBy']),
      status: normalizedStatus,
      createdAt: _parseNullableDateTime(map['createdAt']),
      propertyTitle: (map['propertyTitle'] ?? '').toString(),
      propertyAddress: (map['propertyAddress'] ?? '').toString(),
      tenantName: (map['tenantName'] ?? '').toString(),
      tenantPhone: (map['tenantPhone'] ?? '').toString(),
    );
  }

  static String? _parseOptionalString(dynamic value) {
    if (value == null) {
      return null;
    }
    final s = value.toString().trim();
    return s.isEmpty ? null : s;
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

  static DateTime? _parseNullableDateTime(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    return null;
  }
}
