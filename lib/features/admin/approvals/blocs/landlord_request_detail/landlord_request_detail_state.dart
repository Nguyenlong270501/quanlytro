import 'package:equatable/equatable.dart';

enum DetailSubmitStatus { idle, submitting, success, failure }

enum DetailAction { approve, reject }

class LandlordRequestDetailState extends Equatable {
  const LandlordRequestDetailState({
    this.status = DetailSubmitStatus.idle,
    this.action,
    this.errorMessage,
  });

  final DetailSubmitStatus status;
  final DetailAction? action;
  final String? errorMessage;

  bool get isSubmitting => status == DetailSubmitStatus.submitting;

  LandlordRequestDetailState copyWith({
    DetailSubmitStatus? status,
    DetailAction? action,
    String? errorMessage,
    bool clearError = false,
  }) {
    return LandlordRequestDetailState(
      status: status ?? this.status,
      action: action ?? this.action,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, action, errorMessage];
}
