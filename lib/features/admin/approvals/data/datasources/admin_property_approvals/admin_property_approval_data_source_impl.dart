import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../../../core/services/pending_storage_cleanup.dart';
import '../../../../../auth/data/models/user.dart';
import '../../../../../landlord/create_property/data/datasources/property_update_data_source_impl.dart';
import '../../../../../landlord/create_property/data/models/property_model.dart';
import '../../../../../landlord/create_property/data/models/room_model.dart';
import '../../models/landlord_summary.dart';
import 'admin_property_approval_data_source.dart';

class AdminPropertyApprovalDataSourceImpl
    implements AdminPropertyApprovalDataSource {
  AdminPropertyApprovalDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const List<String> _adminVisibleStatuses = [
    'pending',
    'approved',
    'rejected',
  ];

  @override
  Stream<List<PropertyModel>> watchVisiblePropertiesForAdmin() {
    return _firestore
        .collection('properties')
        .where('status', whereIn: _adminVisibleStatuses)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(_mapSnapshotWithoutRooms);
  }

  @override
  Future<List<PropertyModel>> fetchRecentPropertiesForAdmin({int limit = 5}) async {
    final snapshot = await _firestore
        .collection('properties')
        .where('status', whereIn: _adminVisibleStatuses)
        .orderBy('updatedAt', descending: true)
        .limit(limit)
        .get();
    return _mapSnapshotWithoutRooms(snapshot);
  }

  /// Danh sách duyệt: chỉ đọc document `properties` (không N+1 subcollection `rooms`).
  List<PropertyModel> _mapSnapshotWithoutRooms(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    final properties = snapshot.docs.map((doc) {
      final propertyData = Map<String, dynamic>.from(doc.data());
      propertyData['propertyId'] = doc.id;
      return PropertyModel.fromMap(propertyData);
    }).toList();

    properties.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return properties;
  }

  @override
  Future<PropertyModel?> fetchPropertyWithRooms(String propertyId) async {
    if (propertyId.isEmpty) return null;
    final doc = await _firestore.collection('properties').doc(propertyId).get();
    if (!doc.exists) return null;
    final propertyData = Map<String, dynamic>.from(doc.data()!);
    propertyData['propertyId'] = doc.id;

    final roomsSnapshot = await _firestore
        .collection('properties')
        .doc(doc.id)
        .collection('rooms')
        .get();

    final rooms = roomsSnapshot.docs.map((roomDoc) {
      final roomData = Map<String, dynamic>.from(roomDoc.data());
      roomData['roomId'] = roomDoc.id;
      return RoomModel.fromMap(roomData);
    }).toList();

    final property = PropertyModel.fromMap(propertyData);
    return property.copyWith(rooms: rooms);
  }

  @override
  Future<Map<String, LandlordSummary>> fetchLandlordSummaries(
    Set<String> userIds,
  ) async {
    final out = <String, LandlordSummary>{};
    final ids = userIds.where((e) => e.isNotEmpty).toList();
    if (ids.isEmpty) return out;

    const chunkSize = 10;
    for (var i = 0; i < ids.length; i += chunkSize) {
      final end = min(i + chunkSize, ids.length);
      final chunk = ids.sublist(i, end);
      final snapshot = await _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: chunk)
          .get();

      for (final doc in snapshot.docs) {
        final data = Map<String, dynamic>.from(doc.data());
        final merged = {...data, 'userId': data['userId'] ?? doc.id};
        final user = UserModel.fromMap(merged);
        final name = user.userName.trim().isEmpty ? doc.id : user.userName.trim();
        out[doc.id] = LandlordSummary(
          userId: doc.id,
          displayName: name,
          email: user.email.trim(),
          phoneNumber: user.phoneNumber?.trim(),
        );
      }
    }
    return out;
  }

  @override
  Future<void> approveProperty(String propertyId) async {
    await _firestore.collection('properties').doc(propertyId).update({
      'status': PropertyStatus.approved.name,
      'rejectedReason': FieldValue.delete(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> rejectProperty(String propertyId, String reason) async {
    await _firestore.collection('properties').doc(propertyId).update({
      'status': PropertyStatus.rejected.name,
      'rejectedReason': reason,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> approvePendingUpdate({
    required String propertyId,
    required String reviewedBy,
  }) {
    return PropertyUpdateDataSourceImpl(firestore: _firestore)
        .approvePendingUpdate(propertyId: propertyId, reviewedBy: reviewedBy);
  }

  @override
  Future<void> rejectPendingUpdate({
    required String propertyId,
    required String reviewedBy,
    required String reason,
  }) async {
    final property = await fetchPropertyWithRooms(propertyId);
    final pending = property?.pendingUpdate;
    if (pending != null) {
      await PendingStorageCleanup.deleteUrls(
        PendingStorageCleanup.collectImageUrls(pending),
      );
    }
    await PropertyUpdateDataSourceImpl(firestore: _firestore).rejectPendingUpdate(
      propertyId: propertyId,
      reviewedBy: reviewedBy,
      reason: reason,
    );
  }
}
