import 'package:equatable/equatable.dart';

import '../../data/models/property_review_model.dart';

final class PropertyDetailsReviewsState extends Equatable {
  const PropertyDetailsReviewsState({
    this.reviews = const <PropertyReviewModel>[],
    this.feedLimit = PropertyDetailsReviewsState.initialLimit,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  static const int initialLimit = 20;
  static const int limitStep = 20;

  final List<PropertyReviewModel> reviews;
  final int feedLimit;
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;

  bool get canLoadMore => reviews.length >= feedLimit;

  PropertyDetailsReviewsState copyWith({
    List<PropertyReviewModel>? reviews,
    int? feedLimit,
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PropertyDetailsReviewsState(
      reviews: reviews ?? this.reviews,
      feedLimit: feedLimit ?? this.feedLimit,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    reviews,
    feedLimit,
    isLoading,
    isLoadingMore,
    errorMessage,
  ];
}
