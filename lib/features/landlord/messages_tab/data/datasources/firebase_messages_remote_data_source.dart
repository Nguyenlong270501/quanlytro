import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../appointment/data/models/appointment_model.dart';
import '../models/notification_model.dart';
import 'messages_remote_data_source.dart';

class FirebaseMessagesRemoteDataSource implements MessagesRemoteDataSource {
  FirebaseMessagesRemoteDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _appointmentsRef =>
      _firestore.collection('appointments');

  CollectionReference<Map<String, dynamic>> get _notificationsRef =>
      _firestore.collection('notifications');

  List<AppointmentModel> _mapSnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    return snapshot.docs.map((doc) {
      final data = Map<String, dynamic>.from(doc.data());
      final rawId = (data['appointmentId'] ?? '').toString().trim();
      if (rawId.isEmpty) {
        data['appointmentId'] = doc.id;
      }
      return AppointmentModel.fromMap(data);
    }).toList();
  }

  @override
  Stream<List<AppointmentModel>> watchPendingAppointmentsByLandlord({
    required String landlordId,
    required int limit,
  }) {
    return _appointmentsRef
        .where('landlordId', isEqualTo: landlordId)
        .where(
          'status',
          whereIn: AppointmentStatus.pendingFeedStatuses.toList(),
        )
        .orderBy('appointmentDate')
        .limit(limit)
        .snapshots()
        .map(_mapSnapshot);
  }

  @override
  Stream<List<AppointmentModel>> watchUpcomingAcceptedAppointments({
    required String landlordId,
    required int limit,
  }) {
    return _appointmentsRef
        .where('landlordId', isEqualTo: landlordId)
        .where('status', isEqualTo: AppointmentStatus.accepted)
        .where('appointmentDate', isGreaterThan: Timestamp.now())
        .orderBy('appointmentDate')
        .limit(limit)
        .snapshots()
        .map(_mapSnapshot);
  }

  @override
  Stream<List<AppointmentModel>> watchHistoryAppointments({
    required String landlordId,
    required int limit,
  }) {
    final controller = StreamController<List<AppointmentModel>>.broadcast();
    List<AppointmentModel>? terminalItems;
    List<AppointmentModel>? completedItems;
    List<AppointmentModel>? acceptedPastItems;

    void emitMerged() {
      if (terminalItems == null ||
          completedItems == null ||
          acceptedPastItems == null) {
        return;
      }
      final merged = <AppointmentModel>[
        ...terminalItems!,
        ...completedItems!,
        ...acceptedPastItems!,
      ];
      merged.sort((a, b) => b.appointmentDate.compareTo(a.appointmentDate));
      if (merged.length <= limit) {
        controller.add(merged);
      } else {
        controller.add(merged.sublist(0, limit));
      }
    }

    final terminalSub = _appointmentsRef
        .where('landlordId', isEqualTo: landlordId)
        .where(
          'status',
          whereIn: AppointmentStatus.historyTerminalStatuses.toList(),
        )
        .orderBy('appointmentDate', descending: true)
        .limit(limit)
        .snapshots()
        .listen((snapshot) {
          terminalItems = _mapSnapshot(snapshot);
          emitMerged();
        }, onError: controller.addError);

    final completedSub = _appointmentsRef
        .where('landlordId', isEqualTo: landlordId)
        .where('status', isEqualTo: AppointmentStatus.success)
        .where('appointmentDate', isLessThan: Timestamp.now())
        .orderBy('appointmentDate', descending: true)
        .limit(limit)
        .snapshots()
        .listen((snapshot) {
          completedItems = _mapSnapshot(snapshot);
          emitMerged();
        }, onError: controller.addError);

    final acceptedPastSub = _appointmentsRef
        .where('landlordId', isEqualTo: landlordId)
        .where('status', isEqualTo: AppointmentStatus.accepted)
        .where('appointmentDate', isLessThan: Timestamp.now())
        .orderBy('appointmentDate', descending: true)
        .limit(limit)
        .snapshots()
        .listen((snapshot) {
          acceptedPastItems = _mapSnapshot(snapshot);
          emitMerged();
        }, onError: controller.addError);

    controller.onCancel = () async {
      await terminalSub.cancel();
      await completedSub.cancel();
      await acceptedPastSub.cancel();
    };

    return controller.stream;
  }

  @override
  Stream<List<NotificationModel>> watchNotificationsByReceiver({
    required String receiverId,
    required int limit,
  }) {
    final normalizedId = receiverId.trim();
    if (normalizedId.isEmpty || limit <= 0) {
      return Stream.value(const <NotificationModel>[]);
    }

    return _notificationsRef
        .where('receiverId', isEqualTo: normalizedId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map(NotificationModel.fromFirestore).toList(),
        );
  }

  @override
  Future<void> markNotificationRead({
    required String notificationId,
    required String receiverId,
  }) async {
    final normalizedReceiverId = receiverId.trim();
    final normalizedNotificationId = notificationId.trim();
    if (normalizedReceiverId.isEmpty || normalizedNotificationId.isEmpty) {
      return;
    }

    final docRef = _notificationsRef.doc(normalizedNotificationId);
    final snap = await docRef.get();
    if (!snap.exists) {
      return;
    }
    final data = snap.data();
    if (data == null) {
      return;
    }
    if ((data['receiverId'] ?? '').toString().trim() != normalizedReceiverId) {
      return;
    }
    if (data['isRead'] == true) {
      return;
    }
    await docRef.update({'isRead': true});
  }
}
