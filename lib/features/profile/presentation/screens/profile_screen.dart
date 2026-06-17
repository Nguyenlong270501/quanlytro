import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:app_settings/app_settings.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../core/route/app_routes.dart';
import '../../../auth/blocs/authentication/auth_cubit.dart';
import '../../../auth/blocs/authentication/auth_state.dart';
import '../../../auth/data/models/user.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_style.dart';
import '../../../../core/widgets/app_alerts.dart';
import '../widgets/menu_item.dart';
import '../widgets/profile_avatar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.onOpenNotificationSettings});

  final VoidCallback? onOpenNotificationSettings;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _cachedUser;

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthenticationCubit>().state;
    if (authState is AuthenticationSuccessState) {
      _cachedUser = authState.user;
    }

    final user = _cachedUser;
    final name = (user?.userName.isNotEmpty ?? false)
        ? user!.userName
        : 'Người dùng';
    final email = user?.email ?? 'Chưa có email';
    final avatarUrl = user?.avatarUrl ?? '';
    final isLandlord = user?.role == UserRole.landlord;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 52.h, 16.w, 16.h),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.textMuted.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.only(left: 8.w),
                  child: Text(
                    'Thông tin cá nhân',
                    style: AppTypography.bold20(color: AppColors.textPrimary),
                  ),
                ),
              ),
              AppSizes.gapH12,
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ProfileAvatar(
                  name: name,
                  email: email,
                  avatarUrl: avatarUrl,
                  isLandlord: isLandlord,
                ),
              ),
              AppSizes.gapH16,
              _ProfileMenuSection(
                user: user,
                onOpenNotificationSettings: widget.onOpenNotificationSettings,
              ),
              AppSizes.gapH24,
              Center(
                child: _LogoutButton(
                  onTap: () async {
                    await context.read<AuthenticationCubit>().signout();
                    if (context.mounted) {
                      context.goNamed(RouteNames.loginpage);
                    }
                  },
                ),
              ),
              AppSizes.gapH16,
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileMenuSection extends StatefulWidget {
  const _ProfileMenuSection({
    required this.user,
    this.onOpenNotificationSettings,
  });

  final UserModel? user;
  final VoidCallback? onOpenNotificationSettings;

  @override
  State<_ProfileMenuSection> createState() => _ProfileMenuSectionState();
}

class _ProfileMenuSectionState extends State<_ProfileMenuSection> {
  bool _isOpeningSettings = false;

  Future<void> _openSystemSettings(AppSettingsType type) async {
    if (_isOpeningSettings) return;
    _isOpeningSettings = true;

    try {
      await AppSettings.openAppSettings(type: type);
    } catch (_) {
      if (!mounted) return;

      final message = type == AppSettingsType.notification
          ? 'Không thể mở cài đặt thông báo.'
          : 'Không thể mở cài đặt vị trí.';

      Alerts.of(context).showError(message);
    } finally {
      _isOpeningSettings = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionTitle('Tài khoản của tôi'),
        _ProfileSectionCard(
          children: [
            MenuItem(
              grouped: true,
              icon: Icons.person_outline,
              title: 'Thông tin cá nhân',
              onTap: () =>
                  context.pushNamed(RouteNames.editProfilePage, extra: user),
            ),
            _ProfileMenuDivider(),
            MenuItem(
              grouped: true,
              icon: Icons.security,
              title: 'Bảo mật & Mật khẩu',
              onTap: () => context.pushNamed(RouteNames.securityPasswordPage),
            ),
            _ProfileMenuDivider(),
            if (user != null && user.role == UserRole.landlord) ...[
              MenuItem(
                grouped: true,
                icon: Icons.apartment_outlined,
                title: 'Đơn đăng ký chủ trọ',
                onTap: () => context.pushNamed(RouteNames.landlordRequestPage),
              ),
            ],
          ],
        ),
        if (user != null && user.role == UserRole.landlord) ...[
          _buildSectionTitle('Cài đặt ứng dụng'),
          _ProfileSectionCard(
            children: [
              MenuItem(
                grouped: true,
                icon: Icons.notifications_outlined,
                title: 'Cài đặt thông báo',
                onTap: () {
                  widget.onOpenNotificationSettings?.call();
                  _openSystemSettings(AppSettingsType.notification);
                },
              ),
              _ProfileMenuDivider(),
              MenuItem(
                grouped: true,
                icon: Icons.location_on_outlined,
                title: 'Cài đặt vị trí',
                onTap: () => _openSystemSettings(AppSettingsType.location),
              ),
            ],
          ),
        ],
        _buildSectionTitle('Hỗ trợ & Thông tin'),
        _ProfileSectionCard(
          children: const [
            MenuItem(
              grouped: true,
              icon: Icons.headset_mic_outlined,
              title: 'Trung tâm hỗ trợ',
            ),
            _ProfileMenuDivider(),
            MenuItem(
              grouped: true,
              icon: Icons.article_outlined,
              title: 'Điều khoản & Chính sách',
            ),
            _ProfileMenuDivider(),
            MenuItem(
              grouped: true,
              icon: Icons.info_outline,
              title: 'Về Trọ Tốt (v1.0.0)',
              showTrailing: false,
            ),
          ],
        ),
      ],
    );
  }
}

class _ProfileSectionCard extends StatelessWidget {
  const _ProfileSectionCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
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
      child: Column(children: children),
    );
  }
}

class _ProfileMenuDivider extends StatelessWidget {
  const _ProfileMenuDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey.shade100,
      indent: 54.w,
      endIndent: 16.w,
    );
  }
}

Widget _buildSectionTitle(String title) {
  return Padding(
    padding: EdgeInsets.only(left: 4.w, right: 4.w, bottom: 8.h, top: 4.h),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title.toUpperCase(),
        style: AppTypography.bold14(color: AppColors.textSecondary),
      ),
    ),
  );
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200.w,
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.danger.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(28.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.logout_rounded,
              size: AppSizes.iconSizeSmall,
              color: AppColors.danger,
            ),
            AppSizes.gapW8,
            Text(
              'Đăng xuất',
              style: AppTypography.bold18(color: AppColors.danger),
            ),
          ],
        ),
      ),
    );
  }
}
