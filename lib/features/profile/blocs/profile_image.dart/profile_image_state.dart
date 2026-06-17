import 'package:equatable/equatable.dart';

enum ProfileImageStatus { idle, picking, uploading, success, error }

class ProfileImageState extends Equatable {
  const ProfileImageState({
    this.status = ProfileImageStatus.idle,
    this.avatarUrl = '',
    this.initialAvatarUrl = '',
    this.localAvatarPath,
    this.errorMessage,
  });

  final ProfileImageStatus status;
  final String avatarUrl;
  final String initialAvatarUrl;
  final String? localAvatarPath;
  final String? errorMessage;

  bool get hasPendingAvatar =>
      localAvatarPath != null && localAvatarPath!.trim().isNotEmpty;

  ProfileImageState copyWith({
    ProfileImageStatus? status,
    String? avatarUrl,
    String? initialAvatarUrl,
    String? localAvatarPath,
    bool clearLocalAvatarPath = false,
    String? errorMessage,
  }) {
    return ProfileImageState(
      status: status ?? this.status,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      initialAvatarUrl: initialAvatarUrl ?? this.initialAvatarUrl,
      localAvatarPath: clearLocalAvatarPath
          ? null
          : (localAvatarPath ?? this.localAvatarPath),
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        avatarUrl,
        initialAvatarUrl,
        localAvatarPath,
        errorMessage,
      ];
}
