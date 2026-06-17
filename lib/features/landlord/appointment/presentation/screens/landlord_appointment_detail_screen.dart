import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_style.dart';
import '../../../../../core/widgets/app_alerts.dart';
import '../../../../../core/widgets/app_confirm_dialog.dart';
import '../../../../../core/widgets/app_reason_dialog.dart';
import '../../data/models/appointment_model.dart';
import '../../blocs/landlord_appointment_detail/landlord_appointment_detail_cubit.dart';
import '../../blocs/landlord_appointment_detail/landlord_appointment_detail_state.dart';
import '../widgets/appointment_header.dart';
import '../widgets/appointment_reschedule_bottom_sheet.dart';
import '../widgets/appointment_section.dart';
import '../widgets/landlord_appointment_detail_bottom_bar.dart';

class LandlordAppointmentDetailScreen extends StatelessWidget {
  const LandlordAppointmentDetailScreen({super.key});

  String? _documentId(AppointmentModel model) {
    final id = model.appointmentId.trim();
    return id.isEmpty ? null : id;
  }

  String _formatAppointmentDateTime(DateTime d) {
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '$h:$m — ${d.day}/${d.month}/${d.year}';
  }

  String _dashIfEmpty(String value) {
    final t = value.trim();
    return t.isEmpty ? '—' : t;
  }

  Future<void> _onAcceptPressed(BuildContext context) async {
    final cubit = context.read<LandlordAppointmentDetailCubit>();
    final model = cubit.state.appointment;
    if (model.status != AppointmentStatus.pending || cubit.state.isSubmitting) {
      return;
    }
    final docId = _documentId(model);
    if (docId == null) {
      Alerts.of(context).showError('Thiếu mã lịch hẹn');
      return;
    }
    final confirmed = await AppConfirmDialog.show(
      context,
      title: 'Xác nhận',
      message: 'Bạn có đồng ý lịch hẹn này không?',
      cancelLabel: 'Hủy',
      confirmLabel: 'Đồng ý',
    );
    if (!confirmed || !context.mounted) {
      return;
    }
    await cubit.accept();
  }

  Future<void> _onRejectPressed(BuildContext context) async {
    final cubit = context.read<LandlordAppointmentDetailCubit>();
    final model = cubit.state.appointment;
    if (model.status != AppointmentStatus.pending || cubit.state.isSubmitting) {
      return;
    }
    final docId = _documentId(model);
    if (docId == null) {
      Alerts.of(context).showError('Thiếu mã lịch hẹn');
      return;
    }
    final reason = await AppReasonDialog.show(
      context,
      title: 'Từ chối lịch hẹn',
      description: 'Nhập lý do từ chối (tối đa 200 ký tự):',
      dismissLabel: 'Hủy',
      confirmLabel: 'Xác nhận từ chối',
    );
    if (reason == null || !context.mounted) {
      return;
    }
    await cubit.reject(reason);
  }

  Future<void> _onCompletePressed(BuildContext context) async {
    final cubit = context.read<LandlordAppointmentDetailCubit>();
    final model = cubit.state.appointment;
    if (model.status != AppointmentStatus.accepted ||
        cubit.state.isSubmitting) {
      return;
    }
    final docId = _documentId(model);
    if (docId == null) {
      Alerts.of(context).showError('Thiếu mã lịch hẹn');
      return;
    }
    final confirmed = await AppConfirmDialog.show(
      context,
      title: 'Hoàn thành',
      message: 'Đánh dấu buổi xem phòng đã hoàn tất?',
      cancelLabel: 'Đóng',
      confirmLabel: 'Hoàn thành',
    );
    if (!confirmed || !context.mounted) {
      return;
    }
    await cubit.markComplete();
  }

  Future<void> _onCancelAcceptedPressed(BuildContext context) async {
    final cubit = context.read<LandlordAppointmentDetailCubit>();
    final model = cubit.state.appointment;
    if (model.status != AppointmentStatus.accepted ||
        cubit.state.isSubmitting) {
      return;
    }
    final docId = _documentId(model);
    if (docId == null) {
      Alerts.of(context).showError('Thiếu mã lịch hẹn');
      return;
    }
    final reason = await AppReasonDialog.show(
      context,
      title: 'Hủy lịch hẹn',
      description: 'Nhập lý do hủy lịch (tối đa 200 ký tự):',
      dismissLabel: 'Đóng',
      confirmLabel: 'Xác nhận hủy',
    );
    if (reason == null || !context.mounted) {
      return;
    }
    await cubit.cancelAfterAccept(reason);
  }

