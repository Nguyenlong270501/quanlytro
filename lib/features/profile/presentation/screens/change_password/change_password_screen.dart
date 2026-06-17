import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_style.dart';
import '../../../../../core/widgets/app_alerts.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_text_field.dart';
import '../../../blocs/change_password_form/change_password_form_cubit.dart';
import '../../../blocs/change_password_form/change_password_form_state.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Widget _ruleItem({required bool passed, required String text}) {
    return Row(
      children: [
        Icon(
          passed
              ? Icons.check_circle_rounded
              : Icons.radio_button_unchecked_rounded,
          size: 16,
          color: passed ? AppColors.primary : AppColors.textMuted,
        ),
        AppSizes.gapW8,
        Text(
          text,
          style: AppTypography.medium14(
            color: passed ? AppColors.primary : AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Đổi mật khẩu'),
        backgroundColor: AppColors.scaffoldBackground,
      ),
      body: BlocListener<ChangePasswordFormCubit, ChangePasswordFormState>(
        listenWhen: (previous, current) =>
            previous.errorMessage != current.errorMessage ||
            previous.successMessage != current.successMessage,
        listener: (context, state) {
          if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
            Alerts.of(context).showError(state.errorMessage!);
            context.read<ChangePasswordFormCubit>().clearFeedback();
            return;
          }
          if (state.successMessage != null &&
              state.successMessage!.isNotEmpty) {
            Alerts.of(context).showSuccess(state.successMessage!);
            context.read<ChangePasswordFormCubit>().clearFeedback();
            context.pop();
          }
        },
        child: BlocBuilder<ChangePasswordFormCubit, ChangePasswordFormState>(
          builder: (context, state) {
            final password = state.newPassword.value.trim();
            final hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
            final hasDigit = RegExp(r'\d').hasMatch(password);
            final hasMinLength = password.length >= 8;
            final isLoading = state.status == FormzSubmissionStatus.inProgress;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Điền các thông tin để đổi mật khẩu',
                    style: AppTypography.medium16(color: AppColors.textMuted),
                  ),
                  AppSizes.gapH16,
                  MyAppTextfield(
                    label: 'Mật khẩu hiện tại',
                    controller: _currentPasswordController,
                    hintText: 'Mật khẩu hiện tại',
                    obscureText: state.isCurrentPasswordObscure,
                    suffixIcon: Icons.visibility,
                    onSuffixIconTap: context
                        .read<ChangePasswordFormCubit>()
                        .toggleCurrentPasswordObscure,
                    onChanged: context
                        .read<ChangePasswordFormCubit>()
                        .currentPasswordChanged,
                  ),
                  AppSizes.gapH12,
                  MyAppTextfield(
                    label: 'Mật khẩu mới',
                    controller: _newPasswordController,
                    hintText: 'Mật khẩu mới',
                    obscureText: state.isNewPasswordObscure,
                    suffixIcon: Icons.visibility,
                    onSuffixIconTap: context
                        .read<ChangePasswordFormCubit>()
                        .toggleNewPasswordObscure,
                    onChanged: context
                        .read<ChangePasswordFormCubit>()
                        .newPasswordChanged,
                  ),
                  AppSizes.gapH12,
                  _ruleItem(
                    passed: hasUppercase,
                    text: 'Có ít nhất 1 chữ viết hoa',
                  ),
                  AppSizes.gapH6,
                  _ruleItem(passed: hasDigit, text: 'Có ít nhất 1 chữ số'),
                  AppSizes.gapH6,
                  _ruleItem(
                    passed: hasMinLength,
                    text: 'Độ dài từ 8 ký tự trở lên',
                  ),
                  AppSizes.gapH12,
                  MyAppTextfield(
                    label: 'Nhập lại mật khẩu mới',
                    controller: _confirmPasswordController,
                    hintText: 'Nhập lại mật khẩu mới',
                    obscureText: state.isConfirmPasswordObscure,
                    suffixIcon: Icons.visibility,
                    onSuffixIconTap: context
                        .read<ChangePasswordFormCubit>()
                        .toggleConfirmPasswordObscure,
                    onChanged: context
                        .read<ChangePasswordFormCubit>()
                        .confirmPasswordChanged,
                    errorText: state.confirmPassword.displayError != null
                        ? 'Mật khẩu xác nhận không khớp'
                        : null,
                  ),
                  AppSizes.gapH24,
                  AppButton(
                    text: 'Cập nhật mật khẩu',
                    isLoading: isLoading,
                    isEnabled: state.isValid && !isLoading,
                    onPressed: context.read<ChangePasswordFormCubit>().submit,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
