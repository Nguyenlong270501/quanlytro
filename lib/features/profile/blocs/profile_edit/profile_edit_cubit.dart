import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/profile_image_repository.dart';
import 'profile_edit_state.dart';

class ProfileEditCubit extends Cubit<ProfileEditState> {
  ProfileEditCubit({
    required String initialName,
    required String initialPhone,
    required ProfileImageRepository repository,
  }) : _repository = repository,
       super(
         ProfileEditState(
           initialName: initialName,
           initialPhone: initialPhone,
           name: initialName,
           phoneNumber: initialPhone,
         ),
       );

  final ProfileImageRepository _repository;

  void nameChanged(String value) {
    emit(
      state.copyWith(
        name: value,
        status: ProfileEditStatus.idle,
        errorMessage: null,
      ),
    );
  }

  void phoneChanged(String value) {
    emit(
      state.copyWith(
        phoneNumber: value,
        status: ProfileEditStatus.idle,
        errorMessage: null,
      ),
    );
  }

  Future<void> saveProfile() async {
    if (!state.canSave || state.status == ProfileEditStatus.saving) {
      return;
    }

    emit(state.copyWith(status: ProfileEditStatus.saving, errorMessage: null));
    try {
      await _repository.updateProfileInfo(
        userName: state.name,
        phoneNumber: state.phoneNumber,
      );
      emit(
        state.copyWith(
          initialName: state.name,
          initialPhone: state.phoneNumber,
          status: ProfileEditStatus.success,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ProfileEditStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void clearStatus() {
    emit(state.copyWith(status: ProfileEditStatus.idle, errorMessage: null));
  }
}
