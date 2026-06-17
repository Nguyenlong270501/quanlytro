import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/route/app_routes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_style.dart';
import '../../../appointment/data/models/appointment_model.dart';
import '../../blocs/appointments_feed/appointments_feed_cubit.dart';
import '../../blocs/appointments_feed/appointments_feed_state.dart';

class AppointmentsPanel extends StatelessWidget {
  const AppointmentsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppointmentsFeedCubit, AppointmentsFeedState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
              child: _FilterChips(state: state),
            ),
            Expanded(child: _AppointmentsListBody(state: state)),
          ],
        );
      },
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.state});

  final AppointmentsFeedState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AppointmentsFeedCubit>();

    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: [
        ChoiceChip(
          label: Text('Chờ xác nhận (${state.pendingCount})'),
          selected: state.selectedFilter == AppointmentListFilter.pending,
          onSelected: (_) => cubit.selectFilter(AppointmentListFilter.pending),
          labelStyle: AppTypography.medium12(
            color: state.selectedFilter == AppointmentListFilter.pending
                ? AppColors.surface
                : AppColors.textPrimary,
          ),
          selectedColor: AppColors.primary,
          backgroundColor: AppColors.surface,
          side: const BorderSide(color: AppColors.border),
          showCheckmark: false,
        ),
        ChoiceChip(
          label: const Text('Sắp tới'),
          selected: state.selectedFilter == AppointmentListFilter.upcoming,
          onSelected: (_) => cubit.selectFilter(AppointmentListFilter.upcoming),
          labelStyle: AppTypography.medium12(
            color: state.selectedFilter == AppointmentListFilter.upcoming
                ? AppColors.surface
                : AppColors.textPrimary,
          ),
          selectedColor: AppColors.primary,
          backgroundColor: AppColors.surface,
          side: const BorderSide(color: AppColors.border),
          showCheckmark: false,
        ),
        ChoiceChip(
          label: const Text('Lịch sử'),
          selected: state.selectedFilter == AppointmentListFilter.history,
          onSelected: (_) => cubit.selectFilter(AppointmentListFilter.history),
          labelStyle: AppTypography.medium12(
            color: state.selectedFilter == AppointmentListFilter.history
                ? AppColors.surface
                : AppColors.textPrimary,
          ),
          selectedColor: AppColors.primary,
          backgroundColor: AppColors.surface,
          side: const BorderSide(color: AppColors.border),
          showCheckmark: false,
        ),
      ],
    );
  }
}

class _AppointmentsListBody extends StatefulWidget {
  const _AppointmentsListBody({required this.state});

  final AppointmentsFeedState state;

  @override
  State<_AppointmentsListBody> createState() => _AppointmentsListBodyState();
}

class _AppointmentsListBodyState extends State<_AppointmentsListBody> {
  final ScrollController _scrollController = ScrollController();
  static const double _loadMoreThreshold = 120;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }
    final position = _scrollController.position;
    if (position.pixels < position.maxScrollExtent - _loadMoreThreshold) {
      return;
    }
    final cubit = context.read<AppointmentsFeedCubit>();
    final state = cubit.state;
    if (state.isLoadingMoreSelected || !state.canLoadMoreSelected) {
      return;
    }
    cubit.loadMore();
  }

  String _emptyMessage(AppointmentListFilter filter) {
    return switch (filter) {
      AppointmentListFilter.pending => 'Không có lịch chờ xác nhận',
      AppointmentListFilter.upcoming => 'Không có lịch sắp tới',
      AppointmentListFilter.history => 'Chưa có lịch sử',
    };
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;

    if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Text(
            state.errorMessage!,
            style: AppTypography.medium14(color: AppColors.textPrimary),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (state.isLoadingSelected && state.selectedItems.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final items = state.selectedItems;
    if (items.isEmpty) {
      return Center(
        child: Text(
          _emptyMessage(state.selectedFilter),
          style: AppTypography.medium14(color: AppColors.textPrimary),
        ),
      );
    }

    final dimPast = state.selectedFilter == AppointmentListFilter.history;
    final showLoadMoreFooter = state.isLoadingMoreSelected;
    final itemCount = items.length + (showLoadMoreFooter ? 1 : 0);

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index >= items.length) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }
        final item = items[index];
        final card = _AppointmentCard(item: item);
        if (dimPast) {
          return Opacity(opacity: 0.7, child: card);
        }
        return card;
      },
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({required this.item});

  final AppointmentModel item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(
        RouteNames.landlordAppointmentDetail,
        extra: item,
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.propertyTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bold14(color: AppColors.textPrimary),
                  ),
                ),
                _StatusBadge(status: item.status),
              ],
            ),
            AppSizes.gapH6,
            Text(
              item.propertyAddress,
              style: AppTypography.medium12(color: AppColors.textSecondary),
            ),
            AppSizes.gapH6,
            Text(
              '${item.appointmentDate.hour.toString().padLeft(2, '0')}:${item.appointmentDate.minute.toString().padLeft(2, '0')} - ${item.appointmentDate.day}/${item.appointmentDate.month}/${item.appointmentDate.year}',
              style: AppTypography.bold14(color: AppColors.primary),
            ),
          ],
        ),
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