  Future<void> _onReschedulePressed(BuildContext context) async {
    final cubit = context.read<LandlordAppointmentDetailCubit>();
    final model = cubit.state.appointment;
    final canReschedule =
        model.status == AppointmentStatus.rejected ||
        model.status == AppointmentStatus.cancelled;
    if (!canReschedule || cubit.state.isSubmitting) {
      return;
    }
    if (_documentId(model) == null) {
      Alerts.of(context).showError('Thiếu mã lịch hẹn');
      return;
    }
    final picked = await showAppointmentRescheduleSheet(context);
    if (picked == null || !context.mounted) {
      return;
    }
    await cubit.reschedule(picked);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<
          LandlordAppointmentDetailCubit,
          LandlordAppointmentDetailState
        >(
          listenWhen: (previous, current) =>
              current.errorMessage != null &&
              current.errorMessage != previous.errorMessage,
          listener: (context, state) {
            final message = state.errorMessage;
            if (message != null) {
              Alerts.of(context).showError(message);
              context.read<LandlordAppointmentDetailCubit>().clearError();
            }
          },
        ),
        BlocListener<
          LandlordAppointmentDetailCubit,
          LandlordAppointmentDetailState
        >(
          listenWhen: (previous, current) =>
              current.successMessage != null &&
              current.successMessage != previous.successMessage,
          listener: (context, state) {
            final message = state.successMessage;
            if (message != null) {
              Alerts.of(context).showSuccess(message);
              context
                  .read<LandlordAppointmentDetailCubit>()
                  .clearSuccessMessage();
            }
          },
        ),
      ],
      child:
          BlocBuilder<
            LandlordAppointmentDetailCubit,
            LandlordAppointmentDetailState
          >(
            builder: (context, state) {
              final model = state.appointment;
              final canRespond = model.status == AppointmentStatus.pending;
              final canPostAcceptActions =
                  model.status == AppointmentStatus.accepted;
              final showRescheduleBar =
                  model.status == AppointmentStatus.rejected ||
                  model.status == AppointmentStatus.cancelled;
              final created = model.createdAt;
              final landlordCancelReason = model.landlordCancelReason?.trim();
              final tenantCancelReason = model.tenantCancelReason?.trim();

              return Scaffold(
                backgroundColor: AppColors.scaffoldBackground,
                bottomNavigationBar: canRespond || canPostAcceptActions
                    ? LandlordAppointmentDetailBottomBar(
                        isSaving: state.isSubmitting,
                        state: canRespond
                            ? LandlordAppointmentDetailBottomBarPending(
                                onReject: () => _onRejectPressed(context),
                                onAccept: () => _onAcceptPressed(context),
                              )
                            : LandlordAppointmentDetailBottomBarAfterAccept(
                                onCancelAppointment: () =>
                                    _onCancelAcceptedPressed(context),
                                onComplete: () => _onCompletePressed(context),
                              ),
                      )
                    : showRescheduleBar
                    ? LandlordAppointmentDetailBottomBar(
                        isSaving: state.isSubmitting,
                        state: LandlordAppointmentDetailBottomBarReschedule(
                          onReschedule: () => _onReschedulePressed(context),
                        ),
                      )
                    : null,
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppointmentHeader(
                      onBackTap: () => context.pop(),
                      title: 'Chi tiết lịch hẹn',
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.only(bottom: 24.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      model.propertyTitle,
                                      style: AppTypography.bold16(
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  _StatusBadge(status: model.status),
                                ],
                              ),
                            ),
                            AppSizes.gapH8,
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 18.w),
                              child: Text(
                                _dashIfEmpty(model.propertyAddress),
                                style: AppTypography.medium14(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            const AppointmentDivider(),
                            AppointmentSection(
                              label: 'Thời gian hẹn',
                              child: Text(
                                _formatAppointmentDateTime(
                                  model.appointmentDate,
                                ),
                                style: AppTypography.medium14(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            const AppointmentDivider(),
                            AppointmentSection(
                              label: 'Mục đích',
                              child: Text(
                                _dashIfEmpty(model.purpose),
                                style: AppTypography.medium14(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            const AppointmentDivider(),
                            AppointmentSection(
                              label: 'Ghi chú',
                              child: Text(
                                _dashIfEmpty(model.note),
                                style: AppTypography.medium14(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            if (landlordCancelReason != null &&
                                landlordCancelReason.isNotEmpty) ...[
                              const AppointmentDivider(),
                              AppointmentSection(
                                label: 'Lý do chủ trọ đã hủy / từ chối',
                                child: Text(
                                  landlordCancelReason,
                                  style: AppTypography.medium14(
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                            if (tenantCancelReason != null &&
                                tenantCancelReason.isNotEmpty) ...[
                              const AppointmentDivider(),
                              AppointmentSection(
                                label: 'Lý do khách thuê đã hủy / từ chối',
                                child: Text(
                                  tenantCancelReason,
                                  style: AppTypography.medium14(
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                            const AppointmentDivider(),
                            AppointmentSection(
                              label: 'Người đặt lịch',
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _dashIfEmpty(model.tenantName),
                                    style: AppTypography.medium14(
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  AppSizes.gapH6,
                                  Text(
                                    _dashIfEmpty(model.tenantPhone),
                                    style: AppTypography.medium14(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (created != null) ...[
                              const AppointmentDivider(),
                              AppointmentSection(
                                label: 'Tạo lúc',
                                child: Text(
                                  _formatAppointmentDateTime(created),
                                  style: AppTypography.medium12(
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final (text, color) = switch (status) {
      AppointmentStatus.accepted => ('Đã xác nhận', AppColors.primary),
      AppointmentStatus.pending => ('Chờ xác nhận', AppColors.warning),
      AppointmentStatus.success => ('Đã xem', AppColors.accent),
      AppointmentStatus.cancelled => ('Đã hủy', AppColors.danger),
      AppointmentStatus.rejected => ('Từ chối', AppColors.warning),
      AppointmentStatus.rescheduled => ('Đã đổi lịch', AppColors.primary),
      _ => ('Không rõ', AppColors.textMuted),
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text, style: AppTypography.bold10(color: color)),
    );
  }
}
