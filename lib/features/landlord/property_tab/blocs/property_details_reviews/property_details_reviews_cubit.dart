import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/property_review_model.dart';
import '../../data/repositories/property_repository.dart';
import 'property_details_reviews_state.dart';

class PropertyDetailsReviewsCubit extends Cubit<PropertyDetailsReviewsState> {
  PropertyDetailsReviewsCubit({required PropertyRepository repository})
    : _repository = repository,
      super(const PropertyDetailsReviewsState());

  final PropertyRepository _repository;
  StreamSubscription<Either<String, List<PropertyReviewModel>>>? _subscription;
  String? _propertyId;

  void watch(String propertyId) {
    final normalizedId = propertyId.trim();
    _propertyId = normalizedId;
    if (normalizedId.isEmpty) {
      emit(
        const PropertyDetailsReviewsState(
          reviews: <PropertyReviewModel>[],
          isLoading: false,
          isLoadingMore: false,
        ),
      );
      return;
    }
    emit(
      const PropertyDetailsReviewsState(
        feedLimit: PropertyDetailsReviewsState.initialLimit,
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
        feedLimit: state.feedLimit + PropertyDetailsReviewsState.limitStep,
        isLoadingMore: true,
        clearError: true,
      ),
    );
    _subscribe();
  }

  void _subscribe({bool isInitialLoad = false}) {
    final propertyId = _propertyId;
    if (propertyId == null || propertyId.isEmpty) {
      return;
    }
    if (isInitialLoad) {
      emit(state.copyWith(isLoading: true, clearError: true));
    }
    _subscription?.cancel();
    _subscription = _repository
        .watchPropertyReviews(propertyId: propertyId, limit: state.feedLimit)
        .listen(
          (result) => result.fold(
            (message) => emit(
              state.copyWith(
                isLoading: false,
                isLoadingMore: false,
                errorMessage: message,
              ),
            ),
            (reviews) => emit(
              state.copyWith(
                isLoading: false,
                isLoadingMore: false,
                reviews: reviews,
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
