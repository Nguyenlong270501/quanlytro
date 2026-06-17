import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/landlord_request.dart';
import '../../data/repositories/landlord_request/landlord_request_repository.dart';
import 'landlord_requests_state.dart';

class LandlordRequestsCubit extends Cubit<LandlordRequestsState> {
  LandlordRequestsCubit({required LandlordRequestRepository repository})
    : _repository = repository,
      super(const LandlordRequestsState());

  final LandlordRequestRepository _repository;
  StreamSubscription<Either<String, List<LandlordRequest>>>? _subscription;

  void subscribe() {
    if (_subscription != null) {
      return;
    }
    _subscribe(isInitialLoad: true);
  }

  Future<Either<String, void>> approve(String userId) {
    return _repository.approve(userId);
  }

  Future<Either<String, void>> reject(String userId, String reason) {
    return _repository.reject(userId, reason);
  }

  void _subscribe({bool isInitialLoad = false}) {
    if (isInitialLoad) {
      emit(
        state.copyWith(
          status: LandlordRequestsStatus.loading,
          clearError: true,
        ),
      );
    }
    _subscription?.cancel();
    _subscription = _repository.watchAll().listen(_onData);
  }

  void _onData(Either<String, List<LandlordRequest>> result) {
    result.fold(
      (message) => emit(
        state.copyWith(
          status: LandlordRequestsStatus.failure,
          errorMessage: message,
        ),
      ),
      (list) => emit(
        state.copyWith(
          status: LandlordRequestsStatus.loaded,
          items: list,
          clearError: true,
        ),
      ),
    );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    _subscription = null;
    return super.close();
  }
}
