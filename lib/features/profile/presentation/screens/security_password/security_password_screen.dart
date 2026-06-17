import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/app_enums.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/route/app_routes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_style.dart';
import '../../../../../core/widgets/app_alerts.dart';
import '../../../../auth/blocs/authentication/auth_cubit.dart';
import '../../../../auth/blocs/authentication/auth_state.dart';
import '../../widgets/menu_item.dart';

class SecurityPasswordScreen extends StatelessWidget {
  const SecurityPasswordScreen({super.key});

  String _providerLabel(AuthProvider provider) {
    switch (provider) {
      case AuthProvider.email:
        return 'email/password';
      case AuthProvider.google:
        return 'Google';
      case AuthProvider.facebook:
        return 'Facebook';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bảo mật & Mật khẩu'),
        backgroundColor: AppColors.surfaceCard,
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(10.w, 12.h, 10.w, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 4.w, right: 4.w, bottom: 8.h),
              child: Text(
                'MẬT KHẨU',
                style: AppTypography.bold14(color: AppColors.textSecondary),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: Offset(0, 4.h),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: MenuItem(
                grouped: true,
                icon: Icons.lock_outline_rounded,
                title: 'Đổi mật khẩu',
                onTap: () {
                  final authState = context.read<AuthenticationCubit>().state;
                  if (authState is! AuthenticationSuccessState) {
                    Alerts.of(
                      context,
                    ).showWarning('Vui lòng đăng nhập lại để đổi mật khẩu');
                    return;
                  }

                  final provider = authState.user.authProvider;
                  if (provider == AuthProvider.email) {
                    context.pushNamed(RouteNames.changePasswordPage);
                    return;
                  }

                  final providerLabel = _providerLabel(provider);
                  Alerts.of(context).showWarning(
                    'Tài khoản của bạn đăng nhập bằng $providerLabel, '
                    'không hỗ trợ đổi mật khẩu email.',
                  );
                },
              ),
            ),
            AppSizes.gapH16,
          ],
        ),
      ),
    );
  }
}
