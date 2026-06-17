import 'package:equatable/equatable.dart';

import '../../../../../core/constants/app_enums.dart';
import '../../../../auth/data/models/user.dart';

final class AdminUserDetailState extends Equatable {
  const AdminUserDetailState({
    required this.user,
    required this.selectedStatus,
    this.isSaving = false,
    this.isResettingPassword = false,
    this.successMessage,
    this.errorMessage,
  });

  factory AdminUserDetailState.initial(UserModel user) {
    return AdminUserDetailState(
      user: user,
      selectedStatus: user.status,
    );
  }

  final UserModel user;
  final UserStatus selectedStatus;
  final bool isSaving;
  final bool isResettingPassword;
  final String? successMessage;
  final String? errorMessage;

  bool get hasChanges => selectedStatus != user.status;

  bool get isBusy => isSaving || isResettingPassword;

  AdminUserDetailState copyWith({
    UserModel? user,
    UserStatus? selectedStatus,
    bool? isSaving,
    bool? isResettingPassword,
    String? successMessage,
    String? errorMessage,
    bool clearSuccess = false,
    bool clearError = false,
  }) {
    return AdminUserDetailState(
      user: user ?? this.user,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      isSaving: isSaving ?? this.isSaving,
      isResettingPassword: isResettingPassword ?? this.isResettingPassword,
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    user,
    selectedStatus,
    isSaving,
    isResettingPassword,
    successMessage,
    errorMessage,
  ];
}
