import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/notification_model.dart';
import '../../data/repositories/messages_repository.dart';
import 'notifications_feed_state.dart';

class NotificationsFeedCubit extends Cubit<NotificationsFeedState> {
  NotificationsFeedCubit(this._repository)
    : super(const NotificationsFeedState());

  final MessagesRepository _repository;
  StreamSubscription<Either<String, List<NotificationModel>>>? _subscription;
  String? _receiverId;

  void watch(String receiverId) {
    final normalizedId = receiverId.trim();
    _receiverId = normalizedId;
    if (normalizedId.isEmpty) {
      emit(
        const NotificationsFeedState(
          items: <NotificationModel>[],
          isLoading: false,
          isLoadingMore: false,
        ),
      );
      return;
    }
    emit(
      const NotificationsFeedState(
        feedLimit: NotificationsFeedState.initialLimit,
      ),
    );
    _subscribe(isInitialLoad: true);
  }

  void loadMore() {
    if (state.isLoadingMore || !state.canLoadMore) {
      return;
    }
    emit(
      state.copyWith(
        feedLimit: state.feedLimit + NotificationsFeedState.limitStep,
        isLoadingMore: true,
        clearError: true,
      ),
    );
    _subscribe();
  }

  Future<void> markAsRead(String notificationId) async {
    final receiverId = _receiverId;
    if (receiverId == null || receiverId.isEmpty) {
      return;
    }
    final result = await _repository.markNotificationRead(
      notificationId: notificationId,
      receiverId: receiverId,
    );
    result.fold(
      (message) => emit(state.copyWith(errorMessage: message)),
      (_) {},
    );
  }

  void _subscribe({bool isInitialLoad = false}) {
    final receiverId = _receiverId;
    if (receiverId == null || receiverId.isEmpty) {
      return;
    }
    if (isInitialLoad) {
      emit(state.copyWith(isLoading: true, clearError: true));
    }
    _subscription?.cancel();
    _subscription = _repository
        .watchNotificationsByReceiver(
          receiverId: receiverId,
          limit: state.feedLimit,
        )
        .listen(
          (result) => result.fold(
            (message) => emit(
              state.copyWith(
                isLoading: false,
                isLoadingMore: false,
                errorMessage: message,
              ),
            ),
            (items) => emit(
              state.copyWith(
                isLoading: false,
                isLoadingMore: false,
                items: items,
                clearError: true,
              ),
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
