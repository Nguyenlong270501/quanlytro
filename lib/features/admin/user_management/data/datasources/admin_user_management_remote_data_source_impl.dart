import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../../../../../core/constants/app_enums.dart';
import '../../../../auth/data/models/user.dart';
import 'admin_user_management_remote_data_source.dart';

/// Firestore composite index (tạo trong Console khi SDK báo link):
/// - users: role ASC, createdAt DESC
class AdminUserManagementRemoteDataSourceImpl
    implements AdminUserManagementRemoteDataSource {
  AdminUserManagementRemoteDataSourceImpl({
    FirebaseFirestore? firestore,
    FirebaseFunctions? firebaseFunctions,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _firebaseFunctions =
           firebaseFunctions ??
           FirebaseFunctions.instanceFor(region: 'asia-southeast1');

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _firebaseFunctions;

  @override
  Stream<List<UserModel>> watchUsersByRole({required UserRole role}) {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: role.firestoreValue)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(_mapSnapshot);
  }

  List<UserModel> _mapSnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    return snapshot.docs.map((doc) {
      final data = Map<String, dynamic>.from(doc.data());
      final rawId = (data['userId'] ?? '').toString().trim();
      if (rawId.isEmpty) {
        data['userId'] = doc.id;
      }
      return UserModel.fromMap(data);
    }).toList();
  }

  @override
  Future<void> updateUserAccess({
    required String userId,
    required UserRole role,
    required UserStatus status,
  }) async {
    final batches = <WriteBatch>[_firestore.batch()];
    final userRef = _firestore.collection('users').doc(userId);
    batches.last.update(userRef, {
      'role': role.firestoreValue,
      'status': status.firestoreValue,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    if (role == UserRole.landlord) {
      await _applyLandlordPropertyStatusUpdates(
        batches: batches,
        writeCount: 1,
        landlordId: userId,
        userStatus: status,
      );
    }

    for (final batch in batches) {
      await batch.commit();
    }
  }

  Future<void> _applyLandlordPropertyStatusUpdates({
    required List<WriteBatch> batches,
    required int writeCount,
    required String landlordId,
    required UserStatus userStatus,
  }) async {
    var currentWriteCount = writeCount;
    final snapshot = await _firestore
        .collection('properties')
        .where('landlordId', isEqualTo: landlordId)
        .get();

    for (final doc in snapshot.docs) {
      if (currentWriteCount >= 450) {
        batches.add(_firestore.batch());
        currentWriteCount = 0;
      }
      final data = doc.data();
      if (userStatus == UserStatus.blocked) {
        final currentStatus = (data['status'] ?? '').toString().trim();
        batches.last.update(doc.reference, {
          'status': 'hidden',
          'previousStatus': currentStatus.isEmpty ? null : currentStatus,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        currentWriteCount++;
        continue;
      }

      final previousStatus = (data['previousStatus'] ?? '').toString().trim();
      if (previousStatus.isEmpty) {
        batches.last.update(doc.reference, {
          'previousStatus': null,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        currentWriteCount++;
        continue;
      }
      batches.last.update(doc.reference, {
        'status': previousStatus,
        'previousStatus': null,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      currentWriteCount++;
    }
  }

  @override
  Future<void> resetUserPasswordToDefault({
    required String userId,
    required String email,
  }) async {
    final callable = _firebaseFunctions.httpsCallable(
      'resetUserPasswordToDefault',
    );
    await callable.call(<String, Object?>{
      'uid': userId,
      if (email.trim().isNotEmpty) 'email': email.trim(),
    });
  }
}
