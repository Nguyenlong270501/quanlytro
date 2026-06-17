import 'package:flutter_bloc/flutter_bloc.dart';

import '../../approvals/data/models/landlord_summary.dart';
import '../../approvals/data/repositories/admin_property_approvals/admin_property_approval_repository.dart';
import '../../../landlord/create_property/data/models/property_model.dart';
import '../data/repositories/admin_dashboard_repository.dart';
import 'admin_dashboard_state.dart';

class AdminDashboardCubit extends Cubit<AdminDashboardState> {
  AdminDashboardCubit(
    this._repository, {
    required AdminPropertyApprovalRepository approvalRepository,
  })  : _approvalRepository = approvalRepository,
        super(const AdminDashboardState());

  final AdminDashboardRepository _repository;
  final AdminPropertyApprovalRepository _approvalRepository;

  Future<void> loadUserStats({bool silent = false}) async {
    final hasCache = state.status == AdminDashboardStatus.loaded;
    if (!silent || !hasCache) {
      emit(
        state.copyWith(
          status: AdminDashboardStatus.loading,
          clearError: true,
        ),
      );
    }

    final result = await _repository.getUserStatsCounts();
    if (isClosed) return;
    result.fold(
      (message) {
        if (silent && hasCache) return;
        emit(
          state.copyWith(
            status: AdminDashboardStatus.failure,
            errorMessage: message,
          ),
        );
      },
      (counts) => emit(
        state.copyWith(
          status: AdminDashboardStatus.loaded,
          counts: counts,
          clearError: true,
        ),
      ),
    );
  }

  Future<void> loadRecentPosts({int limit = 5, bool silent = false}) async {
    final hasCache = state.recentStatus == AdminDashboardRecentStatus.loaded;
    if (!silent || !hasCache) {
      emit(
        state.copyWith(
          recentStatus: AdminDashboardRecentStatus.loading,
          clearRecentError: true,
        ),
      );
    }

    final listResult = await _approvalRepository.getRecentPropertiesForAdmin(
      limit: limit,
    );
    if (isClosed) return;

    await listResult.fold(
      (message) async {
        if (silent && hasCache) return;
        emit(
          state.copyWith(
            recentStatus: AdminDashboardRecentStatus.failure,
            recentErrorMessage: message,
          ),
        );
      },
      (list) async {
        final summaries = await _resolveLandlordSummaries(list);
        if (isClosed) return;
        emit(
          state.copyWith(
            recentStatus: AdminDashboardRecentStatus.loaded,
            recentProperties: list,
            recentLandlordSummaries: summaries,
            clearRecentError: true,
          ),
        );
      },
    );
  }

  Future<Map<String, LandlordSummary>> _resolveLandlordSummaries(
    List<PropertyModel> list,
  ) async {
    final needed = list
        .map((e) => e.landlordId)
        .where((id) => id.trim().isNotEmpty)
        .toSet();

    final embedded = <String, LandlordSummary>{};
    final missing = <String>{};
    for (final p in list) {
      final id = p.landlordId.trim();
      if (id.isEmpty) continue;
      final e = p.landlordSummary;
      if (e != null && e.userName.trim().isNotEmpty) {
        embedded[id] = LandlordSummary(
          userId: id,
          displayName: e.userName.trim(),
          email: e.email?.trim() ?? '',
          phoneNumber: e.phoneNumber?.trim(),
        );
      } else {
        missing.add(id);
      }
    }

    final idsToFetch = needed.where((id) => !embedded.containsKey(id)).toSet();
    idsToFetch.addAll(missing);
    if (idsToFetch.isEmpty) return embedded;

    final fetchedResult = await _approvalRepository.getLandlordSummaries(
      idsToFetch,
    );
    return fetchedResult.fold((_) => embedded, (fetched) => {...embedded, ...fetched});
  }
}
