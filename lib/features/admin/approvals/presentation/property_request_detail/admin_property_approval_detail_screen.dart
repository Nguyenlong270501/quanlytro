import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_style.dart';
import '../../../../../core/widgets/app_alerts.dart';
import '../../../../landlord/create_property/data/models/property_model.dart';
import '../../../../landlord/create_property/presentation/steps/step4/widgets/image_carousel.dart';
import '../../blocs/admin_property_detail/admin_property_detail_cubit.dart';
import '../../blocs/admin_property_detail/admin_property_detail_state.dart';
import '../../data/repositories/admin_property_approvals/admin_property_approval_repository_impl.dart';
import '../landlord_request_detail/widgets/detail_action_bar.dart';
import '../landlord_request_detail/widgets/detail_status_banner.dart';
import '../property_request/widgets/admin_pending_room_list.dart';
import '../property_request/widgets/pending_update_display_formatter.dart';
import '../property_request/widgets/pending_value_banner.dart';
import '../approvals_tab/widgets/reject_reason_dialog.dart';
import 'widgets/property_detail_amenities_section.dart';
import 'widgets/property_detail_building_cost_section.dart';
import 'widgets/property_detail_landlord_section.dart';
import 'widgets/property_detail_rejected_reason_banner.dart';
import 'widgets/property_detail_rooms_section.dart';

class AdminPropertyApprovalDetailScreen extends StatelessWidget {
  const AdminPropertyApprovalDetailScreen({super.key, required this.property});

  final PropertyModel property;

  String _fallback(String value, String placeholder) =>
      value.trim().isEmpty ? placeholder : value;

