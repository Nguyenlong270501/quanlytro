import '../../../../../core/constants/app_enums.dart';
import '../../../../auth/data/models/user.dart';

abstract class AdminUserManagementRemoteDataSource {
  Stream<List<UserModel>> watchUsersByRole({required UserRole role});

  Future<void> updateUserAccess({
    required String userId,
    required UserRole role,
    required UserStatus status,
  });

  Future<void> resetUserPasswordToDefault({
    required String userId,
    required String email,
  });
}
