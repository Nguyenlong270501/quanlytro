import 'package:dartz/dartz.dart';

import '../models/appointment_model.dart';

abstract class AppointmentRepository {
  Future<Either<String, AppointmentModel>> getAppointmentById(
    String appointmentId,
  );
  Future<Either<String, void>> acceptAppointment(String appointmentId);

  Future<Either<String, void>> rejectAppointment({
    required String appointmentId,
    required String landlordCancelReason,
  });

  Future<Either<String, void>> markAppointmentComplete(String appointmentId);

  Future<Either<String, void>> cancelAcceptedAppointment({
    required String appointmentId,
    required String landlordCancelReason,
  });

  Future<Either<String, void>> rescheduleAppointment({
    required String appointmentId,
    required DateTime appointmentDate,
  });
}
