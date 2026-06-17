import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/constants/app_sizes.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_style.dart';
import '../../../blocs/property_filter/property_filter_cubit.dart';
import '../../../blocs/property_filter/property_filter_state.dart';

class PropertyFilterTabs extends StatelessWidget {
  const PropertyFilterTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PropertyFilterCubit, PropertyFilterState>(
      builder: (context, state) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _TabItem(
                text: 'Tất cả bài đăng',
                isSelected: state.currentFilter == PropertyFilter.all,
                onTap: () => context.read<PropertyFilterCubit>().changeFilter(
                  PropertyFilter.all,
                ),
              ),
              AppSizes.gapW8,
              _TabItem(
                text: 'Chờ duyệt',
                isSelected: state.currentFilter == PropertyFilter.pending,
                onTap: () => context.read<PropertyFilterCubit>().changeFilter(
                  PropertyFilter.pending,
                ),
              ),
              AppSizes.gapW8,
              _TabItem(
                text: 'Đã duyệt',
                isSelected: state.currentFilter == PropertyFilter.approved,
                onTap: () => context.read<PropertyFilterCubit>().changeFilter(
                  PropertyFilter.approved,
                ),
              ),
              AppSizes.gapW8,
              _TabItem(
                text: 'Từ chối',
                isSelected: state.currentFilter == PropertyFilter.rejected,
                onTap: () => context.read<PropertyFilterCubit>().changeFilter(
                  PropertyFilter.rejected,
                ),
              ),
              AppSizes.gapW8,
              _TabItem(
                text: 'Ẩn',
                isSelected: state.currentFilter == PropertyFilter.hidden,
                onTap: () => context.read<PropertyFilterCubit>().changeFilter(
                  PropertyFilter.hidden,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TabItem extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabItem({
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF5B5E91) : AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          text,
          style: AppTypography.medium14(
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
