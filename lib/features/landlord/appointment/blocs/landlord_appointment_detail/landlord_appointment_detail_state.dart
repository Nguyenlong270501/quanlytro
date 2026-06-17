import 'package:equatable/equatable.dart';

import '../../data/models/appointment_model.dart';

final class LandlordAppointmentDetailState extends Equatable {
  const LandlordAppointmentDetailState({
    required this.appointment,
    this.isSubmitting = false,
    this.errorMessage,
    this.successMessage,
  });

  final AppointmentModel appointment;
  final bool isSubmitting;
  final String? errorMessage;
  final String? successMessage;

  LandlordAppointmentDetailState copyWith({
    AppointmentModel? appointment,
    bool? isSubmitting,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccessMessage = false,
  }) {
    return LandlordAppointmentDetailState(
      appointment: appointment ?? this.appointment,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccessMessage
          ? null
          : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
    appointment,
    isSubmitting,
    errorMessage,
    successMessage,
  ];
}
