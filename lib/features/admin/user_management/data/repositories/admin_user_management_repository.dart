import 'package:dartz/dartz.dart';

import '../../../../../core/constants/app_enums.dart';
import '../../../../auth/data/models/user.dart';

abstract class AdminUserManagementRepository {
  Stream<Either<String, List<UserModel>>> watchUsersByRole({
    required UserRole role,
  });

  Future<Either<String, UserModel>> updateUserAccess({
    required UserModel user,
    required UserRole role,
    required UserStatus status,
  });

  Future<Either<String, void>> resetUserPasswordToDefault(UserModel user);
}
