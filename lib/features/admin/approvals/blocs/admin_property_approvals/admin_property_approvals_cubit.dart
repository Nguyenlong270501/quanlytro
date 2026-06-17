import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../landlord/create_property/data/models/property_model.dart';
import '../../data/models/landlord_summary.dart';
import '../../data/repositories/admin_property_approvals/admin_property_approval_repository.dart';
import 'admin_property_approvals_state.dart';

class AdminPropertyApprovalsCubit extends Cubit<AdminPropertyApprovalsState> {
  AdminPropertyApprovalsCubit({
    required AdminPropertyApprovalRepository repository,
  }) : _repository = repository,
       super(const AdminPropertyApprovalsState());

  final AdminPropertyApprovalRepository _repository;
  StreamSubscription<List<PropertyModel>>? _subscription;

  int _landlordFetchGeneration = 0;

  void subscribe() {
    if (_subscription != null) {
      return;
    }
    _subscribe(isInitialLoad: true);
  }

  Future<Either<String, void>> approve(String propertyId) {
    return _repository.approveProperty(propertyId);
  }

  Future<Either<String, void>> reject(String propertyId, String reason) {
    return _repository.rejectProperty(propertyId, reason);
  }

  Future<Either<String, void>> approvePendingUpdate({
    required String propertyId,
    required String reviewedBy,
  }) {
    return _repository.approvePendingUpdate(
      propertyId: propertyId,
      reviewedBy: reviewedBy,
    );
  }

  Future<Either<String, void>> rejectPendingUpdate({
    required String propertyId,
    required String reviewedBy,
    required String reason,
  }) {
    return _repository.rejectPendingUpdate(
      propertyId: propertyId,
      reviewedBy: reviewedBy,
      reason: reason,
    );
  }

  void _subscribe({bool isInitialLoad = false}) {
    if (isInitialLoad) {
      emit(
        state.copyWith(
          status: AdminPropertyApprovalsStatus.loading,
          clearError: true,
        ),
      );
    }
    _subscription?.cancel();
    _subscription = _repository.watchVisiblePropertiesForAdmin().listen(
      _onPropertyList,
      onError: (Object e, StackTrace _) {
        emit(
          state.copyWith(
            status: AdminPropertyApprovalsStatus.failure,
            errorMessage: e.toString(),
          ),
        );
      },
    );
  }

  Future<void> _onPropertyList(List<PropertyModel> list) async {
    final gen = ++_landlordFetchGeneration;
    final neededIds =
        list.map((p) => p.landlordId).where((id) => id.isNotEmpty).toSet();

    final summaries = <String, LandlordSummary>{};
    for (final id in neededIds) {
      final cached = state.landlordSummaries[id];
      if (cached != null) {
        summaries[id] = cached;
      }
    }

    final fetchCandidateIds = <String>{};
    for (final p in list) {
      final id = p.landlordId;
      if (id.isEmpty) {
        continue;
      }
      if (_needsLandlordFetch(p)) {
        fetchCandidateIds.add(id);
      }
    }

    final missing = fetchCandidateIds
        .where((id) => !summaries.containsKey(id))
        .toSet();

    if (missing.isEmpty) {
      if (isClosed || gen != _landlordFetchGeneration) {
        return;
      }
      emit(
        state.copyWith(
          status: AdminPropertyApprovalsStatus.loaded,
          items: list,
          landlordSummaries: summaries,
          clearError: true,
        ),
      );
      return;
    }

    final result = await _repository.getLandlordSummaries(missing);
    if (isClosed || gen != _landlordFetchGeneration) {
      return;
    }

    result.fold(
      (message) {
        emit(
          state.copyWith(
            status: AdminPropertyApprovalsStatus.loaded,
            items: list,
            landlordSummaries: summaries,
            errorMessage: message,
          ),
        );
      },
      (fetched) {
        emit(
          state.copyWith(
            status: AdminPropertyApprovalsStatus.loaded,
            items: list,
            landlordSummaries: {...summaries, ...fetched},
            clearError: true,
          ),
        );
      },
    );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    _subscription = null;
    return super.close();
  }

  static bool _needsLandlordFetch(PropertyModel p) {
    final s = p.landlordSummary;
    if (s == null) {
      return true;
    }
    return s.userName.trim().isEmpty;
  }
}
