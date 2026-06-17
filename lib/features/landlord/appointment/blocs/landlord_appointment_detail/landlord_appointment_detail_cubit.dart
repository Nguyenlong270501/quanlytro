import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/appointment_model.dart';
import '../../data/repositories/appointment_repository.dart';
import 'landlord_appointment_detail_state.dart';

class LandlordAppointmentDetailCubit extends Cubit<LandlordAppointmentDetailState> {
  LandlordAppointmentDetailCubit({
    required AppointmentRepository repository,
    required AppointmentModel appointment,
  }) : _repository = repository,
       super(LandlordAppointmentDetailState(appointment: appointment));

  final AppointmentRepository _repository;

  static const String _missingTenantError =
      'Thiếu thông tin người thuê — không thể gửi thông báo';

  String? _documentId(AppointmentModel model) {
    final id = model.appointmentId.trim();
    return id.isEmpty ? null : id;
  }

  bool _ensureCanNotifyTenant() {
    if (state.appointment.tenantId.trim().isEmpty) {
      emit(state.copyWith(errorMessage: _missingTenantError));
      return false;
    }
    return true;
  }

  void clearError() {
    emit(state.copyWith(clearError: true));
  }

  void clearSuccessMessage() {
    emit(state.copyWith(clearSuccessMessage: true));
  }

  Future<void> accept() async {
    final docId = _documentId(state.appointment);
    if (docId == null) {
      emit(state.copyWith(errorMessage: 'Thiếu mã lịch hẹn'));
      return;
    }
    if (!_ensureCanNotifyTenant()) {
      return;
    }
    emit(
      state.copyWith(
        isSubmitting: true,
        clearError: true,
        clearSuccessMessage: true,
      ),
    );
    final result = await _repository.acceptAppointment(docId);
    result.fold(
      (message) => emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: message,
          clearSuccessMessage: true,
        ),
      ),
      (_) => emit(
        state.copyWith(
          isSubmitting: false,
          appointment: state.appointment.copyWith(
            status: AppointmentStatus.accepted,
            clearLandlordCancelReason: true,
            clearCancelledBy: true,
            acceptedBy: 'landlord',
          ),
          clearError: true,
          successMessage:
              'Đã xác nhận lịch hẹn. Người thuê sẽ được thông báo.',
        ),
      ),
    );
  }

  Future<void> reject(String landlordCancelReason) async {
    final docId = _documentId(state.appointment);
    if (docId == null) {
      emit(state.copyWith(errorMessage: 'Thiếu mã lịch hẹn'));
      return;
    }
    if (!_ensureCanNotifyTenant()) {
      return;
    }
    emit(
      state.copyWith(
        isSubmitting: true,
        clearError: true,
        clearSuccessMessage: true,
      ),
    );
    final result = await _repository.rejectAppointment(
      appointmentId: docId,
      landlordCancelReason: landlordCancelReason,
    );
    result.fold(
      (message) => emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: message,
          clearSuccessMessage: true,
        ),
      ),
      (_) => emit(
        state.copyWith(
          isSubmitting: false,
          appointment: state.appointment.copyWith(
            status: AppointmentStatus.rejected,
            landlordCancelReason: landlordCancelReason,
            cancelledBy: 'landlord',
            clearAcceptedBy: true,
          ),
          clearError: true,
          successMessage:
              'Đã từ chối lịch hẹn. Người thuê sẽ được thông báo.',
        ),
      ),
    );
  }

  Future<void> markComplete() async {
    final docId = _documentId(state.appointment);
    if (docId == null) {
      emit(state.copyWith(errorMessage: 'Thiếu mã lịch hẹn'));
      return;
    }
    if (!_ensureCanNotifyTenant()) {
      return;
    }
    emit(
      state.copyWith(
        isSubmitting: true,
        clearError: true,
        clearSuccessMessage: true,
      ),
    );
    final result = await _repository.markAppointmentComplete(docId);
    result.fold(
      (message) => emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: message,
          clearSuccessMessage: true,
        ),
      ),
      (_) => emit(
        state.copyWith(
          isSubmitting: false,
          appointment: state.appointment.copyWith(
            status: AppointmentStatus.success,
          ),
          clearError: true,
          successMessage:
              'Đã đánh dấu hoàn thành. Người thuê sẽ được thông báo.',
        ),
      ),
    );
  }

  Future<void> cancelAfterAccept(String landlordCancelReason) async {
    final docId = _documentId(state.appointment);
    if (docId == null) {
      emit(state.copyWith(errorMessage: 'Thiếu mã lịch hẹn'));
      return;
    }
    if (!_ensureCanNotifyTenant()) {
      return;
    }
    emit(
      state.copyWith(
        isSubmitting: true,
        clearError: true,
        clearSuccessMessage: true,
      ),
    );
    final result = await _repository.cancelAcceptedAppointment(
      appointmentId: docId,
      landlordCancelReason: landlordCancelReason,
    );
    result.fold(
      (message) => emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: message,
          clearSuccessMessage: true,
        ),
      ),
      (_) => emit(
        state.copyWith(
          isSubmitting: false,
          appointment: state.appointment.copyWith(
            status: AppointmentStatus.cancelled,
            landlordCancelReason: landlordCancelReason,
            cancelledBy: 'landlord',
            clearAcceptedBy: true,
          ),
          clearError: true,
          successMessage: 'Đã hủy lịch hẹn. Người thuê sẽ được thông báo.',
        ),
      ),
    );
  }

  Future<void> reschedule(DateTime newAppointmentDate) async {
    final docId = _documentId(state.appointment);
    if (docId == null) {
      emit(state.copyWith(errorMessage: 'Thiếu mã lịch hẹn'));
      return;
    }
    if (!_ensureCanNotifyTenant()) {
      return;
    }
    emit(
      state.copyWith(
        isSubmitting: true,
        clearError: true,
        clearSuccessMessage: true,
      ),
    );
    final result = await _repository.rescheduleAppointment(
      appointmentId: docId,
      appointmentDate: newAppointmentDate,
    );
    result.fold(
      (message) => emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: message,
          clearSuccessMessage: true,
        ),
      ),
      (_) => emit(
        state.copyWith(
          isSubmitting: false,
          appointment: state.appointment.copyWith(
            appointmentDate: newAppointmentDate,
            status: AppointmentStatus.rescheduled,
            clearLandlordCancelReason: true,
            clearCancelledBy: true,
            clearAcceptedBy: true,
          ),
          clearError: true,
          successMessage:
              'Đã cập nhật lịch hẹn. Người thuê sẽ được thông báo.',
        ),
      ),
    );
  }
}
