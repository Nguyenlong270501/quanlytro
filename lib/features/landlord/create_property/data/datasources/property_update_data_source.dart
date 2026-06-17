import '../models/pending_property_update.dart';
import '../models/property_model.dart';

abstract class PropertyUpdateDataSource {
  Future<void> patchPropertyFields(
    String propertyId,
    Map<String, dynamic> patch,
  );

  Future<void> patchRoomFields(
    String propertyId,
    String roomId,
    Map<String, dynamic> patch,
  );

  Future<void> deleteRooms({
    required String propertyId,
    required List<String> roomIds,
  });

  Future<void> setPendingUpdate({
    required String propertyId,
    required PendingPropertyUpdate pendingUpdate,
  });

  Future<void> clearPendingUpdate(String propertyId);

  Future<void> approvePendingUpdate({
    required String propertyId,
    required String reviewedBy,
  });

  Future<void> rejectPendingUpdate({
    required String propertyId,
    required String reviewedBy,
    required String reason,
  });

  Future<PropertyModel?> fetchPropertyWithRooms(String propertyId);
}
