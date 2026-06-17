import '../models/user.dart'; 

abstract class FirebaseAuthDataSource {
  Future<UserModel> loginWithEmail(String email, String password);
  Future<UserModel> signInWithGoogle();
  Future<UserModel> signInWithFacebook();
  Future<void> signOut();
  Future<void> sendPasswordResetEmail(String email);
  Future<UserModel?> getCurrentUser();
  Stream<UserModel?> watchCurrentUserData(String uid);
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}