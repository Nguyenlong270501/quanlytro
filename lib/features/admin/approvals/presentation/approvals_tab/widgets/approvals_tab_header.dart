import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quanlytro/core/constants/app_sizes.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_style.dart';
import '../../../blocs/approvals_search/approvals_search_cubit.dart';
import '../../../blocs/approvals_search/approvals_search_state.dart';

class ApprovalsTabHeader extends StatefulWidget {
  const ApprovalsTabHeader({super.key});

  @override
  State<ApprovalsTabHeader> createState() => _ApprovalsTabHeaderState();
}

class _ApprovalsTabHeaderState extends State<ApprovalsTabHeader> {
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
    return BlocConsumer<ApprovalsSearchCubit, ApprovalsSearchState>(
      listenWhen: (prev, curr) => prev.isSearchActive != curr.isSearchActive,
      listener: (context, state) {
        if (state.isSearchActive) {
          _searchController.clear();
          context.read<ApprovalsSearchCubit>().updateSearchQuery('');
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
        final cubit = context.read<ApprovalsSearchCubit>();
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
                    hintText: 'Tìm kiếm...',
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
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: AppColors.textMuted.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Duyệt bài đăng và chủ trọ',
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
