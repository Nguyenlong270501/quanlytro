import '../../../../landlord/create_property/data/models/property_model.dart';
import '../../data/models/landlord_summary.dart';

enum AdminPropertySubmitPhase {
  idle,
  approving,
  rejecting,
}

enum LandlordProfileStatus { initial, loading, loaded, failure }

class AdminPropertyDetailState {
  const AdminPropertyDetailState({
    required this.property,
    this.isRoomsLoading = false,
    this.submitPhase = AdminPropertySubmitPhase.idle,
    this.landlordProfileStatus = LandlordProfileStatus.initial,
    this.displayLandlord,
    this.landlordProfileError,
    this.errorMessage,
    this.successMessage,
  });

  final PropertyModel property;
  final bool isRoomsLoading;

  final AdminPropertySubmitPhase submitPhase;
  final LandlordProfileStatus landlordProfileStatus;
  final LandlordSummary? displayLandlord;
  final String? landlordProfileError;
  final String? errorMessage;
  final String? successMessage;

  bool get isSubmitting => submitPhase != AdminPropertySubmitPhase.idle;

  bool get isApproving => submitPhase == AdminPropertySubmitPhase.approving;

  bool get isRejecting => submitPhase == AdminPropertySubmitPhase.rejecting;

  AdminPropertyDetailState copyWith({
    PropertyModel? property,
    bool? isRoomsLoading,
    AdminPropertySubmitPhase? submitPhase,
    LandlordProfileStatus? landlordProfileStatus,
    LandlordSummary? displayLandlord,
    bool clearDisplayLandlord = false,
    String? landlordProfileError,
    bool clearLandlordProfileError = false,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return AdminPropertyDetailState(
      property: property ?? this.property,
      isRoomsLoading: isRoomsLoading ?? this.isRoomsLoading,
      submitPhase: submitPhase ?? this.submitPhase,
      landlordProfileStatus: landlordProfileStatus ?? this.landlordProfileStatus,
      displayLandlord: clearDisplayLandlord
          ? null
          : (displayLandlord ?? this.displayLandlord),
      landlordProfileError: clearLandlordProfileError
          ? null
          : (landlordProfileError ?? this.landlordProfileError),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }
}
