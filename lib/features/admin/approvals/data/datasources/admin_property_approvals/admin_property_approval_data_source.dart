import '../../../../../landlord/create_property/data/models/property_model.dart';
import '../../models/landlord_summary.dart';

abstract class AdminPropertyApprovalDataSource {

  Stream<List<PropertyModel>> watchVisiblePropertiesForAdmin();

  Future<List<PropertyModel>> fetchRecentPropertiesForAdmin({int limit = 5});

  Future<PropertyModel?> fetchPropertyWithRooms(String propertyId);

  Future<Map<String, LandlordSummary>> fetchLandlordSummaries(Set<String> userIds);

  Future<void> approveProperty(String propertyId);

  Future<void> rejectProperty(String propertyId, String reason);

  Future<void> approvePendingUpdate({
    required String propertyId,
    required String reviewedBy,
  });

  Future<void> rejectPendingUpdate({
    required String propertyId,
    required String reviewedBy,
    required String reason,
  });
}
