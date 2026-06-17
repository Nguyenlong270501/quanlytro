import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../../core/services/pending_storage_cleanup.dart';
import '../models/property_model.dart';
import '../models/room_model.dart';
import 'create_property_data_source.dart'; 

class CreatePropertyDataSourceImpl implements CreatePropertyDataSource {
  CreatePropertyDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<void> createProperty({
    required PropertyModel property,
    required List<RoomModel> rooms,
    List<String> deletedRoomIds = const [],
  }) async {
    final batch = _firestore.batch();

    // --- Property ---
    final propertyRef = property.propertyId.isEmpty
        ? _firestore.collection('properties').doc()
        : _firestore.collection('properties').doc(property.propertyId);

    final savedProperty = property.copyWith(propertyId: propertyRef.id);
    batch.set(propertyRef, savedProperty.toMap());

    for (final roomId in deletedRoomIds) {
      final trimmed = roomId.trim();
      if (trimmed.isEmpty) {
        continue;
      }
      batch.delete(propertyRef.collection('rooms').doc(trimmed));
    }

    // --- Rooms (subcollection) ---
    for (final room in rooms) {
      final roomRef = room.roomId.isEmpty
          ? propertyRef.collection('rooms').doc()
          : propertyRef.collection('rooms').doc(room.roomId);

      final savedRoom = room.copyWith(
        roomId: roomRef.id,
        propertyId: propertyRef.id,
      );
      batch.set(roomRef, savedRoom.toMap());
    }

    final quotaId = savedProperty.quotaId.trim();
    if (quotaId.isNotEmpty) {
      final quotaRef = _firestore
          .collection('users')
          .doc(savedProperty.landlordId)
          .collection('propertyQuotas')
          .doc(quotaId);
      batch.set(
        quotaRef,
        {
          'usedRooms': rooms.length,
          'propertyId': propertyRef.id,
          'isUsed': true,
        },
        SetOptions(merge: true),
      );
    }

    await batch.commit();
  }


  @override
  Future<void> upsertRoom({
    required String propertyId,
    required RoomModel room,
  }) async {
    if (room.roomId.isEmpty) {
      throw ArgumentError('upsertRoom requires non-empty roomId');
    }
    final propertyRef = _firestore.collection('properties').doc(propertyId);
    final roomRef = propertyRef.collection('rooms').doc(room.roomId);
    final saved = room.copyWith(
      roomId: roomRef.id,
      propertyId: propertyRef.id,
    );

    final batch = _firestore.batch();
    batch.set(roomRef, saved.toMap());
    batch.update(propertyRef, {'updatedAt': FieldValue.serverTimestamp()});
    await batch.commit();
  }

  @override
  Future<void> deletePropertyAndReleaseQuota({
    required String landlordId,
    required String propertyId,
    required String quotaId,
  }) async {
    final pid = propertyId.trim();
    if (pid.isEmpty) {
      throw ArgumentError('propertyId must not be empty');
    }

    final propRef = _firestore.collection('properties').doc(pid);

    final propDoc = await propRef.get();
    final roomsSnap = await propRef.collection('rooms').get();
    final imageUrlsToDelete = <String>{};

    final propData = propDoc.data();
    if (propDoc.exists && propData != null) {
      final property = PropertyModel.fromMap(
        Map<String, dynamic>.from(propData)..['propertyId'] = propDoc.id,
      );
      imageUrlsToDelete.addAll(property.imageUrls ?? const <String>[]);
      imageUrlsToDelete.addAll(
        PendingStorageCleanup.collectImageUrls(property.pendingUpdate),
      );
    }

    for (final doc in roomsSnap.docs) {
      final room = RoomModel.fromMap(
        Map<String, dynamic>.from(doc.data())..['roomId'] = doc.id,
      );
      imageUrlsToDelete.addAll(room.imageUrls);
    }

    await PendingStorageCleanup.deleteUrls(imageUrlsToDelete);

    WriteBatch batch = _firestore.batch();
    var ops = 0;
    for (final doc in roomsSnap.docs) {
      batch.delete(doc.reference);
      ops++;
      if (ops >= 450) {
        await batch.commit();
        batch = _firestore.batch();
        ops = 0;
      }
    }
    if (ops > 0) {
      await batch.commit();
    }

    await propRef.delete();

    final qid = quotaId.trim();
    if (qid.isEmpty) return;

    final uid = landlordId.trim();
    if (uid.isEmpty) return;

    final quotaRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('propertyQuotas')
        .doc(qid);
    await quotaRef.set(
      {
        'isUsed': false,
        'usedRooms': 0,
        'propertyId': null,
      },
      SetOptions(merge: true),
    );
  }
}
