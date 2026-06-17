import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../landlord/create_property/data/models/property_model.dart';
import '../../data/models/landlord_summary.dart';
import '../../data/repositories/admin_property_approvals/admin_property_approval_repository_impl.dart';
import 'admin_property_detail_state.dart';

class AdminPropertyDetailCubit extends Cubit<AdminPropertyDetailState> {
  AdminPropertyDetailCubit(this._repo, {required PropertyModel initialProperty})
      : super(AdminPropertyDetailState(property: initialProperty));

  final AdminPropertyApprovalRepositoryImpl _repo;

  void init() {
    unawaited(_loadLatestLandlordProfile());
    if (state.property.rooms == null) {
      unawaited(_loadRooms());
    }
  }

  Future<void> _loadRooms() async {
    emit(state.copyWith(isRoomsLoading: true));
    final result = await _repo.getPropertyWithRooms(state.property.propertyId);
    if (isClosed) return;
    result.fold(
      (_) => emit(state.copyWith(isRoomsLoading: false)),
      (p) {
        if (p != null) {
          emit(state.copyWith(isRoomsLoading: false, property: p));
        } else {
          emit(state.copyWith(isRoomsLoading: false));
        }
      },
    );
  }

  Future<void> _loadLatestLandlordProfile() async {
    final property = state.property;
    final landlordId = property.landlordId.trim();
    final baseline = _toBaselineSummary(property);

    if (landlordId.isEmpty) {
      emit(
        state.copyWith(
          landlordProfileStatus: LandlordProfileStatus.failure,
          displayLandlord: baseline,
          landlordProfileError: 'Thiếu landlordId để tải hồ sơ chủ trọ.',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        landlordProfileStatus: LandlordProfileStatus.loading,
        displayLandlord: baseline,
        clearLandlordProfileError: true,
      ),
    );

    final result = await _repo.getLandlordSummaries({landlordId});
    if (isClosed) return;
    result.fold(
      (error) {
        emit(
          state.copyWith(
            landlordProfileStatus: LandlordProfileStatus.failure,
            displayLandlord: baseline,
            landlordProfileError: error,
          ),
        );
      },
      (map) {
        final fresh = map[landlordId];
        final merged = baseline == null
            ? fresh
            : (fresh == null ? baseline : baseline.mergeWith(fresh));
        emit(
          state.copyWith(
            landlordProfileStatus: LandlordProfileStatus.loaded,
            displayLandlord: merged,
            clearLandlordProfileError: true,
          ),
        );
      },
    );
  }

  Future<void> approveProperty(String propertyId) => _runSubmit(
        AdminPropertySubmitPhase.approving,
        () => _repo.approveProperty(propertyId),
        'Đã duyệt bài đăng',
      );

  Future<void> rejectProperty(String propertyId, String reason) => _runSubmit(
        AdminPropertySubmitPhase.rejecting,
        () => _repo.rejectProperty(propertyId, reason),
        'Đã từ chối bài đăng',
      );

  Future<void> approvePendingUpdate({
    required String propertyId,
    required String reviewedBy,
  }) =>
      _runSubmit(
        AdminPropertySubmitPhase.approving,
        () => _repo.approvePendingUpdate(
          propertyId: propertyId,
          reviewedBy: reviewedBy,
        ),
        'Đã duyệt chỉnh sửa',
      );

  Future<void> rejectPendingUpdate({
    required String propertyId,
    required String reviewedBy,
    required String reason,
  }) =>
      _runSubmit(
        AdminPropertySubmitPhase.rejecting,
        () => _repo.rejectPendingUpdate(
          propertyId: propertyId,
          reviewedBy: reviewedBy,
          reason: reason,
        ),
        'Đã từ chối chỉnh sửa',
      );

  Future<void> _runSubmit(
    AdminPropertySubmitPhase phase,
    Future<Either<String, void>> Function() action,
    String successMessage,
  ) async {
    emit(
      state.copyWith(
        submitPhase: phase,
        clearError: true,
        clearSuccess: true,
      ),
    );
    final result = await action();
    if (isClosed) return;
    result.fold(
      (error) => emit(
        state.copyWith(
          submitPhase: AdminPropertySubmitPhase.idle,
          errorMessage: error,
          clearSuccess: true,
        ),
      ),
      (_) => emit(
        state.copyWith(
          submitPhase: AdminPropertySubmitPhase.idle,
          successMessage: successMessage,
          clearError: true,
        ),
      ),
    );
  }

  static LandlordSummary? _toBaselineSummary(PropertyModel property) {
    final embedded = property.landlordSummary;
    if (embedded == null) return null;
    final displayName = embedded.userName.trim();
    final email = embedded.email?.trim() ?? '';
    final phone = embedded.phoneNumber?.trim();
    return LandlordSummary(
      userId: property.landlordId,
      displayName: displayName,
      email: email,
      phoneNumber: phone != null && phone.isNotEmpty ? phone : null,
    );
  }
}
