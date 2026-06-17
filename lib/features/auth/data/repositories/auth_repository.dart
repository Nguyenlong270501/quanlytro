import 'package:dartz/dartz.dart';

import '../models/user.dart';

abstract class AuthRepository {
  Future<Either<String, UserModel>> loginWithEmail(
    String email,
    String password,
  );


  Future<Either<String, UserModel>> signInWithGoogle();

  Future<Either<String, UserModel>> signInWithFacebook();

  Future<Either<String, void>> sendPasswordResetEmail(String email);

  Future<UserModel?> getCurrentUser();

  Stream<UserModel?> watchCurrentUserData(String userId);

  Future<void> signOut();

  Future<Either<String, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}