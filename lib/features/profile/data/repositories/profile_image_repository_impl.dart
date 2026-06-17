import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../../core/services/image_picker_service.dart';
import '../../../../core/services/storage_services.dart';
import 'profile_image_repository.dart';

class ProfileImageRepositoryImpl implements ProfileImageRepository {
  ProfileImageRepositoryImpl({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    ImagePickerService? imagePickerService,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _imagePickerService = imagePickerService ?? ImagePickerService();

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final ImagePickerService _imagePickerService;

  @override
  Future<XFile?> pickImageFromGallery() {
    return _imagePickerService.pickImageFromGallery();
  }

  @override
  Future<String> copyImageToCache(XFile imageFile) async {
    final cacheDir = await getTemporaryDirectory();
    final ext = p.extension(imageFile.path);
    final safeExt = ext.isEmpty ? '.jpg' : ext;
    final fileName =
        'avatar_pending_${DateTime.now().millisecondsSinceEpoch}$safeExt';
    final destPath = p.join(cacheDir.path, fileName);
    await File(imageFile.path).copy(destPath);
    return destPath;
  }

  @override
  Future<String> uploadAvatarAndSaveUrl(XFile imageFile) async {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) {
      throw Exception('Bạn chưa đăng nhập');
    }

    final uid = currentUser.uid;

    final userDoc = await _firestore.collection('users').doc(uid).get();
    final oldAvatarUrl = userDoc.data()?['avatarUrl'] as String?;

    final newAvatarUrl = await StorageServices.uploadSingleImage(
      File(imageFile.path),
      'users/avatars/$uid',
    );

    if (newAvatarUrl == null) {
      throw Exception('Không thể upload ảnh, vui lòng thử lại!');
    }

    await _firestore.collection('users').doc(uid).update({
      'avatarUrl': newAvatarUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    if (oldAvatarUrl != null && oldAvatarUrl.isNotEmpty) {
      await StorageServices.deleteDownloadUrlIfFirebaseStorage(oldAvatarUrl);
    }

    return newAvatarUrl;
  }

  @override
  Future<void> updateProfileInfo({
    required String userName,
    required String phoneNumber,
  }) async {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) {
      throw Exception('Bạn chưa đăng nhập');
    }

    await _firestore.collection('users').doc(currentUser.uid).update({
      'userName': userName.trim(),
      'phoneNumber': phoneNumber.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
