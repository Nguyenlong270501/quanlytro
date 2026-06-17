import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../../core/constants/app_sizes.dart';
import '../../../../../../../core/theme/app_colors.dart';
import '../../../../../../../core/theme/app_style.dart';
import '../../../../blocs/step1/step1_cubit.dart';
import '../../../../blocs/step1/step1_state.dart';
import '../../../shared_widgets/section_card.dart';

class QuotaSection extends StatelessWidget {
  const QuotaSection({
    super.key,
    required this.cubit,
    required this.state,
  });

  final Step1Cubit cubit;
  final Step1State state;

  @override
  Widget build(BuildContext context) {
    final showErr = state.showErrors;
    final quotaErr = showErr && !state.isQuotaSelectionValid;
    return SectionCard(
      emoji: '📋',
      title: 'Hạn mức khu trọ',
      subtitle: state.quotaSelectionLocked
          ? 'Hạn mức đã gắn với bài đăng — không đổi được khi chỉnh sửa.'
          : 'Chọn một slot hạn mức còn trống do admin cấp sau khi duyệt đơn chủ trọ.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state.quotaLoadStatus == PropertyQuotaLoadStatus.loading)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: Center(
                child: SizedBox(
                  width: 28.w,
                  height: 28.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.primary,
                  ),
                ),
              ),
            )
          else if (state.quotaLoadStatus == PropertyQuotaLoadStatus.failure)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.quotaLoadError ?? 'Không tải được danh sách hạn mức.',
                  style: AppTypography.medium12(color: AppColors.danger),
                ),
                AppSizes.gapH8,
                TextButton(
                  onPressed: cubit.loadUnusedQuotas,
                  child: Text(
                    'Thử lại',
                    style: AppTypography.bold14(color: AppColors.primary),
                  ),
                ),
              ],
            )
          else if (state.quotaSelectionLocked)
            _LockedQuotaBody(state: state)
          else if (state.availableQuotas.isEmpty)
            Text(
              'Bạn đã sử dụng hết slot khu trọ. Vui lòng liên hệ admin để được cấp slot mới.',
              style: AppTypography.medium14(color: AppColors.textMuted),
            )
          else
            _AvailableQuotaPicker(cubit: cubit, state: state),
          if (quotaErr)
            Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: Text(
                state.quotaSelectionLocked
                    ? 'Thiếu mã hạn mức trên bài đăng.'
                    : (state.availableQuotas.isEmpty
                          ? 'Cần ít nhất một hạn mức trống để đăng tin.'
                          : 'Vui lòng chọn một hạn mức.'),
                style: AppTypography.medium12(color: AppColors.danger),
              ),
            ),
        ],
      ),
    );
  }
}

class _AvailableQuotaPicker extends StatelessWidget {
  const _AvailableQuotaPicker({
    required this.cubit,
    required this.state,
  });

  final Step1Cubit cubit;
  final Step1State state;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: state.availableQuotas.asMap().entries.map((entry) {
              final index = entry.key;
              final quota = entry.value;
              final selected = state.selectedQuotaId == quota.quotaId;

              return Padding(
                padding: EdgeInsets.only(right: 10.w),
                child: ChoiceChip(
                  label: Text(
                    'Slot ${index + 1} (${quota.maxRooms} phòng)',
                    style: AppTypography.medium12(
                      color: selected
                          ? AppColors.surface
                          : AppColors.textPrimary,
                    ),
                  ),
                  selected: selected,
                  onSelected: (_) => cubit.selectQuota(quota.quotaId),
                  showCheckmark: false,
                  backgroundColor: AppColors.surface,
                  selectedColor: AppColors.primary,
                  elevation: 0,
                  pressElevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: selected
                          ? AppColors.primary
                          : AppColors.primary.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        if (state.selectedQuotaId != null) ...[
          AppSizes.gapH8,
          Text(
            'Đã chọn Slot ${state.availableQuotas.indexWhere((q) => q.quotaId == state.selectedQuotaId) + 1}. Bạn được phép tạo tối đa ${state.availableQuotas.firstWhere((q) => q.quotaId == state.selectedQuotaId).maxRooms} phòng.',
            style: AppTypography.medium12(color: AppColors.textMuted),
          ),
        ] else ...[
          AppSizes.gapH8,
          Text(
            'Vui lòng chọn 1 hạn mức để tiếp tục',
            style: AppTypography.medium12(color: AppColors.error),
          ),
        ],
      ],
    );
  }
}

class _LockedQuotaBody extends StatelessWidget {
  const _LockedQuotaBody({required this.state});

  final Step1State state;

  @override
  Widget build(BuildContext context) {
    final snap = state.lockedQuotaSnapshot;
    final id = state.selectedQuotaId?.trim() ?? '';
    if (snap != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tối đa ${snap.maxRooms} phòng',
            style: AppTypography.bold14(color: AppColors.textPrimary),
          ),
          AppSizes.gapH4,
          Text(
            'Mã slot: $id',
            style: AppTypography.medium12(color: AppColors.textMuted),
          ),
        ],
      );
    }
    if (id.isNotEmpty) {
      return Text(
        'Mã hạn mức: $id',
        style: AppTypography.medium14(color: AppColors.textPrimary),
      );
    }
    return Text('—', style: AppTypography.medium14(color: AppColors.textMuted));
  }
}
