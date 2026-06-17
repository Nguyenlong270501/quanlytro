import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/app_enums.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_style.dart';
import '../../../../../core/widgets/app_alerts.dart';
import '../../../../../core/widgets/app_confirm_dialog.dart';
import '../../../../auth/data/models/user.dart';
import '../../blocs/admin_user_detail/admin_user_detail_cubit.dart';
import '../../blocs/admin_user_detail/admin_user_detail_state.dart';
import 'widgets/admin_user_actions_section.dart';
import 'widgets/role_status_section.dart';
import 'widgets/section_title.dart';
import 'widgets/user_metadata_section.dart';
import 'widgets/user_summary_card.dart';

class AdminUserDetailScreen extends StatelessWidget {
  const AdminUserDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AdminUserDetailCubit, AdminUserDetailState>(
      listenWhen: (prev, curr) =>
          prev.successMessage != curr.successMessage ||
          prev.errorMessage != curr.errorMessage,
      listener: _onStateChanged,
      child: Scaffold(
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
            'Chi tiết người dùng',
            style: AppTypography.bold20(color: AppColors.textPrimary),
          ),
        ),
        body: SafeArea(
          child: BlocBuilder<AdminUserDetailCubit, AdminUserDetailState>(
            buildWhen: (prev, curr) =>
                prev.user != curr.user ||
                prev.selectedStatus != curr.selectedStatus ||
                prev.isSaving != curr.isSaving ||
                prev.isResettingPassword != curr.isResettingPassword,
            builder: (context, state) {
              return AbsorbPointer(
                absorbing: state.isBusy,
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      UserSummaryCard(user: state.user),
                      AppSizes.gapH20,
                      const SectionTitle(title: 'Thông tin tài khoản'),
                      AppSizes.gapH12,
                      UserMetadataSection(user: state.user),
                      AppSizes.gapH24,
                      const SectionTitle(title: 'Trạng thái'),
                      AppSizes.gapH12,
                      RoleStatusSection(
                        selectedStatus: state.selectedStatus,
                        onStatusChanged: context
                            .read<AdminUserDetailCubit>()
                            .changeStatus,
                      ),
                      AppSizes.gapH24,
                      const SectionTitle(title: 'Thao tác'),
                      AppSizes.gapH12,
                      AdminUserActionsSection(
                        isBusy: state.isBusy,
                        hasChanges: state.hasChanges,
                        isSaving: state.isSaving,
                        isResettingPassword: state.isResettingPassword,
                        onSave: () => _handleSaveChanges(context, state),
                        onResetPassword: () =>
                            _handleResetPassword(context, state.user),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _onStateChanged(BuildContext context, AdminUserDetailState state) {
    final message = state.successMessage;
    final error = state.errorMessage;
    if (message != null) {
      _showSnackBar(
        context,
        message: message,
        backgroundColor: AppColors.primary,
      );
    } else if (error != null) {
      _showSnackBar(context, message: error, backgroundColor: AppColors.danger);
    }
  }

  Future<void> _handleSaveChanges(
    BuildContext context,
    AdminUserDetailState state,
  ) async {
    final confirmed = await AppConfirmDialog.show(
      context,
      title: 'Lưu thay đổi',
      message: 'Xác nhận cập nhật trạng thái của người dùng này?',
      confirmLabel: 'Lưu',
    );
    if (!confirmed || !context.mounted) {
      return;
    }
    await context.read<AdminUserDetailCubit>().saveChanges();
  }

  Future<void> _handleResetPassword(
    BuildContext context,
    UserModel user,
  ) async {
    if (user.authProvider == AuthProvider.google ||
        user.authProvider == AuthProvider.facebook) {
      Alerts.of(context).showWarning(
        'Tài khoản đăng nhập bằng mạng xã hội không hỗ trợ reset mật khẩu.',
      );
      return;
    }
    final confirmed = await AppConfirmDialog.show(
      context,
      title: 'Reset password',
      message:
          'Xác nhận reset password của người dùng này về mật khẩu mặc định?',
      confirmLabel: 'Reset',
    );
    if (!confirmed || !context.mounted) {
      return;
    }
    await context.read<AdminUserDetailCubit>().resetPassword();
  }

  void _showSnackBar(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: AppTypography.medium14(color: AppColors.surface),
          ),
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}
