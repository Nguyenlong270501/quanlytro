import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../appointment/data/models/appointment_model.dart';
import '../../data/repositories/messages_repository.dart';
import 'appointments_feed_state.dart';

class AppointmentsFeedCubit extends Cubit<AppointmentsFeedState> {
  AppointmentsFeedCubit(this._repository) : super(const AppointmentsFeedState());

  final MessagesRepository _repository;
  StreamSubscription<Either<String, List<AppointmentModel>>>? _pendingSubscription;
  StreamSubscription<Either<String, List<AppointmentModel>>>? _upcomingSubscription;
  StreamSubscription<Either<String, List<AppointmentModel>>>? _historySubscription;
  String? _landlordId;

  void watch(String landlordId) {
    final normalizedLandlordId = landlordId.trim();
    _landlordId = normalizedLandlordId;
    if (normalizedLandlordId.isEmpty) {
      emit(
        state.copyWith(
          isLoadingPending: false,
          pendingItems: const [],
          clearError: true,
        ),
      );
      return;
    }
    _subscribePending(isInitialLoad: true);
  }

  void selectFilter(AppointmentListFilter filter) {
    if (filter == state.selectedFilter) {
      return;
    }
    emit(state.copyWith(selectedFilter: filter, clearError: true));
    switch (filter) {
      case AppointmentListFilter.pending:
        break;
      case AppointmentListFilter.upcoming:
        if (_upcomingSubscription == null) {
          _subscribeUpcoming(isInitialLoad: true);
        }
        break;
      case AppointmentListFilter.history:
        if (_historySubscription == null) {
          _subscribeHistory(isInitialLoad: true);
        }
        break;
    }
  }

  void loadMore() {
    if (state.isLoadingMoreSelected || !state.canLoadMoreSelected) {
      return;
    }
    switch (state.selectedFilter) {
      case AppointmentListFilter.pending:
        emit(
          state.copyWith(
            pendingLimit: state.pendingLimit + AppointmentsFeedState.limitStep,
            isLoadingMorePending: true,
            clearError: true,
          ),
        );
        _subscribePending();
        break;
      case AppointmentListFilter.upcoming:
        emit(
          state.copyWith(
            upcomingLimit: state.upcomingLimit + AppointmentsFeedState.limitStep,
            isLoadingMoreUpcoming: true,
            clearError: true,
          ),
        );
        _subscribeUpcoming();
        break;
      case AppointmentListFilter.history:
        emit(
          state.copyWith(
            historyLimit: state.historyLimit + AppointmentsFeedState.limitStep,
            isLoadingMoreHistory: true,
            clearError: true,
          ),
        );
        _subscribeHistory();
        break;
    }
  }

  void _subscribePending({bool isInitialLoad = false}) {
    final landlordId = _landlordId;
    if (landlordId == null || landlordId.isEmpty) {
      return;
    }
    if (isInitialLoad) {
      emit(state.copyWith(isLoadingPending: true, clearError: true));
    }
    _pendingSubscription?.cancel();
    _pendingSubscription = _repository
        .watchPendingAppointmentsByLandlord(
          landlordId: landlordId,
          limit: state.pendingLimit,
        )
        .listen(
          (result) => result.fold(
            (message) => emit(
              state.copyWith(
                isLoadingPending: false,
                isLoadingMorePending: false,
                errorMessage: message,
              ),
            ),
            (items) {
              final sorted = List<AppointmentModel>.from(items)
                ..sort(comparePendingFeedAppointments);
              emit(
                state.copyWith(
                  isLoadingPending: false,
                  isLoadingMorePending: false,
                  pendingItems: sorted,
                  clearError: true,
                ),
              );
            },
          ),
        );
  }

  void _subscribeUpcoming({bool isInitialLoad = false}) {
    final landlordId = _landlordId;
    if (landlordId == null || landlordId.isEmpty) {
      return;
    }
    if (isInitialLoad) {
      emit(state.copyWith(isLoadingUpcoming: true, clearError: true));
    }
    _upcomingSubscription?.cancel();
    _upcomingSubscription = _repository
        .watchUpcomingAcceptedAppointments(
          landlordId: landlordId,
          limit: state.upcomingLimit,
        )
        .listen(
          (result) => result.fold(
            (message) => emit(
              state.copyWith(
                isLoadingUpcoming: false,
                isLoadingMoreUpcoming: false,
                errorMessage: message,
              ),
            ),
            (items) => emit(
              state.copyWith(
                isLoadingUpcoming: false,
                isLoadingMoreUpcoming: false,
                upcomingItems: items,
                clearError: true,
              ),
            ),
          ),
        );
  }

  void _subscribeHistory({bool isInitialLoad = false}) {
    final landlordId = _landlordId;
    if (landlordId == null || landlordId.isEmpty) {
      return;
    }
    if (isInitialLoad) {
      emit(state.copyWith(isLoadingHistory: true, clearError: true));
    }
    _historySubscription?.cancel();
    _historySubscription = _repository
        .watchHistoryAppointments(
          landlordId: landlordId,
          limit: state.historyLimit,
        )
        .listen(
          (result) => result.fold(
            (message) => emit(
              state.copyWith(
                isLoadingHistory: false,
                isLoadingMoreHistory: false,
                errorMessage: message,
              ),
            ),
            (items) => emit(
              state.copyWith(
                isLoadingHistory: false,
                isLoadingMoreHistory: false,
                historyItems: items,
                clearError: true,
              ),
            ),
          ),
        );
  }

  @override
  Future<void> close() async {
    await _pendingSubscription?.cancel();
    await _upcomingSubscription?.cancel();
    await _historySubscription?.cancel();
    return super.close();
  }
}
