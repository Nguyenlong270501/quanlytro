import '../../../appointment/data/models/appointment_model.dart';
import '../models/notification_model.dart';

abstract class MessagesRemoteDataSource {
  Stream<List<AppointmentModel>> watchPendingAppointmentsByLandlord({
    required String landlordId,
    required int limit,
  });

  Stream<List<AppointmentModel>> watchUpcomingAcceptedAppointments({
    required String landlordId,
    required int limit,
  });

  Stream<List<AppointmentModel>> watchHistoryAppointments({
    required String landlordId,
    required int limit,
  });

  Stream<List<NotificationModel>> watchNotificationsByReceiver({
    required String receiverId,
    required int limit,
  });

  Future<void> markNotificationRead({
    required String notificationId,
    required String receiverId,
  });
}
