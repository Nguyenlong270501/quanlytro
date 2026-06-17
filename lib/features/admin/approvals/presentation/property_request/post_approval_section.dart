import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/route/app_routes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_style.dart';
import '../../../../../core/widgets/app_alerts.dart';
import '../../../../landlord/create_property/data/models/property_model.dart';
import '../../blocs/approval_filter/approval_filter_cubit.dart';
import '../../blocs/approval_filter/approval_filter_state.dart';
import '../../blocs/approvals_search/approvals_search_cubit.dart';
import '../../blocs/approvals_search/approvals_search_state.dart';
import '../../blocs/admin_property_approvals/admin_property_approvals_cubit.dart';
import '../../blocs/admin_property_approvals/admin_property_approvals_state.dart';
import '../../data/models/admin_property_approval_detail_args.dart';
import '../../data/models/landlord_summary.dart';
import '../approvals_tab/widgets/filter_chips.dart';
import '../approvals_tab/widgets/reject_reason_dialog.dart';
import 'property_approval_card.dart';

class PostApprovalSection extends StatelessWidget {
  const PostApprovalSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BlocBuilder<AdminPropertyApprovalsCubit, AdminPropertyApprovalsState>(
          buildWhen: (prev, curr) =>
              prev.pendingCount != curr.pendingCount ||
              prev.pendingUpdateCount != curr.pendingUpdateCount,
          builder: (context, propState) {
            return FilterChips(
              pendingCount: propState.pendingCount,
              pendingUpdateCount: propState.pendingUpdateCount,
            );
          },
        ),
        Expanded(
          child: BlocBuilder<AdminPropertyApprovalsCubit,
              AdminPropertyApprovalsState>(
            builder: (context, propState) {
              if (propState.status == AdminPropertyApprovalsStatus.initial ||
                  (propState.status == AdminPropertyApprovalsStatus.loading &&
                      propState.items.isEmpty)) {
                return const _LoadingState();
              }
              if (propState.status == AdminPropertyApprovalsStatus.failure &&
                  propState.items.isEmpty) {
                return _ErrorState(
                  message: propState.errorMessage ?? 'Có lỗi xảy ra',
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
                      final baseItems = propState.itemsForFilter(
                        filterState.currentFilter,
                      );
                      final items = propState.displayItemsForFilter(
                        filterState.currentFilter,
                        searchState.searchQuery,
                      );
                      if (baseItems.isEmpty) {
                        return const _EmptyState();
                      }
                      if (items.isEmpty) {
                        return const _EmptySearchState();
                      }
                      return _PostApprovalList(
                        items: items,
                        landlordSummaries: propState.landlordSummaries,
                      );
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

class _PostApprovalList extends StatelessWidget {
  const _PostApprovalList({
    required this.items,
    required this.landlordSummaries,
  });

  final List<PropertyModel> items;
  final Map<String, LandlordSummary> landlordSummaries;

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
        final property = items[index];
        final isNewPending = property.status == PropertyStatus.pending;
        final isPendingUpdate = property.hasPendingUpdate;
        final landlordSummary = property.landlordId.isEmpty
            ? null
            : landlordSummaries[property.landlordId];
        return PropertyApprovalCard(
          property: property,
          landlordSummary: landlordSummary,
          showPendingEditBadge: isPendingUpdate,
          onTap: () => context.push(
            RouteNames.adminPropertyApprovalDetail,
            extra: AdminPropertyApprovalDetailArgs(property: property),
          ),
          onApprove: isNewPending
              ? () => _onApprove(context, property)
              : isPendingUpdate
              ? () => _onApprovePendingUpdate(context, property)
              : null,
          onReject: isNewPending
              ? () => _onReject(context, property)
              : isPendingUpdate
              ? () => _onRejectPendingUpdate(context, property)
              : null,
        );
      },
    );
  }

  Future<void> _onApprove(BuildContext context, PropertyModel property) async {
    final cubit = context.read<AdminPropertyApprovalsCubit>();
    final result = await cubit.approve(property.propertyId);
    if (!context.mounted) {
      return;
    }
    final alerts = Alerts.of(context);
    result.fold(
      (msg) => alerts.showError(msg),
      (_) => alerts.showSuccess('Đã duyệt bài: ${property.title}'),
    );
  }

  Future<void> _onApprovePendingUpdate(
    BuildContext context,
    PropertyModel property,
  ) async {
    final reviewedBy = FirebaseAuth.instance.currentUser?.uid ?? '';
    final cubit = context.read<AdminPropertyApprovalsCubit>();
    final result = await cubit.approvePendingUpdate(
      propertyId: property.propertyId,
      reviewedBy: reviewedBy,
    );
    if (!context.mounted) return;
    final alerts = Alerts.of(context);
    result.fold(
      (msg) => alerts.showError(msg),
      (_) => alerts.showSuccess('Đã duyệt chỉnh sửa: ${property.title}'),
    );
  }

  Future<void> _onRejectPendingUpdate(
    BuildContext context,
    PropertyModel property,
  ) async {
    final reason = await showRejectReasonDialog(
      context,
      fullName: property.title.isEmpty ? 'chỉnh sửa' : property.title,
    );
    if (reason == null || reason.trim().isEmpty) return;
    if (!context.mounted) return;
    final reviewedBy = FirebaseAuth.instance.currentUser?.uid ?? '';
    final cubit = context.read<AdminPropertyApprovalsCubit>();
    final result = await cubit.rejectPendingUpdate(
      propertyId: property.propertyId,
      reviewedBy: reviewedBy,
      reason: reason.trim(),
    );
    if (!context.mounted) return;
    final alerts = Alerts.of(context);
    result.fold(
      (msg) => alerts.showError(msg),
      (_) => alerts.showSuccess('Đã từ chối chỉnh sửa'),
    );
  }

  Future<void> _onReject(BuildContext context, PropertyModel property) async {
    final reason = await showRejectReasonDialog(
      context,
      fullName: property.title.isEmpty ? 'bài đăng' : property.title,
    );
    if (reason == null || reason.trim().isEmpty) {
      return;
    }
    if (!context.mounted) {
      return;
    }
    final cubit = context.read<AdminPropertyApprovalsCubit>();
    final result = await cubit.reject(property.propertyId, reason.trim());
    if (!context.mounted) {
      return;
    }
    final alerts = Alerts.of(context);
    result.fold(
      (msg) => alerts.showError(msg),
      (_) => alerts.showSuccess('Đã từ chối bài đăng'),
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
