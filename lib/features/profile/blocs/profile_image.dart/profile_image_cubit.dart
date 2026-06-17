import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/repositories/profile_image_repository.dart';
import 'profile_image_state.dart';

class ProfileImageCubit extends Cubit<ProfileImageState> {
  ProfileImageCubit(
    this._repository, {
    String initialAvatarUrl = '',
  }) : super(
          ProfileImageState(
            avatarUrl: initialAvatarUrl,
            initialAvatarUrl: initialAvatarUrl,
          ),
        );

  final ProfileImageRepository _repository;

  Future<void> pickAvatar() async {
    try {
      emit(
        state.copyWith(status: ProfileImageStatus.picking, errorMessage: null),
      );
      final picked = await _repository.pickImageFromGallery();
      if (picked == null) {
        emit(state.copyWith(status: ProfileImageStatus.idle));
        return;
      }

      final cachedPath = await _repository.copyImageToCache(picked);
      await _deleteCachedFile(state.localAvatarPath);

      emit(
        state.copyWith(
          status: ProfileImageStatus.idle,
          localAvatarPath: cachedPath,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ProfileImageStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<bool> uploadPendingAvatar() async {
    final path = state.localAvatarPath;
    if (path == null || path.trim().isEmpty) {
      return true;
    }

    emit(
      state.copyWith(
        status: ProfileImageStatus.uploading,
        errorMessage: null,
      ),
    );

    try {
      final newAvatarUrl = await _repository.uploadAvatarAndSaveUrl(
        XFile(path),
      );
      await _deleteCachedFile(path);

      emit(
        state.copyWith(
          status: ProfileImageStatus.success,
          avatarUrl: newAvatarUrl,
          initialAvatarUrl: newAvatarUrl,
          clearLocalAvatarPath: true,
          errorMessage: null,
        ),
      );
      return true;
    } catch (e) {
      emit(
        state.copyWith(
          status: ProfileImageStatus.error,
          errorMessage: e.toString(),
        ),
      );
      return false;
    }
  }

  Future<void> _deleteCachedFile(String? path) async {
    if (path == null || path.trim().isEmpty) {
      return;
    }
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }

  void clearStatus() {
    emit(state.copyWith(status: ProfileImageStatus.idle, errorMessage: null));
  }
}
