import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../../../../core/constants/app_sizes.dart';
import '../../../../../../core/route/app_routes.dart';
import '../../../../../../core/theme/app_style.dart';
import '../../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_text_field.dart';
import '../../../blocs/authentication/auth_cubit.dart';
import '../../../blocs/authentication/auth_state.dart';
import '../../../blocs/sign_form/signin_form_cubit.dart';

class SignInForm extends StatelessWidget {
  const SignInForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _EmailField(),
        AppSizes.gapH24,
        const _PasswordField(),
        AppSizes.gapH16,
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              context.pushNamed(RouteNames.forgetpasswordpage);
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Quên mật khẩu?',
              style: AppTypography.medium14(color: Colors.black87),
            ),
          ),
        ),
        AppSizes.gapH24,
        const _SignInButton(),
      ],
    );
  }
}

class _EmailField extends StatelessWidget {
  const _EmailField();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignInFormCubit, SignInFormState>(
      buildWhen: (previous, current) => previous.email != current.email,
      builder: (context, state) {
        return MyAppTextfield(
          label: 'Email',
          hintText: 'example@gmail.com',
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.email_outlined,
          textInputAction: TextInputAction.next,
          errorText: state.email.displayError != null
              ? "Email không hợp lệ"
              : null,
          onChanged: (value) {
            context.read<SignInFormCubit>().emailChanged(value);
          },
        );
      },
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignInFormCubit, SignInFormState>(
      buildWhen: (previous, current) =>
          previous.password != current.password ||
          previous.isObscure != current.isObscure,
      builder: (context, state) {
        return MyAppTextfield(
          label: 'Mật khẩu',
          hintText: '*************',
          keyboardType: TextInputType.visiblePassword,
          prefixIcon: Icons.lock,
          obscureText: state.isObscure,
          suffixIcon: state.isObscure ? Icons.visibility_off : Icons.visibility,
          textInputAction: TextInputAction.done,
          errorText: state.password.displayError != null
              ? "Mật khẩu phải có ít nhất 8 ký tự, 1 chữ hoa và 1 số"
              : null,
          onSuffixIconTap: () {
            context.read<SignInFormCubit>().changeObscurity();
          },
          onChanged: (value) {
            context.read<SignInFormCubit>().passwordChanged(value);
          },
        );
      },
    );
  }
}

class _SignInButton extends StatelessWidget {
  const _SignInButton();

  @override
  Widget build(BuildContext context) {
    final isFormValid = context.select(
      (SignInFormCubit cubit) => cubit.state.isValid,
    );

    return BlocBuilder<AuthenticationCubit, AuthenticationState>(
      builder: (context, authState) {
        final isLoading = authState is AuthenticationLoadingState;
        return AppButton(
          text: 'Đăng nhập',
          isLoading: isLoading,
          isEnabled: isFormValid && !isLoading,
          onPressed: () {
            if (isFormValid) {
              FocusScope.of(context).unfocus();
              final signInState = context.read<SignInFormCubit>().state;          
              context.read<AuthenticationCubit>().signInWithEmail(
                signInState.email.value,
                signInState.password.value,
              );
            }
          },
        );
      },
    );
  }
}
