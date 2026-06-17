import '../models/appointment_model.dart';

abstract class AppointmentRemoteDataSource {
  Future<AppointmentModel> getAppointmentById(String appointmentId);

  Future<void> acceptAppointment(String appointmentId);

  Future<void> rejectAppointment({
    required String appointmentId,
    required String landlordCancelReason,
  });

  Future<void> markAppointmentComplete(String appointmentId);

  Future<void> cancelAcceptedAppointment({
    required String appointmentId,
    required String landlordCancelReason,
  });

  Future<void> rescheduleAppointment({
    required String appointmentId,
    required DateTime appointmentDate,
  });
}
