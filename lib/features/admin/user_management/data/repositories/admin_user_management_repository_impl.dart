import 'dart:developer';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:dartz/dartz.dart';

import '../../../../../core/constants/app_enums.dart';
import '../../../../auth/data/models/user.dart';
import '../datasources/admin_user_management_remote_data_source.dart';
import 'admin_user_management_repository.dart';

class AdminUserManagementRepositoryImpl implements AdminUserManagementRepository {
  AdminUserManagementRepositoryImpl(this._remoteDataSource);

  final AdminUserManagementRemoteDataSource _remoteDataSource;

  @override
  Stream<Either<String, List<UserModel>>> watchUsersByRole({
    required UserRole role,
  }) async* {
    try {
      await for (final users in _remoteDataSource.watchUsersByRole(
        role: role,
      )) {
        yield Right(users);
      }
    } catch (e, stackTrace) {
      log(
        'AdminUserManagementRepository.watchUsersByRole failed',
        error: e,
        stackTrace: stackTrace,
      );
      yield Left(_errorMessage(e));
    }
  }

  @override
  Future<Either<String, UserModel>> updateUserAccess({
    required UserModel user,
    required UserRole role,
    required UserStatus status,
  }) async {
    try {
      await _remoteDataSource.updateUserAccess(
        userId: user.userId,
        role: role,
        status: status,
      );
      return Right(
        user.copyWith(
          role: role,
          status: status,
          updatedAt: DateTime.now(),
        ),
      );
    } catch (e, stackTrace) {
      log(
        'AdminUserManagementRepository.updateUserAccess failed',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(_errorMessage(e));
    }
  }

  @override
  Future<Either<String, void>> resetUserPasswordToDefault(
    UserModel user,
  ) async {
    try {
      await _remoteDataSource.resetUserPasswordToDefault(
        userId: user.userId,
        email: user.email,
      );
      return const Right(null);
    } catch (e, stackTrace) {
      log(
        'AdminUserManagementRepository.resetUserPasswordToDefault failed',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(_errorMessage(e));
    }
  }

  String _errorMessage(Object error) {
    if (error is FirebaseFunctionsException) {
      final message = error.message?.trim() ?? '';
      if (message.isNotEmpty) {
        return message;
      }
      return switch (error.code) {
        'unauthenticated' => 'Bạn cần đăng nhập để thực hiện thao tác này',
        'permission-denied' => 'Chỉ quản trị viên mới được reset mật khẩu',
        'not-found' => 'Không tìm thấy tài khoản',
        'invalid-argument' => 'Thiếu thông tin người dùng',
        _ => 'Không thể thực hiện thao tác',
      };
    }
    final message = error.toString().replaceFirst('Exception: ', '').trim();
    if (message.isEmpty) {
      return 'Không thể tải danh sách người dùng';
    }
    return message;
  }
}
