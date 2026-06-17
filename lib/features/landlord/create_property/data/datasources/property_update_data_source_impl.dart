import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../../core/services/storage_services.dart';
import '../models/pending_property_update.dart';
import '../models/property_model.dart';
import '../models/room_model.dart';
import 'property_update_data_source.dart';

class PropertyUpdateDataSourceImpl implements PropertyUpdateDataSource {
  PropertyUpdateDataSourceImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<void> patchPropertyFields(
    String propertyId,
    Map<String, dynamic> patch,
  ) async {
    if (propertyId.isEmpty || patch.isEmpty) return;
    final normalized = _normalizePropertyPatch(patch);
    await _firestore.collection('properties').doc(propertyId).update({
      ...normalized,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> patchRoomFields(
    String propertyId,
    String roomId,
    Map<String, dynamic> patch,
  ) async {
    if (propertyId.isEmpty || roomId.isEmpty || patch.isEmpty) return;
    final normalized = _normalizeRoomPatch(patch);
    await _firestore
        .collection('properties')
        .doc(propertyId)
        .collection('rooms')
        .doc(roomId)
        .update({...normalized, 'updatedAt': FieldValue.serverTimestamp()});
  }

  @override
  Future<void> deleteRooms({
    required String propertyId,
    required List<String> roomIds,
  }) async {
    final ids = roomIds
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (propertyId.isEmpty || ids.isEmpty) return;

    final property = await fetchPropertyWithRooms(propertyId);
    final deleteSet = ids.toSet();

    for (final room in property?.rooms ?? const <RoomModel>[]) {
      if (deleteSet.contains(room.roomId)) {
        await StorageServices.syncDeletedFirebaseImages(
          previousUrls: room.imageUrls,
          nextUrls: const [],
        );
      }
    }

    final batch = _firestore.batch();
    final propertyRef = _firestore.collection('properties').doc(propertyId);
    for (final id in deleteSet) {
      batch.delete(propertyRef.collection('rooms').doc(id));
    }

    batch.update(propertyRef, {
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  @override
  Future<void> clearPendingUpdate(String propertyId) async {
    await _firestore.collection('properties').doc(propertyId).update({
      'hasPendingUpdate': false,
      'pendingUpdate': FieldValue.delete(),
      'rejectedReason': FieldValue.delete(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> setPendingUpdate({
    required String propertyId,
    required PendingPropertyUpdate pendingUpdate,
  }) async {
    await _firestore.collection('properties').doc(propertyId).update({
      'hasPendingUpdate': true,
      'pendingUpdate': pendingUpdate.toMap(),
      'rejectedReason': FieldValue.delete(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> rejectPendingUpdate({
    required String propertyId,
    required String reviewedBy,
    required String reason,
  }) async {
    await _firestore.collection('properties').doc(propertyId).update({
      'hasPendingUpdate': false,
      'pendingUpdate': FieldValue.delete(),
      'rejectedReason': reason,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> approvePendingUpdate({
    required String propertyId,
    required String reviewedBy,
  }) async {
    final property = await fetchPropertyWithRooms(propertyId);
    if (property == null || property.pendingUpdate == null) {
      return;
    }

    final pending = property.pendingUpdate!;
    final batch = _firestore.batch();
    final propertyRef = _firestore.collection('properties').doc(propertyId);

    final propertyPatch = _normalizePropertyPatch(
      Map<String, dynamic>.from(pending.data),
    );

    for (final roomId in pending.roomDeletes) {
      final trimmed = roomId.trim();
      if (trimmed.isEmpty) continue;
      batch.delete(propertyRef.collection('rooms').doc(trimmed));
    }

    for (final entry in pending.roomChanges.entries) {
      final roomId = entry.key.trim();
      if (roomId.isEmpty) continue;
      final roomRef = propertyRef.collection('rooms').doc(roomId);
      batch.update(roomRef, {
        ..._normalizeRoomPatch(entry.value),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    for (final roomMap in pending.roomCreates) {
      final roomRef = propertyRef.collection('rooms').doc();
      final data = Map<String, dynamic>.from(roomMap);
      data['propertyId'] = propertyId;
      data['roomId'] = roomRef.id;
      data['updatedAt'] = FieldValue.serverTimestamp();
      if (!data.containsKey('createdAt')) {
        data['createdAt'] = FieldValue.serverTimestamp();
      }
      batch.set(roomRef, _normalizeRoomPatch(data));
    }

    batch.update(propertyRef, {
      ...propertyPatch,
      'hasPendingUpdate': false,
      'pendingUpdate': FieldValue.delete(),
      'rejectedReason': FieldValue.delete(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  @override
  Future<PropertyModel?> fetchPropertyWithRooms(String propertyId) async {
    if (propertyId.isEmpty) return null;
    final doc = await _firestore.collection('properties').doc(propertyId).get();
    if (!doc.exists) return null;

    final data = Map<String, dynamic>.from(doc.data()!);
    data['propertyId'] = doc.id;

    final roomsSnapshot = await _firestore
        .collection('properties')
        .doc(propertyId)
        .collection('rooms')
        .get();

    final rooms = roomsSnapshot.docs.map((roomDoc) {
      final roomData = Map<String, dynamic>.from(roomDoc.data());
      roomData['roomId'] = roomDoc.id;
      return RoomModel.fromMap(roomData);
    }).toList();

    return PropertyModel.fromMap(data).copyWith(rooms: rooms);
  }



  Map<String, dynamic> _normalizePropertyPatch(Map<String, dynamic> patch) {
    final out = <String, dynamic>{};
    patch.forEach((key, value) {
      if (key == 'location' && value is Map) {
        final lat = (value['latitude'] as num?)?.toDouble();
        final lng = (value['longitude'] as num?)?.toDouble();
        if (lat != null && lng != null) {
          out['location'] = GeoPoint(lat, lng);
        }
        return;
      }
      out[key] = value;
    });
    return out;
  }

  Map<String, dynamic> _normalizeRoomPatch(Map<String, dynamic> patch) {
    final out = <String, dynamic>{};
    patch.forEach((key, value) {
      if (key == 'amenities' && value is List) {
        out[key] = value;
        return;
      }
      out[key] = value;
    });
    return out;
  }

}
