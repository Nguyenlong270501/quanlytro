import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/constants/app_sizes.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_style.dart';
import '../../../blocs/approval_filter/approval_filter_cubit.dart';
import '../../../blocs/approval_filter/approval_filter_state.dart';

class FilterChips extends StatelessWidget {
  const FilterChips({
    super.key,
    this.showPendingUpdate = true,
    this.pendingCount = 0,
    this.pendingUpdateCount = 0,
  });

  /// Tab Chủ trọ không có chỉnh sửa chờ duyệt — ẩn chip tương ứng.
  final bool showPendingUpdate;

  /// Số mục chờ duyệt mới (hiển thị `Chờ duyệt (n)` khi n > 0).
  final int pendingCount;

  /// Số bài có `pendingUpdate` (hiển thị `Chờ duyệt sửa (n)` khi n > 0).
  final int pendingUpdateCount;

  static const List<ApprovalFilter> _filters = [
    ApprovalFilter.pending,
    ApprovalFilter.pendingUpdate,
    ApprovalFilter.approved,
    ApprovalFilter.rejected,
  ];

  static const Map<ApprovalFilter, String> _labels = {
    ApprovalFilter.pending: 'Chờ duyệt',
    ApprovalFilter.pendingUpdate: 'Chờ duyệt sửa',
    ApprovalFilter.approved: 'Đã duyệt',
    ApprovalFilter.rejected: 'Từ chối',
  };

  List<ApprovalFilter> get _visibleFilters => showPendingUpdate
      ? _filters
      : _filters.where((f) => f != ApprovalFilter.pendingUpdate).toList();

  static String _countLabel(String base, int count) =>
      count > 0 ? '$base ($count)' : base;

  String _labelFor(ApprovalFilter filter) {
    final base = _labels[filter]!;
    return switch (filter) {
      ApprovalFilter.pending => _countLabel(base, pendingCount),
      ApprovalFilter.pendingUpdate when showPendingUpdate =>
        _countLabel(base, pendingUpdateCount),
      _ => base,
    };
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visibleFilters;
    return BlocBuilder<ApprovalFilterCubit, ApprovalFilterState>(
      buildWhen: (prev, curr) => prev.currentFilter != curr.currentFilter,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (int i = 0; i < visible.length; i++) ...[
                      if (i > 0) AppSizes.gapW8,
                      _Chip(
                        label: _labelFor(visible[i]),
                        selected: state.currentFilter == visible[i],
                        onTap: () => context
                            .read<ApprovalFilterCubit>()
                            .changeFilter(visible[i]),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: selected
              ? AppTypography.bold12(color: AppColors.surface)
              : AppTypography.medium12(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
