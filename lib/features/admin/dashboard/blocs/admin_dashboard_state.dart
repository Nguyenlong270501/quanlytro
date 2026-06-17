import '../data/models/admin_user_stats_counts.dart';
import '../../approvals/data/models/landlord_summary.dart';
import '../../../landlord/create_property/data/models/property_model.dart';

enum AdminDashboardStatus {
  initial,
  loading,
  loaded,
  failure,
}

enum AdminDashboardRecentStatus {
  initial,
  loading,
  loaded,
  failure,
}

class AdminDashboardState {
  const AdminDashboardState({
    this.status = AdminDashboardStatus.initial,
    this.recentStatus = AdminDashboardRecentStatus.initial,
    this.counts,
    this.recentProperties = const [],
    this.recentLandlordSummaries = const {},
    this.errorMessage,
    this.recentErrorMessage,
  });

  final AdminDashboardStatus status;
  final AdminDashboardRecentStatus recentStatus;
  final AdminUserStatsCounts? counts;
  final List<PropertyModel> recentProperties;
  final Map<String, LandlordSummary> recentLandlordSummaries;
  final String? errorMessage;
  final String? recentErrorMessage;

  AdminDashboardState copyWith({
    AdminDashboardStatus? status,
    AdminDashboardRecentStatus? recentStatus,
    AdminUserStatsCounts? counts,
    List<PropertyModel>? recentProperties,
    Map<String, LandlordSummary>? recentLandlordSummaries,
    String? errorMessage,
    String? recentErrorMessage,
    bool clearError = false,
    bool clearCounts = false,
    bool clearRecentError = false,
    bool clearRecentProperties = false,
  }) {
    return AdminDashboardState(
      status: status ?? this.status,
      recentStatus: recentStatus ?? this.recentStatus,
      counts: clearCounts ? null : (counts ?? this.counts),
      recentProperties: clearRecentProperties
          ? const []
          : (recentProperties ?? this.recentProperties),
      recentLandlordSummaries:
          recentLandlordSummaries ?? this.recentLandlordSummaries,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      recentErrorMessage: clearRecentError
          ? null
          : (recentErrorMessage ?? this.recentErrorMessage),
    );
  }
}
