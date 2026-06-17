import 'package:dartz/dartz.dart';

import '../models/property_model.dart';
import '../models/room_model.dart';

abstract class CreatePropertyRepository {
  Future<Either<String, void>> createProperty({
    required PropertyModel property,
    required List<RoomModel> rooms,
    List<String> deletedRoomIds = const [],
  });


  Future<Either<String, List<String>>> syncUploadPropertyGeneralImages({
    required String propertyId,
    required List<String> nextImageUrls,
    Iterable<String>? previousImageUrls,
  });

  Future<Either<String, RoomModel>> persistRoomEdit({
    required String propertyId,
    required RoomModel room,
    Iterable<String>? previousImageUrls,
  });

  Future<Either<String, void>> deletePropertyAndReleaseQuota({
    required String landlordId,
    required String propertyId,
    required String quotaId,
  });
}
