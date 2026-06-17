import 'dart:developer';

import 'package:dartz/dartz.dart';

import '../../../appointment/data/models/appointment_model.dart';
import '../datasources/messages_remote_data_source.dart';
import '../models/notification_model.dart';
import 'messages_repository.dart';

class MessagesRepositoryImpl implements MessagesRepository {
  MessagesRepositoryImpl(this._remoteDataSource);

  final MessagesRemoteDataSource _remoteDataSource;

  @override
  Stream<Either<String, List<AppointmentModel>>>
  watchPendingAppointmentsByLandlord({
    required String landlordId,
    required int limit,
  }) async* {
    try {
      await for (final appointments in _remoteDataSource
          .watchPendingAppointmentsByLandlord(
            landlordId: landlordId,
            limit: limit,
          )) {
        yield Right(appointments);
      }
    } catch (e, stackTrace) {
      log(
        'MessagesRepository.watchPendingAppointmentsByLandlord failed',
        error: e,
        stackTrace: stackTrace,
      );
      yield Left(_messagesError(e));
    }
  }

  @override
  Stream<Either<String, List<AppointmentModel>>>
  watchUpcomingAcceptedAppointments({
    required String landlordId,
    required int limit,
  }) async* {
    try {
      await for (final appointments in _remoteDataSource
          .watchUpcomingAcceptedAppointments(
            landlordId: landlordId,
            limit: limit,
          )) {
        yield Right(appointments);
      }
    } catch (e, stackTrace) {
      log(
        'MessagesRepository.watchUpcomingAcceptedAppointments failed',
        error: e,
        stackTrace: stackTrace,
      );
      yield Left(_messagesError(e));
    }
  }

  @override
  Stream<Either<String, List<AppointmentModel>>> watchHistoryAppointments({
    required String landlordId,
    required int limit,
  }) async* {
    try {
      await for (final appointments in _remoteDataSource
          .watchHistoryAppointments(landlordId: landlordId, limit: limit)) {
        yield Right(appointments);
      }
    } catch (e, stackTrace) {
      log(
        'MessagesRepository.watchHistoryAppointments failed',
        error: e,
        stackTrace: stackTrace,
      );
      yield Left(_messagesError(e));
    }
  }

  @override
  Stream<Either<String, List<NotificationModel>>> watchNotificationsByReceiver({
    required String receiverId,
    required int limit,
  }) async* {
    try {
      await for (final items in _remoteDataSource.watchNotificationsByReceiver(
        receiverId: receiverId,
        limit: limit,
      )) {
        yield Right(items);
      }
    } catch (e, stackTrace) {
      log(
        'MessagesRepository.watchNotificationsByReceiver failed',
        error: e,
        stackTrace: stackTrace,
      );
      yield Left(_notificationsError(e));
    }
  }

  @override
  Future<Either<String, void>> markNotificationRead({
    required String notificationId,
    required String receiverId,
  }) async {
    try {
      await _remoteDataSource.markNotificationRead(
        notificationId: notificationId,
        receiverId: receiverId,
      );
      return const Right(null);
    } catch (e, stackTrace) {
      log(
        'MessagesRepository.markNotificationRead failed',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(_notificationsError(e));
    }
  }

  String _messagesError(Object error) {
    final message = error.toString().replaceFirst('Exception: ', '').trim();
    if (message.isEmpty) {
      return 'Không thể tải lịch hẹn';
    }
    return message;
  }

  String _notificationsError(Object error) {
    final message = error.toString().replaceFirst('Exception: ', '').trim();
    if (message.isEmpty) {
      return 'Không thể tải thông báo';
    }
    return message;
  }
}
