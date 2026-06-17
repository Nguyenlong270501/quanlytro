import 'package:dartz/dartz.dart';

import '../../models/landlord_request.dart';

abstract class LandlordRequestRepository {
  Future<Either<String, List<LandlordRequest>>> fetchAll();

  Future<Either<String, List<LandlordRequest>>> fetchByStatus(
    LandlordRequestStatus status,
  );

  Future<Either<String, LandlordRequest>> getByUserId(String userId);

  Stream<Either<String, LandlordRequest?>> watchMyLandlordRequest(String userId);

  Stream<Either<String, List<LandlordRequest>>> watchAll();

  Stream<Either<String, List<LandlordRequest>>> watchByStatus(
    LandlordRequestStatus status,
  );

  Future<Either<String, void>> approve(String userId);

  Future<Either<String, void>> reject(String userId, String reason);
}
