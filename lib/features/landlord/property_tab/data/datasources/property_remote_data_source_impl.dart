import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../../core/data/models/property_quota_model.dart';
import '../../../create_property/data/models/property_model.dart';
import '../../../create_property/data/models/room_model.dart';
import 'property_remote_data_source.dart';

class PropertyRemoteDataSourceImpl implements PropertyRemoteDataSource {
  PropertyRemoteDataSourceImpl({required this.firestore});

  final FirebaseFirestore firestore;

  Query<Map<String, dynamic>> _propertiesQuery(String landlordId) {
    return firestore
        .collection('properties')
        .where('landlordId', isEqualTo: landlordId)
        .orderBy('createdAt', descending: true);
  }

  Future<PropertyModel> _hydratePropertyDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) async {
    final propertyData = Map<String, dynamic>.from(doc.data() ?? {});
    propertyData['propertyId'] = doc.id;

    final roomsSnapshot = await firestore
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

  Future<List<PropertyModel>> _hydrateSnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) async {
    return Future.wait(snapshot.docs.map(_hydratePropertyDoc));
  }

  @override
  Future<List<PropertyModel>> getProperties(String landlordId) async {
    try {
      final snapshot = await _propertiesQuery(landlordId).get();
      return _hydrateSnapshot(snapshot);
    } on FirebaseException catch (e) {
      throw Exception('Lỗi Firebase: ${e.message}');
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }

  @override
  Future<PropertyModel?> getPropertyById(String propertyId) async {
    try {
      final doc = await firestore.collection('properties').doc(propertyId).get();
      if (!doc.exists) {
        return null;
      }
      return _hydratePropertyDoc(doc);
    } on FirebaseException catch (e) {
      throw Exception('Lỗi Firebase: ${e.message}');
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }

  @override
  Stream<List<PropertyModel>> watchProperties(String landlordId) {
    return _propertiesQuery(landlordId).snapshots().asyncMap(_hydrateSnapshot);
  }

  @override
  Stream<List<PropertyQuotaModel>> watchPropertyQuotas(String landlordId) {
    return firestore
        .collection('users')
        .doc(landlordId)
        .collection('propertyQuotas')
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map((d) {
        return PropertyQuotaModel.fromMap(
          Map<String, dynamic>.from(d.data()),
          documentId: d.id,
        );
      }).toList();
      list.sort((a, b) {
        final at = a.grantedAt;
        final bt = b.grantedAt;
        if (at == null && bt == null) return a.quotaId.compareTo(b.quotaId);
        if (at == null) return 1;
        if (bt == null) return -1;
        return at.compareTo(bt);
      });
      return list;
    });
  }

  @override
  Future<void> updatePropertyStatus({
    required String propertyId,
    required PropertyStatus status,
  }) async {
    await firestore.collection('properties').doc(propertyId).update({
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    if (status == PropertyStatus.hidden) {
      await _setAllRoomsUnavailable(propertyId);
    }
  }

  /// Đồng bộ ẩn bài: mọi phòng không còn được coi là trống trên Firestore.
  Future<void> _setAllRoomsUnavailable(String propertyId) async {
    final roomsSnap = await firestore
        .collection('properties')
        .doc(propertyId)
        .collection('rooms')
        .get();

    const batchLimit = 500;
    WriteBatch batch = firestore.batch();
    var ops = 0;

    for (final doc in roomsSnap.docs) {
      batch.update(doc.reference, {
        'isAvailable': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      ops++;
      if (ops >= batchLimit) {
        await batch.commit();
        batch = firestore.batch();
        ops = 0;
      }
    }
    if (ops > 0) {
      await batch.commit();
    }
  }
}
