import 'package:equatable/equatable.dart';

enum ProfileEditStatus { idle, saving, success, error }

class ProfileEditState extends Equatable {
  const ProfileEditState({
    required this.initialName,
    required this.initialPhone,
    required this.name,
    required this.phoneNumber,
    this.status = ProfileEditStatus.idle,
    this.errorMessage,
  });

  final String initialName;
  final String initialPhone;
  final String name;
  final String phoneNumber;
  final ProfileEditStatus status;
  final String? errorMessage;

  bool get hasChanges =>
      name.trim() != initialName.trim() ||
      phoneNumber.trim() != initialPhone.trim();

  bool get canSave => hasChanges && name.trim().isNotEmpty;

  ProfileEditState copyWith({
    String? initialName,
    String? initialPhone,
    String? name,
    String? phoneNumber,
    ProfileEditStatus? status,
    String? errorMessage,
  }) {
    return ProfileEditState(
      initialName: initialName ?? this.initialName,
      initialPhone: initialPhone ?? this.initialPhone,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        initialName,
        initialPhone,
        name,
        phoneNumber,
        status,
        errorMessage,
      ];
}
