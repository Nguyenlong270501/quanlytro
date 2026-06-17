import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/landlord_request/landlord_request_repository.dart';
import 'landlord_request_detail_state.dart';

class LandlordRequestDetailCubit extends Cubit<LandlordRequestDetailState> {
  LandlordRequestDetailCubit({required LandlordRequestRepository repository})
    : _repo = repository,
      super(const LandlordRequestDetailState());

  final LandlordRequestRepository _repo;

  Future<void> approve(String userId) => _run(
    action: DetailAction.approve,
    task: () => _repo.approve(userId),
  );

  Future<void> reject(String userId, String reason) => _run(
    action: DetailAction.reject,
    task: () => _repo.reject(userId, reason),
  );

  Future<void> _run({
    required DetailAction action,
    required Future<Either<String, void>> Function() task,
  }) async {
    if (state.isSubmitting) return;
    emit(
      state.copyWith(
        status: DetailSubmitStatus.submitting,
        action: action,
        clearError: true,
      ),
    );
    final res = await task();
    res.fold(
      (msg) => emit(
        state.copyWith(
          status: DetailSubmitStatus.failure,
          errorMessage: msg,
        ),
      ),
      (_) => emit(state.copyWith(status: DetailSubmitStatus.success)),
    );
  }
}
