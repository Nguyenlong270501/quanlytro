import 'package:dartz/dartz.dart';

import '../../../../../landlord/create_property/data/models/property_model.dart';
import '../../models/landlord_summary.dart';

abstract class AdminPropertyApprovalRepository {
  Stream<List<PropertyModel>> watchVisiblePropertiesForAdmin();

  Future<Either<String, List<PropertyModel>>> getRecentPropertiesForAdmin({
    int limit = 5,
  });

  Future<Either<String, PropertyModel?>> getPropertyWithRooms(String propertyId);

  Future<Either<String, Map<String, LandlordSummary>>> getLandlordSummaries(
    Set<String> userIds,
  );

  Future<Either<String, void>> approveProperty(String propertyId);

  Future<Either<String, void>> rejectProperty(String propertyId, String reason);

  Future<Either<String, void>> approvePendingUpdate({
    required String propertyId,
    required String reviewedBy,
  });

  Future<Either<String, void>> rejectPendingUpdate({
    required String propertyId,
    required String reviewedBy,
    required String reason,
  });
}
