import '../models/property_model.dart';
import '../models/room_model.dart';

abstract class CreatePropertyDataSource {
  Future<void> createProperty({
    required PropertyModel property,
    required List<RoomModel> rooms,
    List<String> deletedRoomIds = const [],
  });


  Future<void> upsertRoom({
    required String propertyId,
    required RoomModel room,
  });


  Future<void> deletePropertyAndReleaseQuota({
    required String landlordId,
    required String propertyId,
    required String quotaId,
  });
}