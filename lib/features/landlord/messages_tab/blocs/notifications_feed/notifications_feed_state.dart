import 'package:equatable/equatable.dart';

import '../../data/models/notification_model.dart';

final class NotificationsFeedState extends Equatable {
  const NotificationsFeedState({
    this.items = const <NotificationModel>[],
    this.feedLimit = NotificationsFeedState.initialLimit,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  static const int initialLimit = 20;
  static const int limitStep = 20;

  final List<NotificationModel> items;
  final int feedLimit;
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;

  bool get canLoadMore => items.length >= feedLimit;

  NotificationsFeedState copyWith({
    List<NotificationModel>? items,
    int? feedLimit,
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
    bool clearError = false,
  }) {
    return NotificationsFeedState(
      items: items ?? this.items,
      feedLimit: feedLimit ?? this.feedLimit,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    items,
    feedLimit,
    isLoading,
    isLoadingMore,
    errorMessage,
  ];
}
