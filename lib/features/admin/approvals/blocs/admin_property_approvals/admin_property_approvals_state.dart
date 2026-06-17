import 'package:equatable/equatable.dart';

import '../../../../../core/utils/vietnamese_search.dart';
import '../../../../landlord/create_property/data/models/property_model.dart';
import '../../blocs/approval_filter/approval_filter_state.dart';
import '../../data/models/landlord_summary.dart';

enum AdminPropertyApprovalsStatus { initial, loading, loaded, failure }

class AdminPropertyApprovalsState extends Equatable {
  const AdminPropertyApprovalsState({
    this.status = AdminPropertyApprovalsStatus.initial,
    this.items = const [],
    this.landlordSummaries = const {},
    this.errorMessage,
  });

  final AdminPropertyApprovalsStatus status;
  final List<PropertyModel> items;
  final Map<String, LandlordSummary> landlordSummaries;
  final String? errorMessage;

  List<PropertyModel> get pendingItems =>
      items.where((p) => p.status == PropertyStatus.pending).toList();

  List<PropertyModel> get approvedItems =>
      items.where((p) => p.status == PropertyStatus.approved).toList();

  List<PropertyModel> get rejectedItems =>
      items.where((p) => p.status == PropertyStatus.rejected).toList();

  int get pendingCount => pendingItems.length;

  List<PropertyModel> get pendingUpdateItems =>
      items.where((p) => p.hasPendingUpdate).toList();

  int get pendingUpdateCount => pendingUpdateItems.length;

  int get postTabBadgeCount => pendingCount + pendingUpdateCount;

  List<PropertyModel> itemsForFilter(ApprovalFilter filter) {
    return switch (filter) {
      ApprovalFilter.pending => pendingItems,
      ApprovalFilter.pendingUpdate => pendingUpdateItems,
      ApprovalFilter.approved => approvedItems,
      ApprovalFilter.rejected => rejectedItems,
    };
  }

  List<PropertyModel> displayItemsForFilter(
    ApprovalFilter filter,
    String searchQuery,
  ) {
    final base = itemsForFilter(filter);
    final query = searchQuery.trim();
    if (query.isEmpty) {
      return base;
    }
    return base.where((property) => _matchesSearch(property, query)).toList();
  }

  bool _matchesSearch(PropertyModel property, String query) {
    final snapshotName = property.landlordSummary?.userName.trim() ?? '';
    final summaryName =
        landlordSummaries[property.landlordId]?.displayName.trim() ?? '';
    final landlordName = snapshotName.isNotEmpty ? snapshotName : summaryName;
    final location =
        '${property.streetAddress} ${property.ward} ${property.city}';

    return vietnameseContainsNormalized(property.title, query) ||
        vietnameseContainsNormalized(property.description, query) ||
        vietnameseContainsNormalized(location, query) ||
        vietnameseContainsNormalized(landlordName, query);
  }

  AdminPropertyApprovalsState copyWith({
    AdminPropertyApprovalsStatus? status,
    List<PropertyModel>? items,
    Map<String, LandlordSummary>? landlordSummaries,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AdminPropertyApprovalsState(
      status: status ?? this.status,
      items: items ?? this.items,
      landlordSummaries: landlordSummaries ?? this.landlordSummaries,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, items, landlordSummaries, errorMessage];
}
