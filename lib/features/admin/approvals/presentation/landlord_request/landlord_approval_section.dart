import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/route/app_routes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_style.dart';
import '../../../../../core/widgets/app_alerts.dart';
import '../../blocs/approval_filter/approval_filter_cubit.dart';
import '../../blocs/approval_filter/approval_filter_state.dart';
import '../../blocs/approvals_search/approvals_search_cubit.dart';
import '../../blocs/approvals_search/approvals_search_state.dart';
import '../../blocs/landlord_requests/landlord_requests_cubit.dart';
import '../../blocs/landlord_requests/landlord_requests_state.dart';
import '../../data/models/landlord_request.dart';
import '../approvals_tab/widgets/filter_chips.dart';
import 'landlord_application_card.dart';
import '../approvals_tab/widgets/reject_reason_dialog.dart';

class LandlordApprovalSection extends StatelessWidget {
  const LandlordApprovalSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BlocBuilder<LandlordRequestsCubit, LandlordRequestsState>(
          buildWhen: (prev, curr) => prev.pendingCount != curr.pendingCount,
          builder: (context, requestsState) {
            return FilterChips(
              showPendingUpdate: false,
              pendingCount: requestsState.pendingCount,
            );
          },
        ),
        Expanded(
          child: BlocBuilder<LandlordRequestsCubit, LandlordRequestsState>(
            builder: (context, requestsState) {
              if (requestsState.status == LandlordRequestsStatus.initial ||
                  (requestsState.status == LandlordRequestsStatus.loading &&
                      requestsState.items.isEmpty)) {
                return const _LoadingState();
              }
              if (requestsState.status == LandlordRequestsStatus.failure &&
                  requestsState.items.isEmpty) {
                return _ErrorState(
                  message: requestsState.errorMessage ?? 'Có lỗi xảy ra',
                );
              }
              return BlocBuilder<ApprovalFilterCubit, ApprovalFilterState>(
                buildWhen: (prev, curr) =>
                    prev.currentFilter != curr.currentFilter,
                builder: (context, filterState) {
                  return BlocBuilder<ApprovalsSearchCubit, ApprovalsSearchState>(
                    buildWhen: (prev, curr) =>
                        prev.searchQuery != curr.searchQuery,
                    builder: (context, searchState) {
                      final baseItems = requestsState.itemsForFilter(
                        filterState.currentFilter,
                      );
                      final items = requestsState.displayItemsForFilter(
                        filterState.currentFilter,
                        searchState.searchQuery,
                      );
                      if (baseItems.isEmpty) {
                        return const _EmptyState();
                      }
                      if (items.isEmpty) {
                        return const _EmptySearchState();
                      }
                      return _LandlordApprovalList(items: items);
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _LandlordApprovalList extends StatelessWidget {
  const _LandlordApprovalList({required this.items});

  final List<LandlordRequest> items;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
      itemCount: items.length,
      separatorBuilder: (context, index) {
        if (index >= items.length - 1) {
          return const SizedBox.shrink();
        }
        return AppSizes.gapH12;
      },
      itemBuilder: (context, index) {
        final request = items[index];
        final isPending = request.status == LandlordRequestStatus.pending;
        return LandlordApplicationCard(
          data: LandlordApplication(
            name: request.fullName.isEmpty ? 'Không tên' : request.fullName,
            phone: request.phone.isEmpty ? '—' : request.phone,
          ),
          onTap: () => context.push(
            '${RouteNames.landlordRequestDetail}/${request.userId}',
            extra: request,
          ),
          onApprove: isPending ? () => _onApprove(context, request) : null,
          onReject: isPending ? () => _onReject(context, request) : null,
        );
      },
    );
  }

  Future<void> _onApprove(BuildContext context, LandlordRequest request) async {
    final cubit = context.read<LandlordRequestsCubit>();
    final result = await cubit.approve(request.userId);
    if (!context.mounted) {
      return;
    }
    final alerts = Alerts.of(context);
    result.fold(
      (msg) => alerts.showError(msg),
      (_) => alerts.showSuccess('Đã duyệt hồ sơ của ${request.fullName}'),
    );
  }

  Future<void> _onReject(BuildContext context, LandlordRequest request) async {
    final reason = await showRejectReasonDialog(
      context,
      fullName: request.fullName,
    );
    if (reason == null || reason.trim().isEmpty) {
      return;
    }
    if (!context.mounted) {
      return;
    }
    final cubit = context.read<LandlordRequestsCubit>();
    final result = await cubit.reject(request.userId, reason.trim());
    if (!context.mounted) {
      return;
    }
    final alerts = Alerts.of(context);
    result.fold(
      (msg) => alerts.showError(msg),
      (_) => alerts.showSuccess('Đã từ chối hồ sơ của ${request.fullName}'),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 32.w,
        height: 32.w,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 32.sp, color: AppColors.error),
            AppSizes.gapH12,
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.medium14(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Text(
          'Chưa có dữ liệu',
          textAlign: TextAlign.center,
          style: AppTypography.medium14(color: AppColors.textMuted),
        ),
      ),
    );
  }
}

class _EmptySearchState extends StatelessWidget {
  const _EmptySearchState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Text(
          'Không tìm thấy kết quả',
          textAlign: TextAlign.center,
          style: AppTypography.medium14(color: AppColors.textMuted),
        ),
      ),
    );
  }
}
