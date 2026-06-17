import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:quanlytro/core/constants/app_sizes.dart';
import '../../../../../../../core/theme/app_colors.dart';
import '../../../../../../../core/theme/app_style.dart';
import '../../../../blocs/step3/duplicate_room_cubit.dart';
import '../../../../data/models/room_model.dart';

class DuplicateRoomDialog extends StatelessWidget {
  const DuplicateRoomDialog({
    super.key,
    required this.roomToCopy,
    required this.maxDuplicateCount,
    required this.onConfirm,
  });

  final RoomModel roomToCopy;
  /// Số bản sao tối đa có thể chọn (>= 1).
  final int maxDuplicateCount;
  final void Function(int duplicateCount) onConfirm;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DuplicateRoomCubit(maxCount: maxDuplicateCount),
      child: Builder(
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
            insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
            child: _DialogContent(
              roomToCopy: roomToCopy,
              maxDuplicateCount: maxDuplicateCount,
              onConfirm: onConfirm,
            ),
          );
        },
      ),
    );
  }
}

class _DialogContent extends StatelessWidget {
  const _DialogContent({
    required this.roomToCopy,
    required this.maxDuplicateCount,
    required this.onConfirm,
  });

  final RoomModel roomToCopy;
  final int maxDuplicateCount;
  final void Function(int) onConfirm;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context),
          AppSizes.gapH8,
          _buildSubtitle(),
          AppSizes.gapH12,
          _buildCounter(context),
          AppSizes.gapH16,
          _buildActions(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(
            Icons.content_copy_rounded,
            color: AppColors.primary,
            size: 20.sp,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tạo bản sao phòng',
                style: AppTypography.bold16(color: AppColors.textPrimary),
              ),
              SizedBox(height: 2.h),
              Text(
                roomToCopy.roomName,
                style: AppTypography.medium14(color: AppColors.textMuted),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => context.pop(),
          child: Icon(
            Icons.close_rounded,
            color: AppColors.textMuted,
            size: 20.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildSubtitle() {
    return Text(
      'Chọn số lượng bản sao muốn tạo. Tối đa $maxDuplicateCount phòng.',
      style: AppTypography.medium14(color: AppColors.textMuted),
    );
  }

  Widget _buildCounter(BuildContext context) {
    return BlocBuilder<DuplicateRoomCubit, int>(
      builder: (context, count) {
        final cubit = context.read<DuplicateRoomCubit>();
        final isMin = count <= 1;
        final isMax = count >= maxDuplicateCount;

        return Column(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.textDisabled.withValues(alpha: 0.3),
                  width: 0.5,
                ),
                borderRadius: BorderRadius.circular(14.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _CounterButton(
                        icon: Icons.remove_rounded,
                        enabled: !isMin,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          cubit.decrement();
                        },
                      ),
                      _AnimatedCountDisplay(count: count),
                      _CounterButton(
                        icon: Icons.add_rounded,
                        enabled: !isMax,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          cubit.increment();
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 14.h),
                  _ProgressBar(count: count, maxCount: maxDuplicateCount),
                ],
              ),
            ),
            if (isMax && maxDuplicateCount > 1) ...[
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: AppColors.danger.withValues(alpha: 0.25),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 14.sp,
                      color: AppColors.danger,
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        'Đã đạt giới hạn $maxDuplicateCount phòng trong lượt này!',
                        style: AppTypography.medium12(color: AppColors.danger),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildActions(BuildContext context) {
    return BlocBuilder<DuplicateRoomCubit, int>(
      builder: (context, count) {
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => context.pop(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textMuted,
                  side: BorderSide(
                    color: AppColors.textDisabled.withValues(alpha: 0.4),
                    width: 0.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
                child: Text(
                  'Hủy',
                  style: AppTypography.medium14(color: AppColors.textMuted),
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.pop();
                  onConfirm(count);
                },
                icon: Icon(Icons.content_copy_rounded, size: 16.sp),
                label: Text('Tạo $count bản sao'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  textStyle: AppTypography.medium14(color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CounterButton extends StatelessWidget {
  const _CounterButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 40.w,
        height: 40.w,
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.primary.withValues(alpha: 0.08)
              : AppColors.textDisabled.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: enabled
                ? AppColors.primary.withValues(alpha: 0.25)
                : AppColors.textDisabled.withValues(alpha: 0.15),
            width: 0.5,
          ),
        ),
        child: Icon(
          icon,
          size: 20.sp,
          color: enabled ? AppColors.primary : AppColors.textDisabled,
        ),
      ),
    );
  }
}

class _AnimatedCountDisplay extends StatelessWidget {
  const _AnimatedCountDisplay({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      transitionBuilder: (child, animation) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.elasticOut),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: Text(
        '$count',
        key: ValueKey(count),
        style: AppTypography.bold36(color: AppColors.textPrimary),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.count, required this.maxCount});

  final int count;
  final int maxCount;

  static const int _min = 1;

  @override
  Widget build(BuildContext context) {
    final span = maxCount - _min;
    final progress = span <= 0 ? 1.0 : (count - _min) / span;

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4.r),
          child: SizedBox(
            height: 4.h,
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0) * 0.9 + 0.1,
              backgroundColor: AppColors.textDisabled.withValues(alpha: 0.15),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ),
        SizedBox(height: 4.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$_min',
              style: AppTypography.medium14(color: AppColors.textMuted),
            ),
            Text(
              '$maxCount',
              style: AppTypography.medium14(color: AppColors.textMuted),
            ),
          ],
        ),
      ],
    );
  }
}
