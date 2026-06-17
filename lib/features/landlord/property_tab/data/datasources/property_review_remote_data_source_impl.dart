import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/property_review_model.dart';
import 'property_review_remote_data_source.dart';

class PropertyReviewRemoteDataSourceImpl implements PropertyReviewRemoteDataSource {
  PropertyReviewRemoteDataSourceImpl({required this.firestore});

  final FirebaseFirestore firestore;

  @override
  Stream<List<PropertyReviewModel>> watchPropertyReviews({
    required String propertyId,
    required int limit,
  }) {
    final normalizedId = propertyId.trim();
    if (normalizedId.isEmpty || limit <= 0) {
      return Stream.value(const <PropertyReviewModel>[]);
    }

    return firestore
        .collection('properties')
        .doc(normalizedId)
        .collection('reviews')
        .orderBy('updatedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => _mapSnapshot(snapshot, normalizedId));
  }

  List<PropertyReviewModel> _mapSnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
    String propertyId,
  ) {
    return snapshot.docs.map((doc) {
      final data = Map<String, dynamic>.from(doc.data());
      data['propertyId'] = propertyId;
      return PropertyReviewModel.fromMap(data, reviewId: doc.id);
    }).toList();
  }
}
