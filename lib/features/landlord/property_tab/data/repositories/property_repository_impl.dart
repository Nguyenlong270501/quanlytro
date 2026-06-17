import 'dart:async';
import 'dart:developer';

import 'package:dartz/dartz.dart';

import '../../../../../core/data/models/property_quota_model.dart';
import '../../../create_property/data/models/property_model.dart';
import '../datasources/property_remote_data_source.dart';
import '../datasources/property_review_remote_data_source.dart';
import '../models/property_review_model.dart';
import 'property_repository.dart';

class PropertyRepositoryImpl implements PropertyRepository {
  PropertyRepositoryImpl({
    required this.remoteDataSource,
    required this.reviewRemoteDataSource,
  });

  final PropertyRemoteDataSource remoteDataSource;
  final PropertyReviewRemoteDataSource reviewRemoteDataSource;

  @override
  Future<Either<String, List<PropertyModel>>> getProperties(
    String landlordId,
  ) async {
    try {
      final properties = await remoteDataSource.getProperties(landlordId);
      return Right(properties);
    } catch (e) {
      log('Repository Error: $e');
      return Left(_propertyError(e));
    }
  }

  @override
  Future<Either<String, PropertyModel>> getPropertyById(
    String propertyId,
  ) async {
    try {
      final property = await remoteDataSource.getPropertyById(propertyId);
      if (property == null) {
        return const Left('Không tìm thấy bài đăng');
      }
      return Right(property);
    } catch (e) {
      log('Repository Error (getPropertyById): $e');
      return Left(_propertyError(e));
    }
  }

  @override
  Stream<Either<String, List<PropertyModel>>> watchProperties(
    String landlordId,
  ) async* {
    try {
      await for (final properties in remoteDataSource.watchProperties(landlordId)) {
        yield Right(properties);
      }
    } catch (e) {
      log('Repository Error (watchProperties): $e');
      yield Left(_propertyError(e));
    }
  }

  @override
  Stream<Either<String, List<PropertyQuotaModel>>> watchPropertyQuotas(
    String landlordId,
  ) {
    return remoteDataSource.watchPropertyQuotas(landlordId).transform(
      StreamTransformer<List<PropertyQuotaModel>,
          Either<String, List<PropertyQuotaModel>>>.fromHandlers(
        handleData: (data, sink) => sink.add(Right(data)),
        handleError: (e, st, sink) => sink.add(Left(_propertyError(e))),
      ),
    );
  }

  @override
  Future<Either<String, void>> updatePropertyStatus({
    required String propertyId,
    required PropertyStatus status,
  }) async {
    try {
      await remoteDataSource.updatePropertyStatus(
        propertyId: propertyId,
        status: status,
      );
      return const Right(null);
    } catch (e) {
      log('Repository Error (updatePropertyStatus): $e');
      return Left(_propertyError(e));
    }
  }

  @override
  Stream<Either<String, List<PropertyReviewModel>>> watchPropertyReviews({
    required String propertyId,
    required int limit,
  }) async* {
    try {
      yield* reviewRemoteDataSource
          .watchPropertyReviews(propertyId: propertyId, limit: limit)
          .map((reviews) => Right<String, List<PropertyReviewModel>>(reviews));
    } catch (e) {
      log('Repository Error (watchPropertyReviews): $e');
      yield Left(_propertyError(e));
    }
  }

  String _propertyError(Object error) {
    final message = error.toString().replaceFirst('Exception: ', '').trim();
    if (message.isEmpty) {
      return 'Không thể xử lý dữ liệu nhà trọ';
    }
    return message;
  }
}
