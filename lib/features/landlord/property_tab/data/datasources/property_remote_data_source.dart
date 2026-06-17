import '../../../create_property/data/models/property_model.dart';
import '../../../../../core/data/models/property_quota_model.dart';

abstract class PropertyRemoteDataSource {
  Future<List<PropertyModel>> getProperties(String landlordId);

  Future<PropertyModel?> getPropertyById(String propertyId);

  Stream<List<PropertyModel>> watchProperties(String landlordId);

  /// Realtime: toàn bộ doc trong `users/{landlordId}/propertyQuotas`.
  Stream<List<PropertyQuotaModel>> watchPropertyQuotas(String landlordId);

  Future<void> updatePropertyStatus({
    required String propertyId,
    required PropertyStatus status,
  });
}