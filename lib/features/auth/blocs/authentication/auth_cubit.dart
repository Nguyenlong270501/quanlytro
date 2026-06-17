import 'dart:async';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/fcm_service.dart';
import '../../data/models/user.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthenticationCubit extends Cubit<AuthenticationState> {
  AuthenticationCubit({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(AuthenticationInitial());

  final AuthRepository _authRepository;
  StreamSubscription<UserModel?>? _userSubscription;

  void _listenToUser(String userId) {
    _userSubscription?.cancel();
    _userSubscription = _authRepository
        .watchCurrentUserData(userId)
        .listen(
          (user) {
            if (user != null) {
              emit(AuthenticationSuccessState(user));
              return;
            }
            if (FirebaseAuth.instance.currentUser == null) {
              emit(UnAuthenticationState());
            }
          },
          onError: (error) {
            log('Lỗi khi lắng nghe user data: $error');
            emit(UnAuthenticationState());
          },
        );
  }

  UserModel? get currentUser {
    if (state is AuthenticationSuccessState) {
      return (state as AuthenticationSuccessState).user;
    }
    return null;
  }

  Future<void> checkAuthStatus() async {
    try {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        emit(AuthenticationSuccessState(user));
        _listenToUser(_effectiveUserId(user));
      } else {
        emit(UnAuthenticationState());
      }
    } catch (e) {
      log('Lỗi checkAuthStatus: $e');
      emit(UnAuthenticationState());
    }
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }

  Future<void> signInWithEmail(String email, String password) async {
    try {
      emit(AuthenticationLoadingState());
      final result = await _authRepository.loginWithEmail(email, password);
      result.fold((failure) => emit(AuthenticationErrorState(failure)), (user) {
        emit(AuthenticationSuccessState(user));
        _requestNotificationPermission(user);
        _listenToUser(_effectiveUserId(user));
      });
    } catch (e) {
      emit(AuthenticationErrorState(e.toString()));
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      emit(AuthenticationLoadingState());
      final result = await _authRepository.signInWithGoogle();
      result.fold((error) => emit(AuthenticationErrorState(error)), (user) {
        emit(AuthenticationSuccessState(user));
        _requestNotificationPermission(user);
        _listenToUser(_effectiveUserId(user));
      });
    } catch (e) {
      emit(AuthenticationErrorState(e.toString()));
    }
  }

  Future<void> signInWithFacebook() async {
    try {
      emit(AuthenticationLoadingState());
      final result = await _authRepository.signInWithFacebook();
      result.fold((error) => emit(AuthenticationErrorState(error)), (user) {
        emit(AuthenticationSuccessState(user));
        _requestNotificationPermission(user);
        _listenToUser(_effectiveUserId(user));
      });
    } catch (e) {
      emit(AuthenticationErrorState(e.toString()));
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      emit(AuthenticationLoadingState());
      final result = await _authRepository.sendPasswordResetEmail(email);
      result.fold(
        (error) => emit(AuthenticationErrorState(error)),
        (_) => emit(
          PasswordResetEmailSentState(
            'Đã gửi email đặt lại mật khẩu. Vui lòng kiểm tra hộp thư của bạn.',
          ),
        ),
      );
    } catch (e) {
      emit(AuthenticationErrorState(e.toString()));
    }
  }

  String _effectiveUserId(UserModel user) {
    final fromModel = user.userId.trim();
    if (fromModel.isNotEmpty) {
      return fromModel;
    }
    return FirebaseAuth.instance.currentUser?.uid ?? fromModel;
  }

  void _requestNotificationPermission(UserModel user) {
    final userId = _effectiveUserId(user);
    if (userId.trim().isEmpty) {
      return;
    }

    unawaited(
      FCMService().requestNotificationPermission(uid: userId).catchError((
        Object error,
        StackTrace stackTrace,
      ) {
        log(
          '⚠️ Notification permission request failed after sign in',
          error: error,
          stackTrace: stackTrace,
        );
      }),
    );
  }

  String? _resolveUserIdForSignOut(UserModel? user) {
    if (user != null) {
      final id = _effectiveUserId(user).trim();
      if (id.isNotEmpty) {
        return id;
      }
    }
    return FirebaseAuth.instance.currentUser?.uid;
  }

  Future<void> signout() async {
    final userBeforeSignOut = currentUser;
    final userId = _resolveUserIdForSignOut(userBeforeSignOut);

    emit(AuthenticationLoadingState());

    try {
      await _userSubscription?.cancel();
      _userSubscription = null;

      if (userId != null && userId.isNotEmpty) {
        try {
          await FCMService().clearUserFcmTokensOnFirestore(userId);
        } catch (e) {
          log('⚠️ Clear FCM tokens on Firestore failed, continue signout: $e');
        }
      }

      await _authRepository.signOut();
      emit(UnAuthenticationState());
    } catch (e) {
      emit(AuthenticationErrorState(e.toString()));
    } finally {
      try {
        await FCMService().deleteLocalMessagingToken();
      } catch (e) {
        log('⚠️ deleteLocalMessagingToken failed, ignored: $e');
      }
    }
  }
}
