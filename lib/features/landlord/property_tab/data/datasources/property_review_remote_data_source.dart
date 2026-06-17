import '../models/property_review_model.dart';

abstract class PropertyReviewRemoteDataSource {
  Stream<List<PropertyReviewModel>> watchPropertyReviews({
    required String propertyId,
    required int limit,
  });
}