  Future<void> _handleApprove(
    BuildContext context,
    PropertyModel currentProperty,
  ) async {
    final title = _fallback(currentProperty.title, 'bài đăng này');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Duyệt bài đăng',
          style: AppTypography.bold16(color: AppColors.textPrimary),
        ),
        content: Text(
          'Xác nhận duyệt bài đăng "$title"?',
          style: AppTypography.medium14(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => dialogContext.pop(false),
            child: Text(
              'Huỷ',
              style: AppTypography.bold14(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => dialogContext.pop(true),
            child: Text(
              'Xác nhận',
              style: AppTypography.bold14(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<AdminPropertyDetailCubit>().approveProperty(
        currentProperty.propertyId,
      );
    }
  }

  Future<void> _handleApprovePendingUpdate(
    BuildContext context,
    PropertyModel currentProperty,
  ) async {
    final title = _fallback(currentProperty.title, 'bài đăng này');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Duyệt chỉnh sửa',
          style: AppTypography.bold16(color: AppColors.textPrimary),
        ),
        content: Text(
          'Xác nhận duyệt chỉnh sửa của "$title"?',
          style: AppTypography.medium14(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => dialogContext.pop(false),
            child: Text(
              'Huỷ',
              style: AppTypography.bold14(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => dialogContext.pop(true),
            child: Text(
              'Xác nhận',
              style: AppTypography.bold14(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final reviewedBy = FirebaseAuth.instance.currentUser?.uid ?? '';
    context.read<AdminPropertyDetailCubit>().approvePendingUpdate(
      propertyId: currentProperty.propertyId,
      reviewedBy: reviewedBy,
    );
  }

  Future<void> _handleRejectPendingUpdate(
    BuildContext context,
    PropertyModel currentProperty,
  ) async {
    final reason = await showRejectReasonDialog(
      context,
      fullName: currentProperty.title.isEmpty
          ? 'chỉnh sửa'
          : currentProperty.title,
    );
    if (reason != null && reason.trim().isNotEmpty && context.mounted) {
      final reviewedBy = FirebaseAuth.instance.currentUser?.uid ?? '';
      context.read<AdminPropertyDetailCubit>().rejectPendingUpdate(
        propertyId: currentProperty.propertyId,
        reviewedBy: reviewedBy,
        reason: reason.trim(),
      );
    }
  }

  Future<void> _handleReject(
    BuildContext context,
    PropertyModel currentProperty,
  ) async {
    final reason = await showRejectReasonDialog(
      context,
      fullName: currentProperty.title.isEmpty
          ? 'bài đăng'
          : currentProperty.title,
    );

    if (reason != null && reason.trim().isNotEmpty && context.mounted) {
      context.read<AdminPropertyDetailCubit>().rejectProperty(
        currentProperty.propertyId,
        reason.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdminPropertyDetailCubit(
        context.read<AdminPropertyApprovalRepositoryImpl>(),
        initialProperty: property,
      )..init(),
      child: BlocConsumer<AdminPropertyDetailCubit, AdminPropertyDetailState>(
        listenWhen: (previous, current) =>
            previous.errorMessage != current.errorMessage ||
            previous.successMessage != current.successMessage,
        listener: (context, state) {
          if (state.errorMessage != null) {
            Alerts.of(context).showError(state.errorMessage!);
          } else if (state.successMessage != null) {
            Alerts.of(context).showSuccess(state.successMessage!);
            context.pop();
          }
        },
        builder: (context, state) {
          final currentProperty = state.property;
          final pending = currentProperty.status == PropertyStatus.pending;
          final pendingUpdate = currentProperty.hasPendingUpdate;
          final pendingIndex =
              pendingUpdate && currentProperty.pendingUpdate != null
              ? PendingUpdateDisplayFormatter.buildIndex(
                  property: currentProperty,
                  pending: currentProperty.pendingUpdate!,
                )
              : null;
          final rooms = currentProperty.rooms ?? [];
          final roomListEntries = AdminPendingRoomList.buildEntries(
            property: currentProperty,
            liveRooms: rooms,
            pendingIndex: pendingIndex,
          );
          final roomCount = rooms.length + (pendingIndex?.newRooms.length ?? 0);
          final roomsSectionLoading =
              state.isRoomsLoading && currentProperty.rooms == null;
          final isBusy = state.isSubmitting;

          return Scaffold(
            backgroundColor: AppColors.scaffoldBackground,
            appBar: AppBar(
              title: Text(
                'Chi tiết bài đăng',
                style: AppTypography.bold18(color: AppColors.textPrimary),
              ),
              centerTitle: true,
              backgroundColor: Colors.white,
              elevation: 0,
              scrolledUnderElevation: 0,
              iconTheme: const IconThemeData(color: AppColors.textPrimary),
              leading: IconButton(
                onPressed: isBusy ? null : () => context.pop(),
                icon: Icon(
                  Icons.arrow_back,
                  color: AppColors.textPrimary,
                  size: 24.sp,
                ),
              ),
            ),
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: AbsorbPointer(
                      absorbing: isBusy,
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (pendingUpdate) ...[
                              const PendingUpdateHintBanner(),
                              AppSizes.gapH12,
                            ],
                            if (currentProperty.status ==
                                    PropertyStatus.pending &&
                                currentProperty.rejectedReason != null &&
                                currentProperty.rejectedReason!.isNotEmpty) ...[
                              PropertyDetailRejectedReasonBanner(
                                reason: currentProperty.rejectedReason!,
                              ),
                              AppSizes.gapH10,
                            ],
                            if (currentProperty.imageUrls != null &&
                                currentProperty.imageUrls!.isNotEmpty)
                              PendingFieldBlock(
                                pending: pendingIndex?.property('imageUrls'),
                                pendingCaption: 'Ảnh tòa nhà',
                                child: Container(
                                  height: 200.h,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: ImageCarousel(
                                    images: currentProperty.imageUrls!,
                                  ),
                                ),
                              ),
                            if (currentProperty.imageUrls != null &&
                                currentProperty.imageUrls!.isNotEmpty)
                              AppSizes.gapH16,

                            PropertyDetailLandlordSection(
                              landlordId: currentProperty.landlordId,
                            ),
                            AppSizes.gapH16,

                            PropertyDetailBuildingCostSection(
                              property: currentProperty,
                              pendingIndex: pendingIndex,
                            ),
                            AppSizes.gapH16,

                            PropertyDetailAmenitiesSection(
                              property: currentProperty,
                              pendingIndex: pendingIndex,
                            ),
                            AppSizes.gapH16,

                            PropertyDetailRoomsSection(
                              roomCount: roomCount,
                              isLoading: roomsSectionLoading,
                              entries: roomListEntries,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  if (pending)
                    DetailActionBar(
                      isSubmitting: isBusy,
                      loadingReject: state.isRejecting,
                      loadingApprove: state.isApproving,
                      onApprove: () => _handleApprove(context, currentProperty),
                      onReject: () => _handleReject(context, currentProperty),
                    )
                  else if (pendingUpdate)
                    DetailActionBar(
                      isSubmitting: isBusy,
                      loadingReject: state.isRejecting,
                      loadingApprove: state.isApproving,
                      onApprove: () =>
                          _handleApprovePendingUpdate(context, currentProperty),
                      onReject: () =>
                          _handleRejectPendingUpdate(context, currentProperty),
                    )
                  else
                    DetailStatusBanner(
                      isApproved:
                          currentProperty.status == PropertyStatus.approved,
                      statusTitle:
                          currentProperty.status == PropertyStatus.approved
                          ? 'Bài đăng đã được duyệt'
                          : 'Bài đăng đã bị từ chối',
                      rejectionReason: currentProperty.rejectedReason,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
