import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'auth_repository.dart';
import '../datasources/firebase_auth_data_source.dart';
import '../models/user.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remoteDataSource);

  final FirebaseAuthDataSource _remoteDataSource;

  @override
  Future<Either<String, UserModel>> loginWithEmail(
    String email,
    String password,
  ) async {
    try {
      final user = await _remoteDataSource.loginWithEmail(email, password);
      return Right(user);
    } on FirebaseAuthException catch (e) {
      return Left(_mapFirebaseError(e, fallback: 'Lỗi đăng nhập'));
    } on Exception catch (e) {
      return Left(_authError(e));
    }
  }

  @override
  Future<Either<String, UserModel>> signInWithGoogle() async {
    try {
      final user = await _remoteDataSource.signInWithGoogle();
      return Right(user);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return const Left('Google login cancelled');
      }
      return const Left('Đăng nhập Google thất bại');
    } on FirebaseAuthException catch (e) {
      return Left(_mapFirebaseError(e, fallback: 'Đăng nhập Google thất bại'));
    } on Exception catch (e) {
      return Left(_authError(e));
    }
  }

  @override
  Future<Either<String, UserModel>> signInWithFacebook() async {
    try {
      final user = await _remoteDataSource.signInWithFacebook();
      return Right(user);
    } on FirebaseAuthException catch (e) {
      return Left(
        _mapFirebaseError(e, fallback: 'Đăng nhập Facebook thất bại'),
      );
    } on Exception catch (e) {
      return Left(_authError(e));
    }
  }

  @override
  Future<Either<String, void>> sendPasswordResetEmail(String email) async {
    try {
      await _remoteDataSource.sendPasswordResetEmail(email);
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(
        _mapFirebaseError(e, fallback: 'Không thể gửi email đặt lại mật khẩu'),
      );
    } on Exception catch (e) {
      return Left(_authError(e));
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    return await _remoteDataSource.getCurrentUser();
  }

  @override
  Future<void> signOut() {
    return _remoteDataSource.signOut();
  }

  String _mapFirebaseError(
    FirebaseAuthException e, {
    required String fallback,
  }) {
    switch (e.code) {
      case 'user-not-found':
        return 'Tài khoản không tồn tại';
      case 'wrong-password':
        return 'Sai mật khẩu';
      case 'invalid-email':
        return 'Địa chỉ email không hợp lệ';
      case 'user-disabled':
        return 'Tài khoản này đã bị vô hiệu hóa';
      case 'too-many-requests':
        return 'Quá nhiều lần thử. Vui lòng thử lại sau';
      case 'email-already-in-use':
        return 'Email đã được đăng ký';
      case 'operation-not-allowed':
        return 'Phương thức đăng nhập không được bật';
      case 'weak-password':
        return 'Mật khẩu quá yếu';
      case 'account-exists-with-different-credential':
        return 'Tài khoản đã được đăng ký bằng phương thức khác';
      case 'invalid-credential':
        return 'Thông tin đăng nhập không hợp lệ hoặc đã hết hạn';
      default:
        return e.message ?? fallback;
    }
  }

  String _authError(Exception e) {
    if (e.toString().contains('facebook-cancelled')) {
      return 'Đăng nhập bị hủy';
    }
    if (e.toString().contains('blocked-user')) {
      return 'Tài khoản của bạn đã bị khóa. Vui lòng liên hệ quản trị viên.';
    }
    if (e.toString().contains('unauthorized-role') ||
        e.toString().contains('user-not-found')) {
      return 'Tài khoản chưa được cấp quyền Chủ trọ. Vui lòng đăng ký trên ứng dụng Trọ Tốt.';
    }
    return 'Đăng nhập thất bại';
  }

@override
  Stream<UserModel?> watchCurrentUserData(String userId) {
    return _remoteDataSource.watchCurrentUserData(userId);
  }


  @override
  Future<Either<String, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _remoteDataSource.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(
        _mapFirebaseError(e, fallback: 'Không thể đổi mật khẩu'),
      );
    } on Exception catch (e) {
      return Left(_authError(e));
    }
  }
}
