import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_style.dart';
import '../../../../../core/widgets/app_alerts.dart';

String _formatAppointmentDateTime(DateTime d) {
  final h = d.hour.toString().padLeft(2, '0');
  final m = d.minute.toString().padLeft(2, '0');
  return '$h:$m — ${d.day}/${d.month}/${d.year}';
}

Future<DateTime?> showAppointmentRescheduleSheet(BuildContext context) {
  return showModalBottomSheet<DateTime>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    builder: (_) {
      return _AppointmentRescheduleBody();
    },
  );
}

class _AppointmentRescheduleBody extends StatelessWidget {
  _AppointmentRescheduleBody();

  final ValueNotifier<DateTime> _selectedNotifier = ValueNotifier(
    DateTime.now(),
  );

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  DateTime _ensureNotInPast(DateTime candidate) {
    final now = DateTime.now();
    return candidate.isBefore(now) ? now : candidate;
  }

  Future<void> _pickDate(BuildContext context) async {
    final currentSelected = _selectedNotifier.value;
    final today = _dateOnly(DateTime.now());
    final firstDate = today;
    final lastDate = today.add(const Duration(days: 365 * 3));
    var initialDay = _dateOnly(currentSelected);

    if (initialDay.isBefore(firstDate)) {
      initialDay = firstDate;
    }
    if (initialDay.isAfter(lastDate)) {
      initialDay = lastDate;
    }

    final picked = await showDatePicker(
      context: context,
      useRootNavigator: true,
      initialDate: initialDay,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null && context.mounted) {
      _selectedNotifier.value = _ensureNotInPast(
        DateTime(
          picked.year,
          picked.month,
          picked.day,
          currentSelected.hour,
          currentSelected.minute,
        ),
      );
    }
  }

  Future<void> _pickTime(BuildContext context) async {
    final currentSelected = _selectedNotifier.value;
    final picked = await showTimePicker(
      context: context,
      useRootNavigator: true,
      initialTime: TimeOfDay(
        hour: currentSelected.hour,
        minute: currentSelected.minute,
      ),
    );

    if (picked != null && context.mounted) {
      _selectedNotifier.value = _ensureNotInPast(
        DateTime(
          currentSelected.year,
          currentSelected.month,
          currentSelected.day,
          picked.hour,
          picked.minute,
        ),
      );
    }
  }

  void _onConfirm(BuildContext context) {
    final now = DateTime.now();
    final currentSelected = _selectedNotifier.value;

    if (currentSelected.isBefore(now)) {
      Alerts.of(
        context,
      ).showWarning('Vui lòng chọn thời gian từ hiện tại trở đi');
      return;
    }
    Navigator.of(context).pop(currentSelected);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.textMuted.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Đặt lại lịch hẹn',
                style: AppTypography.bold16(color: AppColors.textPrimary),
              ),
              SizedBox(height: 8.h),
              Text(
                'Thời gian đã chọn',
                style: AppTypography.medium12(color: AppColors.textSecondary),
              ),
              SizedBox(height: 4.h),

              ValueListenableBuilder<DateTime>(
                valueListenable: _selectedNotifier,
                builder: (context, selectedDate, child) {
                  return Text(
                    _formatAppointmentDateTime(selectedDate),
                    style: AppTypography.bold14(color: AppColors.textPrimary),
                  );
                },
              ),

              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _pickDate(context),
                      child: Text(
                        'Chọn ngày',
                        style: AppTypography.bold14(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: OutlinedButton(
                      // Truyền context vào hàm
                      onPressed: () => _pickTime(context),
                      child: Text(
                        'Chọn giờ',
                        style: AppTypography.bold14(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Hủy',
                        style: AppTypography.bold14(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => _onConfirm(context),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.surface,
                      ),
                      child: Text(
                        'Xác nhận',
                        style: AppTypography.bold14(color: AppColors.surface),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
