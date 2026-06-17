import '../../models/landlord_request.dart';

abstract class LandlordRequestDataSource {
  Future<List<LandlordRequest>> fetchAll();

  Future<List<LandlordRequest>> fetchByStatus(LandlordRequestStatus status);

  Future<LandlordRequest?> getByUserId(String userId);

  /// Realtime: một doc `landlord_requests/{userId}` (dùng cho chủ trọ xem đơn của mình).
  Stream<LandlordRequest?> watchDocument(String userId);

  Stream<List<LandlordRequest>> watchAll();

  Stream<List<LandlordRequest>> watchByStatus(LandlordRequestStatus status);

  Future<void> approve(String userId);

  Future<void> reject(String userId, String reason);
}
