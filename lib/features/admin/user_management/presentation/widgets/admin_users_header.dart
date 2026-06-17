import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quanlytro/core/constants/app_sizes.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_style.dart';
import '../../blocs/admin_users_feed/admin_users_feed_cubit.dart';
import '../../blocs/admin_users_feed/admin_users_feed_state.dart';

class AdminUsersHeader extends StatefulWidget {
  const AdminUsersHeader({super.key});

  @override
  State<AdminUsersHeader> createState() => _AdminUsersHeaderState();
}

class _AdminUsersHeaderState extends State<AdminUsersHeader> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminUsersFeedCubit, AdminUsersFeedState>(
      listenWhen: (prev, curr) => prev.isSearchActive != curr.isSearchActive,
      listener: (context, state) {
        if (state.isSearchActive) {
          _searchController.clear();
          context.read<AdminUsersFeedCubit>().updateSearchQuery('');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _searchFocusNode.requestFocus();
            }
          });
        } else {
          _searchController.clear();
        }
      },
      buildWhen: (prev, curr) => prev.isSearchActive != curr.isSearchActive,
      builder: (context, state) {
        final cubit = context.read<AdminUsersFeedCubit>();
        if (state.isSearchActive) {
          return Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  onChanged: cubit.updateSearchQuery,
                  style: AppTypography.medium14(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'Tìm theo tên hoặc email',
                    hintStyle: AppTypography.medium14(
                      color: AppColors.textMuted,
                    ),
                    filled: true,
                    fillColor: AppColors.surface,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 14.h,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
              ),
              AppSizes.gapW8,
              _HeaderIconButton(icon: Icons.close, onTap: cubit.exitSearch),
            ],
          );
        }

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.textMuted.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Quản lý User',
                  style: AppTypography.bold20(color: AppColors.textPrimary),
                ),
              ),
              _HeaderIconButton(icon: Icons.search, onTap: cubit.enterSearch),
            ],
          ),
        );
      },
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        width: 40.w,
        height: 40.w,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowSoft,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 20.sp, color: AppColors.textPrimary),
      ),
    );
  }
}
