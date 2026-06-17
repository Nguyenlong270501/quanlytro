import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_style.dart';

/// Cấu hình thanh nút dưới màn chi tiết lịch hẹn (chủ trọ).
sealed class LandlordAppointmentDetailBottomBarState {
  const LandlordAppointmentDetailBottomBarState();
}

/// Trạng thái chờ: Từ chối / Đồng ý.
final class LandlordAppointmentDetailBottomBarPending
    extends LandlordAppointmentDetailBottomBarState {
  const LandlordAppointmentDetailBottomBarPending({
    required this.onReject,
    required this.onAccept,
  });

  final VoidCallback onReject;
  final VoidCallback onAccept;
}

/// Đã đồng ý: Hủy lịch / Hoàn thành.
final class LandlordAppointmentDetailBottomBarAfterAccept
    extends LandlordAppointmentDetailBottomBarState {
  const LandlordAppointmentDetailBottomBarAfterAccept({
    required this.onCancelAppointment,
    required this.onComplete,
  });

  final VoidCallback onCancelAppointment;
  final VoidCallback onComplete;
}

/// Đã từ chối hoặc đã hủy: chỉ nút đặt lại (placeholder UI).
final class LandlordAppointmentDetailBottomBarReschedule
    extends LandlordAppointmentDetailBottomBarState {
  const LandlordAppointmentDetailBottomBarReschedule({
    required this.onReschedule,
  });

  final VoidCallback onReschedule;
}

/// Thanh [SafeArea] + progress + hai nút — tách riêng để dễ bảo trì.
class LandlordAppointmentDetailBottomBar extends StatelessWidget {
  const LandlordAppointmentDetailBottomBar({
    super.key,
    required this.isSaving,
    required this.state,
  });

  final bool isSaving;
  final LandlordAppointmentDetailBottomBarState state;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      LandlordAppointmentDetailBottomBarPending(:final onReject, :final onAccept) =>
        _BarShell(
          isSaving: isSaving,
          leadingLabel: 'Từ chối',
          trailingLabel: 'Đồng ý',
          onLeading: onReject,
          onTrailing: onAccept,
        ),
      LandlordAppointmentDetailBottomBarAfterAccept(
        :final onCancelAppointment,
        :final onComplete,
      ) =>
        _BarShell(
          isSaving: isSaving,
          leadingLabel: 'Hủy lịch hẹn',
          trailingLabel: 'Hoàn thành',
          onLeading: onCancelAppointment,
          onTrailing: onComplete,
        ),
      LandlordAppointmentDetailBottomBarReschedule(:final onReschedule) =>
        _RescheduleBarShell(isSaving: isSaving, onReschedule: onReschedule),
    };
  }
}

class _RescheduleBarShell extends StatelessWidget {
  const _RescheduleBarShell({
    required this.isSaving,
    required this.onReschedule,
  });

  final bool isSaving;
  final VoidCallback onReschedule;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isSaving) ...[
              const LinearProgressIndicator(minHeight: 2),
              SizedBox(height: 8.h),
            ],
            FilledButton(
              onPressed: isSaving ? null : onReschedule,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.surface,
              ),
              child: Text(
                'Đặt lại lịch hẹn',
                style: AppTypography.bold14(color: AppColors.surface),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BarShell extends StatelessWidget {
  const _BarShell({
    required this.isSaving,
    required this.leadingLabel,
    required this.trailingLabel,
    required this.onLeading,
    required this.onTrailing,
  });

  final bool isSaving;
  final String leadingLabel;
  final String trailingLabel;
  final VoidCallback onLeading;
  final VoidCallback onTrailing;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isSaving) ...[
              const LinearProgressIndicator(minHeight: 2),
              SizedBox(height: 8.h),
            ],
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isSaving ? null : onLeading,
                    child: Text(
                      leadingLabel,
                      style: AppTypography.bold14(color: AppColors.textPrimary),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: FilledButton(
                    onPressed: isSaving ? null : onTrailing,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.surface,
                    ),
                    child: Text(
                      trailingLabel,
                      style: AppTypography.bold14(color: AppColors.surface),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
