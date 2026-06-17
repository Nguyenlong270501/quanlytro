import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../datasources/landlord_request/landlord_request_data_source.dart';
import '../../models/landlord_request.dart';
import 'landlord_request_repository.dart';

class LandlordRequestRepositoryImpl implements LandlordRequestRepository {
  LandlordRequestRepositoryImpl(this._dataSource);

  final LandlordRequestDataSource _dataSource;

  @override
  Future<Either<String, List<LandlordRequest>>> fetchAll() async {
    try {
      final result = await _dataSource.fetchAll();
      return Right(result);
    } on FirebaseException catch (e) {
      return Left(_mapFirebaseError(e));
    } on Exception {
      return const Left('Có lỗi xảy ra! Vui lòng thử lại.');
    }
  }

  @override
  Future<Either<String, List<LandlordRequest>>> fetchByStatus(
    LandlordRequestStatus status,
  ) async {
    try {
      final result = await _dataSource.fetchByStatus(status);
      return Right(result);
    } on FirebaseException catch (e) {
      return Left(_mapFirebaseError(e));
    } on Exception {
      return const Left('Có lỗi xảy ra! Vui lòng thử lại.');
    }
  }

  @override
  Future<Either<String, LandlordRequest>> getByUserId(String userId) async {
    try {
      final result = await _dataSource.getByUserId(userId);
      if (result == null) {
        return const Left('Không tìm thấy hồ sơ');
      }
      return Right(result);
    } on FirebaseException catch (e) {
      return Left(_mapFirebaseError(e));
    } on Exception {
      return const Left('Có lỗi xảy ra! Vui lòng thử lại.');
    }
  }

  @override
  Stream<Either<String, LandlordRequest?>> watchMyLandlordRequest(
    String userId,
  ) {
    return _dataSource.watchDocument(userId).transform(
      StreamTransformer<LandlordRequest?,
          Either<String, LandlordRequest?>>.fromHandlers(
        handleData: (data, sink) => sink.add(Right(data)),
        handleError: (e, st, sink) {
          if (e is FirebaseException) {
            sink.add(Left(_mapFirebaseError(e)));
          } else {
            sink.add(Left(e.toString()));
          }
        },
      ),
    );
  }

  @override
  Stream<Either<String, List<LandlordRequest>>> watchAll() async* {
    try {
      yield* _dataSource.watchAll().map(
        (list) => Right<String, List<LandlordRequest>>(list),
      );
    } on FirebaseException catch (e) {
      yield Left(_mapFirebaseError(e));
    } catch (_) {
      yield const Left('Có lỗi xảy ra! Vui lòng thử lại.');
    }
  }

  @override
  Stream<Either<String, List<LandlordRequest>>> watchByStatus(
    LandlordRequestStatus status,
  ) async* {
    try {
      yield* _dataSource.watchByStatus(status).map(
        (list) => Right<String, List<LandlordRequest>>(list),
      );
    } on FirebaseException catch (e) {
      yield Left(_mapFirebaseError(e));
    } catch (_) {
      yield const Left('Có lỗi xảy ra! Vui lòng thử lại.');
    }
  }

  @override
  Future<Either<String, void>> approve(String userId) async {
    try {
      await _dataSource.approve(userId);
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(_mapFirebaseError(e));
    } on Exception {
      return const Left('Có lỗi xảy ra! Vui lòng thử lại.');
    }
  }

  @override
  Future<Either<String, void>> reject(String userId, String reason) async {
    try {
      await _dataSource.reject(userId, reason);
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
        return 'Không tìm thấy hồ sơ';
      case 'deadline-exceeded':
        return 'Hết thời gian chờ, kiểm tra kết nối mạng';
      case 'cancelled':
        return 'Thao tác đã bị huỷ';
      default:
        return e.message ?? 'Có lỗi xảy ra! Vui lòng thử lại.';
    }
  }
}
