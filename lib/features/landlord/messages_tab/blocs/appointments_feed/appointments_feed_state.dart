import 'package:equatable/equatable.dart';

import '../../../appointment/data/models/appointment_model.dart';

enum AppointmentListFilter { pending, upcoming, history }

final class AppointmentsFeedState extends Equatable {
  const AppointmentsFeedState({
    this.selectedFilter = AppointmentListFilter.pending,
    this.pendingItems = const <AppointmentModel>[],
    this.upcomingItems = const <AppointmentModel>[],
    this.historyItems = const <AppointmentModel>[],
    this.pendingLimit = AppointmentsFeedState.initialLimit,
    this.upcomingLimit = AppointmentsFeedState.initialLimit,
    this.historyLimit = AppointmentsFeedState.initialLimit,
    this.isLoadingPending = false,
    this.isLoadingUpcoming = false,
    this.isLoadingHistory = false,
    this.isLoadingMorePending = false,
    this.isLoadingMoreUpcoming = false,
    this.isLoadingMoreHistory = false,
    this.errorMessage,
  });

  static const int initialLimit = 20;
  static const int limitStep = 20;

  final AppointmentListFilter selectedFilter;
  final List<AppointmentModel> pendingItems;
  final List<AppointmentModel> upcomingItems;
  final List<AppointmentModel> historyItems;
  final int pendingLimit;
  final int upcomingLimit;
  final int historyLimit;
  final bool isLoadingPending;
  final bool isLoadingUpcoming;
  final bool isLoadingHistory;
  final bool isLoadingMorePending;
  final bool isLoadingMoreUpcoming;
  final bool isLoadingMoreHistory;
  final String? errorMessage;

  int get pendingCount => pendingItems.length;

  int get selectedLimit {
    return switch (selectedFilter) {
      AppointmentListFilter.pending => pendingLimit,
      AppointmentListFilter.upcoming => upcomingLimit,
      AppointmentListFilter.history => historyLimit,
    };
  }

  bool get isLoadingSelected {
    return switch (selectedFilter) {
      AppointmentListFilter.pending => isLoadingPending,
      AppointmentListFilter.upcoming => isLoadingUpcoming,
      AppointmentListFilter.history => isLoadingHistory,
    };
  }

  bool get isLoadingMoreSelected {
    return switch (selectedFilter) {
      AppointmentListFilter.pending => isLoadingMorePending,
      AppointmentListFilter.upcoming => isLoadingMoreUpcoming,
      AppointmentListFilter.history => isLoadingMoreHistory,
    };
  }

  bool get canLoadMoreSelected {
    return switch (selectedFilter) {
      AppointmentListFilter.pending => pendingItems.length >= pendingLimit,
      AppointmentListFilter.upcoming => upcomingItems.length >= upcomingLimit,
      AppointmentListFilter.history => historyItems.length >= historyLimit,
    };
  }

  List<AppointmentModel> get selectedItems {
    return switch (selectedFilter) {
      AppointmentListFilter.pending => pendingItems,
      AppointmentListFilter.upcoming => upcomingItems,
      AppointmentListFilter.history => historyItems,
    };
  }

  AppointmentsFeedState copyWith({
    AppointmentListFilter? selectedFilter,
    List<AppointmentModel>? pendingItems,
    List<AppointmentModel>? upcomingItems,
    List<AppointmentModel>? historyItems,
    int? pendingLimit,
    int? upcomingLimit,
    int? historyLimit,
    bool? isLoadingPending,
    bool? isLoadingUpcoming,
    bool? isLoadingHistory,
    bool? isLoadingMorePending,
    bool? isLoadingMoreUpcoming,
    bool? isLoadingMoreHistory,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AppointmentsFeedState(
      selectedFilter: selectedFilter ?? this.selectedFilter,
      pendingItems: pendingItems ?? this.pendingItems,
      upcomingItems: upcomingItems ?? this.upcomingItems,
      historyItems: historyItems ?? this.historyItems,
      pendingLimit: pendingLimit ?? this.pendingLimit,
      upcomingLimit: upcomingLimit ?? this.upcomingLimit,
      historyLimit: historyLimit ?? this.historyLimit,
      isLoadingPending: isLoadingPending ?? this.isLoadingPending,
      isLoadingUpcoming: isLoadingUpcoming ?? this.isLoadingUpcoming,
      isLoadingHistory: isLoadingHistory ?? this.isLoadingHistory,
      isLoadingMorePending: isLoadingMorePending ?? this.isLoadingMorePending,
      isLoadingMoreUpcoming:
          isLoadingMoreUpcoming ?? this.isLoadingMoreUpcoming,
      isLoadingMoreHistory: isLoadingMoreHistory ?? this.isLoadingMoreHistory,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    selectedFilter,
    pendingItems,
    upcomingItems,
    historyItems,
    pendingLimit,
    upcomingLimit,
    historyLimit,
    isLoadingPending,
    isLoadingUpcoming,
    isLoadingHistory,
    isLoadingMorePending,
    isLoadingMoreUpcoming,
    isLoadingMoreHistory,
    errorMessage,
  ];
}
