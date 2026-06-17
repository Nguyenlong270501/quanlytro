import 'package:equatable/equatable.dart';

import '../../../admin/approvals/data/models/landlord_request.dart';

sealed class LandlordRequestViewState extends Equatable {
  const LandlordRequestViewState();

  @override
  List<Object?> get props => [];
}

class LandlordRequestViewLoading extends LandlordRequestViewState {
  const LandlordRequestViewLoading();
}

class LandlordRequestViewEmpty extends LandlordRequestViewState {
  const LandlordRequestViewEmpty();
}

class LandlordRequestViewLoaded extends LandlordRequestViewState {
  const LandlordRequestViewLoaded(this.request);

  final LandlordRequest request;

  @override
  List<Object?> get props => [request];
}

class LandlordRequestViewError extends LandlordRequestViewState {
  const LandlordRequestViewError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
