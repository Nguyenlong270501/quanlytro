import 'dart:developer';

import 'package:dartz/dartz.dart';

import '../../../../../core/services/storage_services.dart';
import '../datasources/create_property_data_source.dart';
import '../models/property_model.dart';
import '../models/room_model.dart';
import 'create_property_repository.dart';

class CreatePropertyRepositoryImpl implements CreatePropertyRepository {
  final CreatePropertyDataSource _remoteDataSource;

  CreatePropertyRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<String, void>> createProperty({
    required PropertyModel property,
    required List<RoomModel> rooms,
    List<String> deletedRoomIds = const [],
  }) async {
    try {
      await _remoteDataSource.createProperty(
        property: property,
        rooms: rooms,
        deletedRoomIds: deletedRoomIds,
      );
      return const Right(null);
    } catch (e, stackTrace) {
      log('CreatePropertyRepository.createProperty failed', error: e, stackTrace: stackTrace);
      return Left(_createPropertyError(e));
    }
  }


  @override
  Future<Either<String, List<String>>> syncUploadPropertyGeneralImages({
    required String propertyId,
    required List<String> nextImageUrls,
    Iterable<String>? previousImageUrls,
  }) async {
    try {
      await StorageServices.syncDeletedFirebaseImages(
        previousUrls: previousImageUrls ?? const [],
        nextUrls: nextImageUrls,
      );
      final urls = await StorageServices.uploadMixedPaths(
        pathsOrUrls: nextImageUrls,
        folderPath: 'properties/$propertyId/general_images',
        localPathDedupeCache: <String, String>{},
      );
      return Right(urls);
    } catch (e, stackTrace) {
      log(
        'CreatePropertyRepository.syncUploadPropertyGeneralImages failed',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(_createPropertyError(e));
    }
  }

  @override
  Future<Either<String, RoomModel>> persistRoomEdit({
    required String propertyId,
    required RoomModel room,
    Iterable<String>? previousImageUrls,
  }) async {
    try {
      await StorageServices.syncDeletedFirebaseImages(
        previousUrls: previousImageUrls ?? const [],
        nextUrls: room.imageUrls,
      );

      final urls = await StorageServices.uploadMixedPaths(
        pathsOrUrls: room.imageUrls,
        folderPath: 'properties/$propertyId/rooms/${room.roomId}',
        localPathDedupeCache: <String, String>{},
      );
      final merged = room.copyWith(
        imageUrls: urls,
        propertyId: propertyId,
      );
      await _remoteDataSource.upsertRoom(
        propertyId: propertyId,
        room: merged,
      );
      return Right(merged);
    } catch (e, stackTrace) {
      log('CreatePropertyRepository.persistRoomEdit failed', error: e, stackTrace: stackTrace);
      return Left(_createPropertyError(e));
    }
  }

  @override
  Future<Either<String, void>> deletePropertyAndReleaseQuota({
    required String landlordId,
    required String propertyId,
    required String quotaId,
  }) async {
    try {
      await _remoteDataSource.deletePropertyAndReleaseQuota(
        landlordId: landlordId,
        propertyId: propertyId,
        quotaId: quotaId,
      );
      return const Right(null);
    } catch (e, stackTrace) {
      log(
        'CreatePropertyRepository.deletePropertyAndReleaseQuota failed',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(_createPropertyError(e));
    }
  }

  String _createPropertyError(Object error) {
    final message = error.toString().replaceFirst('Exception: ', '').trim();
    if (message.isEmpty) {
      return 'Không thể lưu dữ liệu nhà trọ';
    }
    return message;
  }
}
