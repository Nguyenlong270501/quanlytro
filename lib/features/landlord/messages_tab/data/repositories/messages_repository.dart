import 'package:dartz/dartz.dart';

import '../../../appointment/data/models/appointment_model.dart';
import '../models/notification_model.dart';

abstract class MessagesRepository {
  Stream<Either<String, List<AppointmentModel>>>
  watchPendingAppointmentsByLandlord({
    required String landlordId,
    required int limit,
  });

  Stream<Either<String, List<AppointmentModel>>>
  watchUpcomingAcceptedAppointments({
    required String landlordId,
    required int limit,
  });

  Stream<Either<String, List<AppointmentModel>>> watchHistoryAppointments({
    required String landlordId,
    required int limit,
  });

  Stream<Either<String, List<NotificationModel>>> watchNotificationsByReceiver({
    required String receiverId,
    required int limit,
  });

  Future<Either<String, void>> markNotificationRead({
    required String notificationId,
    required String receiverId,
  });
}
