import 'package:dartz/dartz.dart';

import '../../../../../core/data/models/property_quota_model.dart';
import '../../../create_property/data/models/property_model.dart';
import '../models/property_review_model.dart';

abstract class PropertyRepository {
  Future<Either<String, List<PropertyModel>>> getProperties(String landlordId);

  Future<Either<String, PropertyModel>> getPropertyById(String propertyId);

  Stream<Either<String, List<PropertyModel>>> watchProperties(String landlordId);

  Stream<Either<String, List<PropertyQuotaModel>>> watchPropertyQuotas(
    String landlordId,
  );

  Future<Either<String, void>> updatePropertyStatus({
    required String propertyId,
    required PropertyStatus status,
  });

  Stream<Either<String, List<PropertyReviewModel>>> watchPropertyReviews({
    required String propertyId,
    required int limit,
  });
}
