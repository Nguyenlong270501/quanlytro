import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/landlord_request.dart';
import '../../../../../../core/data/models/property_quota_model.dart';
import 'landlord_request_data_source.dart';

class LandlordRequestDataSourceImpl implements LandlordRequestDataSource {
  LandlordRequestDataSourceImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  static const String _collection = 'landlord_requests';

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection(_collection);
  @override
  Future<List<LandlordRequest>> fetchAll() async {
    final snapshot = await _col.orderBy('createdAt', descending: true).get();
    return _mapSnapshot(snapshot);
  }

  @override
  Future<List<LandlordRequest>> fetchByStatus(
    LandlordRequestStatus status,
  ) async {
    final snapshot = await _col
        .where('status', isEqualTo: status.firestoreValue)
        .orderBy('createdAt', descending: true)
        .get();
    return _mapSnapshot(snapshot);
  }

  @override
  Future<LandlordRequest?> getByUserId(String userId) async {
    final doc = await _col.doc(userId).get();
    if (!doc.exists) return null;
    return LandlordRequest.fromFirestore(doc.data()!, documentId: doc.id);
  }

  @override
  Stream<LandlordRequest?> watchDocument(String userId) {
    return _col.doc(userId).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return LandlordRequest.fromFirestore(snap.data()!, documentId: snap.id);
    });
  }

  @override
  Stream<List<LandlordRequest>> watchAll() {
    return _col
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(_mapSnapshot);
  }

  @override
  Stream<List<LandlordRequest>> watchByStatus(LandlordRequestStatus status) {
    return _col
        .where('status', isEqualTo: status.firestoreValue)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(_mapSnapshot);
  }

  @override
  Future<void> approve(String userId) async {
    final requestRef = _col.doc(userId);
    final requestSnap = await requestRef.get();
    if (!requestSnap.exists) {
      throw StateError('landlord_requests/$userId not found');
    }

    final request = LandlordRequest.fromFirestore(
      requestSnap.data()!,
      documentId: requestSnap.id,
    );
    final slots = request.numOfRoomsList;
    final userRef = _firestore.collection('users').doc(userId);
    final quotasRef = userRef.collection('propertyQuotas');
    final slotPrefix = 'from_request_${userId}_slot_';

    final existingQuotas = await quotasRef.get();

    final writeOps = <void Function(WriteBatch b)>[];

    writeOps.add(
      (b) => b.update(requestRef, {
        'status': LandlordRequestStatus.approved.firestoreValue,
        'rejectionReason': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      }),
    );
    writeOps.add(
      (b) => b.update(userRef, {
        'role': 'landlord',
        'phoneNumber': request.phone,
        'updatedAt': DateTime.now().toUtc().toIso8601String(),
      }),
    );

    for (final doc in existingQuotas.docs) {
      if (doc.id.startsWith(slotPrefix)) {
        writeOps.add((b) => b.delete(doc.reference));
      }
    }

    for (var i = 0; i < slots.length; i++) {
      final quotaId = '$slotPrefix$i';
      final maxRooms = slots[i];
      if (maxRooms <= 0) continue;
      final model = PropertyQuotaModel(
        quotaId: quotaId,
        userId: userId,
        maxRooms: maxRooms,
        usedRooms: 0,
        isUsed: false,
        grantedAt: null,
        requestId: userId,
        propertyId: null,
      );
      final payload = model.toFirestoreWriteMap();
      writeOps.add((b) => b.set(quotasRef.doc(quotaId), payload));
    }

    const maxBatchOps = 450;
    var batch = _firestore.batch();
    var countInBatch = 0;
    for (final op in writeOps) {
      if (countInBatch >= maxBatchOps) {
        await batch.commit();
        batch = _firestore.batch();
        countInBatch = 0;
      }
      op(batch);
      countInBatch++;
    }
    if (countInBatch > 0) {
      await batch.commit();
    }
  }

  @override
  Future<void> reject(String userId, String reason) async {
    await _col.doc(userId).update({
      'status': LandlordRequestStatus.rejected.firestoreValue,
      'rejectionReason': reason,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  List<LandlordRequest> _mapSnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    return snapshot.docs
        .map(
          (doc) =>
              LandlordRequest.fromFirestore(doc.data(), documentId: doc.id),
        )
        .toList();
  }
}
