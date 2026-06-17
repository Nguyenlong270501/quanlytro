import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/route/app_routes.dart';
import '../../../../../core/theme/app_style.dart';
import '../../../../../core/widgets/app_alerts.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_text_field.dart';
import '../../../../../core/widgets/aurora_background.dart';
import '../../../blocs/authentication/auth_cubit.dart';
import '../../../blocs/authentication/auth_state.dart';
import '../../../blocs/forget_password_form/forget_password_form_cubit.dart';

class ForgetPasswordScreen extends StatelessWidget {
  const ForgetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthenticationCubit, AuthenticationState>(
        listener: (context, state) {
          if (state is PasswordResetEmailSentState) {
            Alerts.of(context).showSuccess(state.message);
            context.pop();
          } else if (state is AuthenticationErrorState) {
            Alerts.of(context).showError(state.error);
          }
        },
        child: Stack(
          children: [
            const AuroraBackground(darkMode: false),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppSizes.gapH16,
                        Center(
                          child: Image.asset(
                            'assets/icons/app_icon.png',
                            width: AppSizes.iconSizeXXLarge,
                            height: AppSizes.iconSizeXXLarge,
                          ),
                        ),
                        AppSizes.gapH8,
                        Text(
                          'Quên mật khẩu?',
                          textAlign: TextAlign.center,
                          style: AppTypography.medium26(color: Colors.black87),
                        ),
                        AppSizes.gapH8,
                        Text(
                          'Đừng lo lắng! Hãy nhập email đã đăng ký tài khoản để nhận liên kết đặt lại mật khẩu.',
                          textAlign: TextAlign.center,
                          style: AppTypography.medium14(color: Colors.black54),
                        ),
                        AppSizes.gapH24,
                        const _ForgetPasswordEmailField(),
                        AppSizes.gapH24,
                        const _SendResetLinkButton(),
                        AppSizes.gapH12,
                        TextButton(
                          onPressed: () {
                            context.goNamed(RouteNames.loginpage);
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.arrow_back),
                              AppSizes.gapW8,
                              Text(
                                'Quay lại Đăng nhập',
                                style: AppTypography.medium14(
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ForgetPasswordEmailField extends StatelessWidget {
  const _ForgetPasswordEmailField();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ForgetPasswordFormCubit, ForgetPasswordFormState>(
      buildWhen: (previous, current) => previous.email != current.email,
      builder: (context, state) {
        return MyAppTextfield(
          label: 'Email',
          hintText: 'Nhập email của bạn',
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.email_outlined,
          textInputAction: TextInputAction.done,
          errorText: state.email.displayError != null
              ? 'Email không hợp lệ'
              : null,
          onChanged: (value) {
            context.read<ForgetPasswordFormCubit>().emailChanged(value);
          },
        );
      },
    );
  }
}

class _SendResetLinkButton extends StatelessWidget {
  const _SendResetLinkButton();

  @override
  Widget build(BuildContext context) {
    final isFormValid = context.select(
      (ForgetPasswordFormCubit cubit) => cubit.state.isValid,
    );

    return BlocBuilder<AuthenticationCubit, AuthenticationState>(
      builder: (context, authState) {
        final isLoading = authState is AuthenticationLoadingState;
        return AppButton(
          text: 'Gửi liên kết đặt lại',
          isLoading: isLoading,
          isEnabled: isFormValid && !isLoading,
          onPressed: () {
            if (isFormValid) {
              final email = context
                  .read<ForgetPasswordFormCubit>()
                  .state
                  .email
                  .value
                  .trim();
              context.read<AuthenticationCubit>().sendPasswordResetEmail(email);
            }
          },
        );
      },
    );
  }
}
