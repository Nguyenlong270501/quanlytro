import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_style.dart';
import '../home_tab/blocs/landlord_navigation_cubit.dart';

class LandlordBottomNav extends StatelessWidget {
  const LandlordBottomNav({super.key, required this.items});

  final List<NavItemData> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: BlocBuilder<LandlordNavigationCubit, LandlordNavigationState>(
          buildWhen: (prev, curr) => prev.currentTab != curr.currentTab,
          builder: (context, state) {
            return SizedBox(
              height: 68.h,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Row(
                    children: List.generate(items.length, (index) {
                      final item = items[index];
                      final isActive = state.currentIndex == index;

                      return Expanded(
                        child: InkWell(
                          onTap: () => context
                              .read<LandlordNavigationCubit>()
                              .changeTabByIndex(index),
                          child: _NavItemContent(
                            item: item,
                            isActive: isActive,
                          ),
                        ),
                      );
                    }),
                  ),
                  Positioned(
                    top: -16.h,
                    left: 0,
                    right: 0,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: _CenterFab(
                        onTap: () => context
                            .read<LandlordNavigationCubit>()
                            .changeTabByIndex(_centerIndex(items)),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  static int _centerIndex(List<NavItemData> items) {
    for (int i = 0; i < items.length; i++) {
      if (items[i].isCenter) return i;
    }
    return 0;
  }
}

class _NavItemContent extends StatelessWidget {
  const _NavItemContent({
    required this.item,
    required this.isActive,
  });

  final NavItemData item;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.primary : AppColors.textDisabled;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            height: 24.sp,
            child: item.isCenter
                ? null
                : _NavIcon(
                    icon: isActive ? item.activeIcon : item.icon,
                    color: color,
                    badgeCount: item.badgeCount,
                  ),
          ),
          Text(
            item.label,
            style: AppTypography.medium12(
              color: item.isCenter
                  ? (isActive ? AppColors.primary : AppColors.textDisabled)
                  : color,
            ),
          ),
        ],
      ),
    );
  }
}

class _CenterFab extends StatelessWidget {
  const _CenterFab({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 55.w,
        height: 55.w,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowSoft,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Icon(Icons.add, color: AppColors.surface, size: 32.sp),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({
    required this.icon,
    required this.color,
    this.badgeCount,
  });

  final IconData icon;
  final Color color;
  final int? badgeCount;

  @override
  Widget build(BuildContext context) {
    final iconWidget = Icon(icon, color: color, size: 28.sp);

    if (badgeCount == null || badgeCount == 0) return iconWidget;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        iconWidget,
        Positioned(
          right: -8.w,
          top: -4.h,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: AppColors.danger,
              borderRadius: BorderRadius.circular(10),
            ),
            constraints: BoxConstraints(minWidth: 18.w),
            child: Text(
              '$badgeCount',
              textAlign: TextAlign.center,
              style: AppTypography.bold10(color: AppColors.surface),
            ),
          ),
        ),
      ],
    );
  }
}

class NavItemData {
  const NavItemData({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.badgeCount,
    this.isCenter = false,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int? badgeCount;
  final bool isCenter;
}