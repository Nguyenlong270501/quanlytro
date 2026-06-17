import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/appointment_model.dart';
import 'appointment_remote_data_source.dart';

class FirebaseAppointmentRemoteDataSource implements AppointmentRemoteDataSource {
  FirebaseAppointmentRemoteDataSource({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _appointments =>
      _firestore.collection('appointments');

  @override
  Future<AppointmentModel> getAppointmentById(String appointmentId) async {
    final normalizedId = appointmentId.trim();
    if (normalizedId.isEmpty) {
      throw Exception('Thiếu mã lịch hẹn');
    }
    final snap = await _appointments.doc(normalizedId).get();
    if (!snap.exists) {
      throw Exception('Không tìm thấy lịch hẹn');
    }
    final data = Map<String, dynamic>.from(snap.data() ?? {});
    final rawId = (data['appointmentId'] ?? '').toString().trim();
    if (rawId.isEmpty) {
      data['appointmentId'] = snap.id;
    }
    return AppointmentModel.fromMap(data);
  }

  Future<void> _updateStatus(
    String appointmentId, {
    required String status,
    String? landlordCancelReason,
    bool deleteLandlordCancelReason = false,
    String? cancelledBy,
    bool deleteCancelledBy = false,
    String? acceptedBy,
    bool deleteAcceptedBy = false,
    DateTime? appointmentDate,
  }) async {
    final data = <String, dynamic>{
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (deleteLandlordCancelReason) {
      data['landlordCancelReason'] = FieldValue.delete();
    } else if (landlordCancelReason != null) {
      data['landlordCancelReason'] = landlordCancelReason;
    }
    if (deleteCancelledBy) {
      data['cancelledBy'] = FieldValue.delete();
    } else if (cancelledBy != null) {
      data['cancelledBy'] = cancelledBy;
    }
    if (deleteAcceptedBy) {
      data['acceptedBy'] = FieldValue.delete();
    } else if (acceptedBy != null) {
      data['acceptedBy'] = acceptedBy;
    }
    if (appointmentDate != null) {
      data['appointmentDate'] = Timestamp.fromDate(appointmentDate);
    }
    await _appointments.doc(appointmentId).update(data);
  }

  @override
  Future<void> acceptAppointment(String appointmentId) async {
    await _updateStatus(
      appointmentId,
      status: AppointmentStatus.accepted,
      deleteLandlordCancelReason: true,
      deleteCancelledBy: true,
      acceptedBy: 'landlord',
    );
  }

  @override
  Future<void> rejectAppointment({
    required String appointmentId,
    required String landlordCancelReason,
  }) async {
    await _updateStatus(
      appointmentId,
      status: AppointmentStatus.rejected,
      landlordCancelReason: landlordCancelReason,
      cancelledBy: 'landlord',
      deleteAcceptedBy: true,
    );
  }

  @override
  Future<void> markAppointmentComplete(String appointmentId) async {
    await _updateStatus(
      appointmentId,
      status: AppointmentStatus.success,
    );
  }

  @override
  Future<void> cancelAcceptedAppointment({
    required String appointmentId,
    required String landlordCancelReason,
  }) async {
    await _updateStatus(
      appointmentId,
      status: AppointmentStatus.cancelled,
      landlordCancelReason: landlordCancelReason,
      cancelledBy: 'landlord',
      deleteAcceptedBy: true,
    );
  }

  @override
  Future<void> rescheduleAppointment({
    required String appointmentId,
    required DateTime appointmentDate,
  }) async {
    await _updateStatus(
      appointmentId,
      status: AppointmentStatus.rescheduled,
      deleteLandlordCancelReason: true,
      deleteCancelledBy: true,
      deleteAcceptedBy: true,
      appointmentDate: appointmentDate,
    );
  }
}
