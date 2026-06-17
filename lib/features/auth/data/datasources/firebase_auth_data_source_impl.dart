import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/constants/app_enums.dart';
import '../models/user.dart';
import 'firebase_auth_data_source.dart';

class FirebaseAuthDataSourceImpl implements FirebaseAuthDataSource {
  FirebaseAuthDataSourceImpl({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
    FacebookAuth? facebookAuth,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn.instance,
       _facebookAuth = facebookAuth ?? FacebookAuth.instance;

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;
  final FacebookAuth _facebookAuth;

  bool _isGoogleInitialized = false;

  @override
  Future<UserModel> loginWithEmail(String email, String password) async {
    final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = userCredential.user;
    if (user == null) {
      throw FirebaseAuthException(code: 'user-not-found');
    }

    final userDoc = await _getUserData(user.uid);
    if (_isBlockedOrUnauthorized(userDoc)) {
      await _firebaseAuth.signOut();
      _throwAccessDenied(userDoc);
    }

    return userDoc;
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    await _initGoogleSignIn();

    final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();
    final idToken = googleUser.authentication.idToken;

    final authorization = await googleUser.authorizationClient
        .authorizationForScopes(['email', 'profile']);

    final credential = GoogleAuthProvider.credential(
      idToken: idToken,
      accessToken: authorization?.accessToken,
    );

    final userCredential = await _firebaseAuth.signInWithCredential(credential);
    final user = userCredential.user;
    if (user == null) {
      throw FirebaseAuthException(code: 'invalid-credential');
    }

    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    if (!userDoc.exists) {
      try {
        await _googleSignIn.signOut();
        await user.delete();
        throw Exception('user-not-found');
      } catch (e) {
        throw Exception('user-not-found');
      }
    }

    final userData = UserModel.fromMap(userDoc.data()!);
    if (_isBlockedOrUnauthorized(userData)) {
      await _firebaseAuth.signOut();
      await _googleSignIn.signOut();

      _throwAccessDenied(userData);
    }

    return userData;
  }

  @override
  Future<UserModel> signInWithFacebook() async {
    final loginResult = await _facebookAuth.login();
    if (loginResult.status == LoginStatus.cancelled) {
      throw Exception('facebook-cancelled');
    }
    if (loginResult.status != LoginStatus.success) {
      throw Exception('facebook-failed');
    }

    final token = loginResult.accessToken?.tokenString;
    if (token == null || token.isEmpty) {
      throw FirebaseAuthException(code: 'invalid-credential');
    }

    final credential = FacebookAuthProvider.credential(token);
    final userCredential = await _firebaseAuth.signInWithCredential(credential);
    final user = userCredential.user;
    if (user == null) {
      throw FirebaseAuthException(code: 'invalid-credential');
    }

    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    if (!userDoc.exists) {
      try {
        await _facebookAuth.logOut();
        await user.delete();
        throw Exception('user-not-found');
      } catch (e) {
        throw Exception('user-not-found');
      }
    }

    final userData = UserModel.fromMap(userDoc.data()!);
    if (_isBlockedOrUnauthorized(userData)) {
      await _firebaseAuth.signOut();
      await _facebookAuth.logOut();

      _throwAccessDenied(userData);
    }
    return userData;
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) return null;

    try {
      return await _getUserData(firebaseUser.uid);
    } catch (e) {
      return null;
    }
  }

  Future<UserModel> _getUserData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();

    if (!doc.exists || doc.data() == null) {
      throw Exception('user-not-found');
    }

    return UserModel.fromMap(doc.data()!);
  }

  bool _isBlockedOrUnauthorized(UserModel user) {
    return user.status == UserStatus.blocked || user.role == UserRole.tenant;
  }

  Never _throwAccessDenied(UserModel user) {
    if (user.status == UserStatus.blocked) {
      throw Exception('blocked-user');
    }
    throw Exception('unauthorized-role');
  }

  Future<void> _initGoogleSignIn() async {
    if (_isGoogleInitialized) {
      return;
    }

    await _googleSignIn.initialize(
      serverClientId:
          '1012146705116-ov659bo6stbcmdc0fri3vkh7ese7jr2l.apps.googleusercontent.com',
    );
    _isGoogleInitialized = true;
  }

  @override
  Stream<UserModel?> watchCurrentUserData(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    });
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _firebaseAuth.currentUser;
    final email = user?.email;
    if (user == null || email == null || email.trim().isEmpty) {
      throw FirebaseAuthException(code: 'user-not-found');
    }

    final credential = EmailAuthProvider.credential(
      email: email,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }
}
