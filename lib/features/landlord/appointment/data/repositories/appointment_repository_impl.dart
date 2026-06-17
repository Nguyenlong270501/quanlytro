import 'dart:developer';

import 'package:dartz/dartz.dart';

import '../datasources/appointment_remote_data_source.dart';
import '../models/appointment_model.dart';
import 'appointment_repository.dart';

class AppointmentRepositoryImpl implements AppointmentRepository {
  AppointmentRepositoryImpl({required this.remoteDataSource});

  final AppointmentRemoteDataSource remoteDataSource;

  @override
  Future<Either<String, AppointmentModel>> getAppointmentById(
    String appointmentId,
  ) async {
    try {
      final appointment = await remoteDataSource.getAppointmentById(
        appointmentId,
      );
      return Right(appointment);
    } catch (e) {
      log('Repository Error (getAppointmentById): $e');
      return Left(_formatError(e));
    }
  }

  @override
  Future<Either<String, void>> acceptAppointment(String appointmentId) async {
    try {
      await remoteDataSource.acceptAppointment(appointmentId);
      return const Right(null);
    } catch (e) {
      log('Repository Error (acceptAppointment): $e');
      return Left(_formatError(e));
    }
  }

  @override
  Future<Either<String, void>> rejectAppointment({
    required String appointmentId,
    required String landlordCancelReason,
  }) async {
    try {
      await remoteDataSource.rejectAppointment(
        appointmentId: appointmentId,
        landlordCancelReason: landlordCancelReason,
      );
      return const Right(null);
    } catch (e) {
      log('Repository Error (rejectAppointment): $e');
      return Left(_formatError(e));
    }
  }

  @override
  Future<Either<String, void>> markAppointmentComplete(
    String appointmentId,
  ) async {
    try {
      await remoteDataSource.markAppointmentComplete(appointmentId);
      return const Right(null);
    } catch (e) {
      log('Repository Error (markAppointmentComplete): $e');
      return Left(_formatError(e));
    }
  }

  @override
  Future<Either<String, void>> cancelAcceptedAppointment({
    required String appointmentId,
    required String landlordCancelReason,
  }) async {
    try {
      await remoteDataSource.cancelAcceptedAppointment(
        appointmentId: appointmentId,
        landlordCancelReason: landlordCancelReason,
      );
      return const Right(null);
    } catch (e) {
      log('Repository Error (cancelAcceptedAppointment): $e');
      return Left(_formatError(e));
    }
  }

  @override
  Future<Either<String, void>> rescheduleAppointment({
    required String appointmentId,
    required DateTime appointmentDate,
  }) async {
    try {
      await remoteDataSource.rescheduleAppointment(
        appointmentId: appointmentId,
        appointmentDate: appointmentDate,
      );
      return const Right(null);
    } catch (e) {
      log('Repository Error (rescheduleAppointment): $e');
      return Left(_formatError(e));
    }
  }

  String _formatError(Object error) {
    final message = error.toString().replaceFirst('Exception: ', '').trim();
    if (message.isEmpty) {
      return 'Không thể xử lý lịch hẹn';
    }
    return message;
  }
}
