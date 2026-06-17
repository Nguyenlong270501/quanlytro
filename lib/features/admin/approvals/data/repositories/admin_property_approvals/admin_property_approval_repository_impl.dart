import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../../../../landlord/create_property/data/models/property_model.dart';
import '../../datasources/admin_property_approvals/admin_property_approval_data_source.dart';
import '../../models/landlord_summary.dart';
import 'admin_property_approval_repository.dart';

class AdminPropertyApprovalRepositoryImpl
    implements AdminPropertyApprovalRepository {
  AdminPropertyApprovalRepositoryImpl(this._dataSource);

  final AdminPropertyApprovalDataSource _dataSource;

  @override
  Stream<List<PropertyModel>> watchVisiblePropertiesForAdmin() {
    return _dataSource.watchVisiblePropertiesForAdmin();
  }

  @override
  Future<Either<String, List<PropertyModel>>> getRecentPropertiesForAdmin({
    int limit = 5,
  }) async {
    try {
      final list = await _dataSource.fetchRecentPropertiesForAdmin(limit: limit);
      return Right(list);
    } on FirebaseException catch (e) {
      return Left(_mapFirebaseError(e));
    } on Exception {
      return const Left('Có lỗi xảy ra khi tải bài đăng gần đây.');
    }
  }

  @override
  Future<Either<String, PropertyModel?>> getPropertyWithRooms(
    String propertyId,
  ) async {
    try {
      final model = await _dataSource.fetchPropertyWithRooms(propertyId);
      return Right(model);
    } on FirebaseException catch (e) {
      return Left(_mapFirebaseError(e));
    } on Exception {
      return const Left('Có lỗi xảy ra khi tải chi tiết bài đăng.');
    }
  }

  @override
  Future<Either<String, Map<String, LandlordSummary>>> getLandlordSummaries(
    Set<String> userIds,
  ) async {
    try {
      final map = await _dataSource.fetchLandlordSummaries(userIds);
      return Right(map);
    } on FirebaseException catch (e) {
      return Left(_mapFirebaseError(e));
    } on Exception {
      return const Left('Có lỗi xảy ra khi tải thông tin chủ trọ.');
    }
  }

  @override
  Future<Either<String, void>> approveProperty(String propertyId) async {
    try {
      await _dataSource.approveProperty(propertyId);
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(_mapFirebaseError(e));
    } on Exception {
      return const Left('Có lỗi xảy ra! Vui lòng thử lại.');
    }
  }

  @override
  Future<Either<String, void>> rejectProperty(
    String propertyId,
    String reason,
  ) async {
    try {
      await _dataSource.rejectProperty(propertyId, reason);
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(_mapFirebaseError(e));
    } on Exception {
      return const Left('Có lỗi xảy ra! Vui lòng thử lại.');
    }
  }

  @override
  Future<Either<String, void>> approvePendingUpdate({
    required String propertyId,
    required String reviewedBy,
  }) async {
    try {
      await _dataSource.approvePendingUpdate(
        propertyId: propertyId,
        reviewedBy: reviewedBy,
      );
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(_mapFirebaseError(e));
    } on Exception {
      return const Left('Có lỗi xảy ra! Vui lòng thử lại.');
    }
  }

  @override
  Future<Either<String, void>> rejectPendingUpdate({
    required String propertyId,
    required String reviewedBy,
    required String reason,
  }) async {
    try {
      await _dataSource.rejectPendingUpdate(
        propertyId: propertyId,
        reviewedBy: reviewedBy,
        reason: reason,
      );
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(_mapFirebaseError(e));
    } on Exception {
      return const Left('Có lỗi xảy ra! Vui lòng thử lại.');
    }
  }

  String _mapFirebaseError(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return 'Bạn không có quyền truy cập dữ liệu này';
      case 'unavailable':
        return 'Dịch vụ tạm thời không khả dụng. Vui lòng thử lại.';
      case 'not-found':
        return 'Không tìm thấy bài đăng';
      case 'deadline-exceeded':
        return 'Hết thời gian chờ, kiểm tra kết nối mạng';
      default:
        return e.message ?? 'Có lỗi xảy ra! Vui lòng thử lại.';
    }
  }
}
