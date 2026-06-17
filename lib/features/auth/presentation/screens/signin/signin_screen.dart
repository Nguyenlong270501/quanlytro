import 'package:animate_do/animate_do.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../../../core/constants/app_sizes.dart';
import '../../../../../../core/route/app_routes.dart';
import '../../../../../../core/theme/app_style.dart';
import '../../../../../../core/widgets/app_alerts.dart';
import '../../../../../../core/widgets/aurora_background.dart';
import '../../../blocs/authentication/auth_cubit.dart';
import '../../../blocs/authentication/auth_state.dart';
import '../../widget/auth_divider.dart';
import '../../widget/auth_oauth.dart';
import 'signin_form.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthenticationCubit, AuthenticationState>(
        listener: (context, state) {
          if (state is AuthenticationSuccessState) {
            context.goNamed(RouteNames.homepage);
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
                        AppSizes.gapH32,
                        SizedBox(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedTextKit(
                                repeatForever: true,
                                animatedTexts: [
                                  ColorizeAnimatedText(
                                    'Chào mừng đến \nvới Quản lý trọ',
                                    textStyle: AppTypography.medium26(
                                      color: Colors.black87,
                                    ),
                                    colors: const [
                                      Colors.black87,
                                      Color(0xFF8B7CFF),
                                      Color(0xFFFFC58F),
                                    ],
                                  ),
                                ],
                              ),
                              AppSizes.gapW12,
                              FadeInDown(
                                child: SlideInRight(
                                  child: Image.asset(
                                    'assets/icons/app_icon.png',
                                    width: AppSizes.iconSizeXLarge,
                                    height: AppSizes.iconSizeXLarge,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        AppSizes.gapH32,
                        const SignInForm(),
                        AppSizes.gapH24,

                        const AuthDivider(),
                        AppSizes.gapH24,

                        BlocBuilder<AuthenticationCubit, AuthenticationState>(
                          builder: (context, authState) {
                            final isLoading =
                                authState is AuthenticationLoadingState;

                            return AuthOauthSection(
                              isEnabled: !isLoading,
                              onGooglePressed: () {
                                context
                                    .read<AuthenticationCubit>()
                                    .signInWithGoogle();
                              },
                              onFacebookPressed: () {
                                context
                                    .read<AuthenticationCubit>()
                                    .signInWithFacebook();
                              },
                            );
                          },
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
