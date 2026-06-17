import 'package:equatable/equatable.dart';

import '../../../../../core/utils/vietnamese_search.dart';
import '../../blocs/approval_filter/approval_filter_state.dart';
import '../../data/models/landlord_request.dart';

enum LandlordRequestsStatus { initial, loading, loaded, failure }

class LandlordRequestsState extends Equatable {
  const LandlordRequestsState({
    this.status = LandlordRequestsStatus.initial,
    this.items = const [],
    this.errorMessage,
  });

  final LandlordRequestsStatus status;
  final List<LandlordRequest> items;
  final String? errorMessage;

  List<LandlordRequest> byStatus(LandlordRequestStatus filter) =>
      items.where((e) => e.status == filter).toList();

  List<LandlordRequest> get pendingItems =>
      byStatus(LandlordRequestStatus.pending);

  List<LandlordRequest> get approvedItems =>
      byStatus(LandlordRequestStatus.approved);

  List<LandlordRequest> get rejectedItems =>
      byStatus(LandlordRequestStatus.rejected);

  int get pendingCount => pendingItems.length;
  int get approvedCount => approvedItems.length;
  int get rejectedCount => rejectedItems.length;
  int get totalCount => items.length;

  List<LandlordRequest> itemsForFilter(ApprovalFilter filter) {
    return switch (filter) {
      ApprovalFilter.pending => pendingItems,
      ApprovalFilter.pendingUpdate => const [],
      ApprovalFilter.approved => approvedItems,
      ApprovalFilter.rejected => rejectedItems,
    };
  }

  List<LandlordRequest> displayItemsForFilter(
    ApprovalFilter filter,
    String searchQuery,
  ) {
    final base = itemsForFilter(filter);
    final query = searchQuery.trim();
    if (query.isEmpty) {
      return base;
    }
    return base
        .where(
          (request) =>
              vietnameseContainsNormalized(request.fullName, query) ||
              vietnameseContainsNormalized(request.phone, query) ||
              vietnameseContainsNormalized(request.address, query),
        )
        .toList();
  }

  LandlordRequestsState copyWith({
    LandlordRequestsStatus? status,
    List<LandlordRequest>? items,
    String? errorMessage,
    bool clearError = false,
  }) {
    return LandlordRequestsState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, items, errorMessage];
}
