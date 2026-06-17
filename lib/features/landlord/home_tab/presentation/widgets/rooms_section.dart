import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/route/app_routes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_style.dart';
import '../../../../../core/utils/review_helper.dart';
import '../../../create_property/data/models/preview_stat.dart';
import '../../../create_property/data/models/property_model.dart';
import '../../../create_property/presentation/steps/step4/widgets/property_card.dart';
import '../../../property_tab/blocs/property_list/property_list_cubit.dart';
import '../../../property_tab/blocs/property_list/property_list_state.dart';
import '../../../property_tab/presentation/property_screen/widgets/property_bottom.dart';

class RoomsSection extends StatelessWidget {
  const RoomsSection({super.key, this.onSeeAll});

  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Bài đăng của bạn',
                style: AppTypography.bold18(color: AppColors.textPrimary),
              ),
            ),
            InkWell(
              onTap: onSeeAll,
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Xem tất cả',
                      style: AppTypography.medium14(color: AppColors.primary),
                    ),
                    AppSizes.gapW4,
                    Icon(
                      Icons.arrow_forward,
                      size: 16.sp,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        AppSizes.gapH12,
        BlocBuilder<PropertyListCubit, PropertyListState>(
          builder: (context, state) {
            if (state is PropertyListLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is PropertyListLoaded) {
              final properties = state.properties;
              if (properties.isEmpty) {
                return _EmptyState();
              }

              final displayList = properties.take(5).toList();

              return Column(
                children: [
                  for (var i = 0; i < displayList.length; i++) ...[
                    if (i > 0) AppSizes.gapH12,
                    _buildPropertyCard(context, displayList[i]),
                  ],
                ],
              );
            }

            if (state is PropertyListError) {
              return Center(
                child: Text(
                  state.message,
                  style: AppTypography.medium14(color: AppColors.error),
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildPropertyCard(BuildContext context, PropertyModel property) {
    final rooms = property.rooms ?? [];
    final displayRoom = rooms.isNotEmpty ? rooms.first : null;
    final cardImages = displayRoom != null && displayRoom.imageUrls.isNotEmpty
        ? displayRoom.imageUrls
        : (property.imageUrls ?? <String>[]);
    final (pricePrefix, priceValue) = ReviewHelper.priceRangeLabel(rooms);

    return PropertyCard(
      imageUrl: cardImages,
      pricePrefix: pricePrefix,
      priceValue: priceValue,
      name: property.title,
      propertyTypes: property.propertyTypes,
      address: property.streetAddress,
      summary: property.description,
      status: property.status,
      showPendingEditBadge: property.hasPendingUpdate,
      createdAt: property.createdAt,
      onTap: () {
        context.push<bool>(RouteNames.propertyDetail, extra: property);
      },
      stats: [
        PreviewStat(
          value: rooms.length.toString(),
          label: 'Phòng',
          emoji: '🛏️',
        ),
        PreviewStat(
          value: displayRoom != null
              ? ReviewHelper.formatAreaLabel(displayRoom.area.toString())
              : '—',
          label: 'Diện tích',
          emoji: '📐',
        ),
        PreviewStat(
          value: displayRoom != null ? displayRoom.maxTenants.toString() : '—',
          label: 'Người / phòng',
          emoji: '👥',
        ),
      ],
      bottomWidget: PropertyBottom(property: property),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 32.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(
            Icons.home_work_outlined,
            size: 40.sp,
            color: AppColors.textDisabled,
          ),
          AppSizes.gapH8,
          Text(
            'Chưa có bài đăng nào',
            style: AppTypography.medium14(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
