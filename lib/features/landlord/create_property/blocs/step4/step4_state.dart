import 'package:equatable/equatable.dart';

enum SubmitStatus { initial, submitting, success, failure }

class Step4State extends Equatable {
  const Step4State({
    this.status = SubmitStatus.initial,
    this.errorMessage,
  });

  final SubmitStatus status;
  final String? errorMessage;

  bool get isSubmitting => status == SubmitStatus.submitting;
  bool get isSuccess => status == SubmitStatus.success;

  Step4State copyWith({
    SubmitStatus? status,
    String? Function()? errorMessage,
  }) {
    return Step4State(
      status: status ?? this.status,
      errorMessage:
          errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage];
}
