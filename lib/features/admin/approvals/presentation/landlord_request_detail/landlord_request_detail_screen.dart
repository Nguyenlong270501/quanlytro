import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_style.dart';
import '../../../../../core/widgets/app_alerts.dart';
import '../../blocs/landlord_request_detail/landlord_request_detail_cubit.dart';
import '../../blocs/landlord_request_detail/landlord_request_detail_state.dart';
import '../../data/models/landlord_request.dart';
import 'widgets/detail_action_bar.dart';
import 'widgets/detail_info_field.dart';
import 'widgets/detail_status_banner.dart';
import 'widgets/id_card_section.dart';
import 'widgets/optional_docs_section.dart';
import '../approvals_tab/widgets/reject_reason_dialog.dart';
import 'widgets/property_quotas_section.dart';

class LandlordRequestDetailScreen extends StatelessWidget {
  const LandlordRequestDetailScreen({super.key, required this.request});

  final LandlordRequest request;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.textPrimary,
            size: 24.sp,
          ),
        ),
        title: Text(
          'Hồ sơ yêu cầu trở thành chủ trọ',
          style: AppTypography.bold16(color: AppColors.textPrimary),
        ),
      ),
      body:
          BlocListener<LandlordRequestDetailCubit, LandlordRequestDetailState>(
            listenWhen: (prev, curr) => prev.status != curr.status,
            listener: _onStateChanged,
            child:
                BlocBuilder<
                  LandlordRequestDetailCubit,
                  LandlordRequestDetailState
                >(
                  builder: (context, state) {
                    return SafeArea(
                      child: Column(
                        children: [
                          Expanded(
                            child: AbsorbPointer(
                              absorbing: state.isSubmitting,
                              child: SingleChildScrollView(
                                padding: EdgeInsets.fromLTRB(
                                  16.w,
                                  16.h,
                                  16.w,
                                  24.h,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    DetailInfoField(
                                      label: 'Họ và tên',
                                      icon: Icons.person_outline,
                                      value: _fallback(
                                        request.fullName,
                                        'Chưa có tên',
                                      ),
                                    ),
                                    AppSizes.gapH16,
                                    DetailInfoField(
                                      label: 'Số điện thoại',
                                      icon: Icons.phone_outlined,
                                      value: _fallback(request.phone, '—'),
                                    ),
                                    AppSizes.gapH16,
                                    DetailInfoField(
                                      label: 'Địa chỉ',
                                      icon: Icons.place_outlined,
                                      value: _fallback(request.address, '—'),
                                    ),
                                    AppSizes.gapH16,
                                    PropertyQuotasSection(
                                      numberOfRooms: request.numOfRoomsList,
                                    ),
                                    AppSizes.gapH20,
                                    IdCardSection(
                                      frontUrl: request.cccdFrontUrl,
                                      backUrl: request.cccdBackUrl,
                                    ),
                                    if (request
                                        .optionalDocumentUrls
                                        .isNotEmpty) ...[
                                      AppSizes.gapH24,
                                      OptionalDocsSection(
                                        urls: request.optionalDocumentUrls,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                          if (request.status == LandlordRequestStatus.pending)
                            DetailActionBar(
                              isSubmitting: state.isSubmitting,
                              loadingReject:
                                  state.isSubmitting &&
                                  state.action == DetailAction.reject,
                              loadingApprove:
                                  state.isSubmitting &&
                                  state.action == DetailAction.approve,
                              onApprove: () => _handleApprove(context),
                              onReject: () => _handleReject(context),
                            )
                          else
                            DetailStatusBanner(
                              isApproved:
                                  request.status ==
                                  LandlordRequestStatus.approved,
                              statusTitle:
                                  request.status ==
                                      LandlordRequestStatus.approved
                                  ? 'Hồ sơ đã được duyệt'
                                  : 'Hồ sơ đã bị từ chối',
                              rejectionReason: request.rejectionReason,
                            ),
                        ],
                      ),
                    );
                  },
                ),
          ),
    );
  }

  void _onStateChanged(BuildContext context, LandlordRequestDetailState state) {
    final alerts = Alerts.of(context);
    if (state.status == DetailSubmitStatus.success) {
      final message = state.action == DetailAction.approve
          ? 'Đã duyệt hồ sơ'
          : 'Đã từ chối hồ sơ';
      alerts.showSuccess(message);
      context.pop();
    } else if (state.status == DetailSubmitStatus.failure) {
      alerts.showError(state.errorMessage ?? 'Có lỗi xảy ra');
    }
  }

  Future<void> _handleApprove(BuildContext context) async {
    final cubit = context.read<LandlordRequestDetailCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Duyệt hồ sơ',
          style: AppTypography.bold16(color: AppColors.textPrimary),
        ),
        content: Text(
          'Xác nhận duyệt hồ sơ của ${_fallback(request.fullName, 'người dùng này')}?',
          style: AppTypography.medium14(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              'Huỷ',
              style: AppTypography.bold14(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              'Xác nhận',
              style: AppTypography.bold14(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await cubit.approve(request.userId);
    }
  }

  Future<void> _handleReject(BuildContext context) async {
    final cubit = context.read<LandlordRequestDetailCubit>();
    final reason = await showRejectReasonDialog(
      context,
      fullName: request.fullName,
    );
    if (reason != null && reason.trim().isNotEmpty) {
      await cubit.reject(request.userId, reason.trim());
    }
  }

  String _fallback(String value, String placeholder) =>
      value.trim().isEmpty ? placeholder : value;
}
