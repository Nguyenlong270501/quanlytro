import 'dart:async';

import 'package:dartz/dartz.dart' hide State;
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../admin/approvals/data/models/landlord_request.dart';
import '../../../admin/approvals/data/repositories/landlord_request/landlord_request_repository_impl.dart';
import 'landlord_request_view_state.dart';

class LandlordRequestViewCubit extends Cubit<LandlordRequestViewState> {
  LandlordRequestViewCubit({
    required LandlordRequestRepositoryImpl repository,
    required String userId,
  }) : super(const LandlordRequestViewLoading()) {
    _subscription = repository.watchMyLandlordRequest(userId).listen(_onResult);
  }

  StreamSubscription<Either<String, LandlordRequest?>>? _subscription;

  void _onResult(Either<String, LandlordRequest?> result) {
    result.fold(
      (message) => emit(LandlordRequestViewError(message)),
      (request) {
        if (request == null) {
          emit(const LandlordRequestViewEmpty());
        } else {
          emit(LandlordRequestViewLoaded(request));
        }
      },
    );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return await super.close();
  }
}
