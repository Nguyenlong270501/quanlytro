import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../../../core/constants/app_sizes.dart';
import '../../../../../../core/route/app_routes.dart';
import '../../../../../../core/services/local_location_service.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_style.dart';
import '../../../../create_property/data/models/preview_stat.dart';
import '../../../../create_property/data/models/property_model.dart';
import '../../../../create_property/presentation/steps/step4/widgets/property_card.dart';
import '../../../../../../core/utils/review_helper.dart';
import '../../../blocs/property_filter/property_filter_cubit.dart';
import '../../../blocs/property_filter/property_filter_state.dart';
import '../../../blocs/property_list/property_list_cubit.dart';
import '../../../blocs/property_list/property_list_state.dart';
import '../widgets/property_bottom.dart';
import '../widgets/property_header.dart';
import '../widgets/property_filter_tabs.dart';

class PropertyScreen extends StatefulWidget {
  const PropertyScreen({super.key});

  @override
  State<PropertyScreen> createState() => _PropertyScreenState();
}

class _PropertyScreenState extends State<PropertyScreen> {
  late final PropertyFilterCubit _filterCubit;

  @override
  void initState() {
    super.initState();
    _filterCubit = PropertyFilterCubit();
  }

  @override
  void dispose() {
    _filterCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PropertyFilterCubit>.value(
      value: _filterCubit,
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 5.h, 16.w, 16.h),
                child: Column(
                  children: [
                    PropertyHeader(),
                    AppSizes.gapH10,
                    const PropertyFilterTabs(),
                  ],
                ),
              ),
              Expanded(
                child: BlocBuilder<PropertyListCubit, PropertyListState>(
                  builder: (context, listState) {
                    if (listState is PropertyListLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (listState is PropertyListError) {
                      return Center(child: Text(listState.message));
                    }
                    if (listState is PropertyListLoaded) {
                      return BlocBuilder<
                        PropertyFilterCubit,
                        PropertyFilterState
                      >(
                        builder: (context, filterState) {
                          final items = _getFilteredProperties(
                            listState,
                            filterState.currentFilter,
                          );

                          if (items.isEmpty) {
                            return Center(
                              child: Text(
                                'Không có bài đăng nào.',
                                style: AppTypography.medium14(
                                  color: AppColors.textMuted,
                                ),
                              ),
                            );
                          }

                          return ListView.separated(
                            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
                            itemCount: items.length,
                            separatorBuilder: (context, index) =>
                                AppSizes.gapH16,
                            itemBuilder: (context, index) {
                              final property = items[index];
                              final rooms = property.rooms ?? [];
                              final displayRoom = rooms.isNotEmpty
                                  ? rooms.first
                                  : null;
                              final cardImages =
                                  displayRoom != null &&
                                      displayRoom.imageUrls.isNotEmpty
                                  ? displayRoom.imageUrls
                                  : (property.imageUrls ?? []);
                              final (pricePrefix, priceValue) =
                                  ReviewHelper.priceRangeLabel(rooms);
                              final wardName = LocalLocationService()
                                  .wardDisplayName(
                                    city: property.city,
                                    value: property.ward,
                                  );
                              final address = [
                                property.streetAddress,
                                wardName,
                                property.city,
                              ].where((e) => e.trim().isNotEmpty).join(', ');

                              return PropertyCard(
                                imageUrl: cardImages,
                                showPendingEditBadge: property.hasPendingUpdate,
                                pricePrefix: pricePrefix,
                                priceValue: priceValue,
                                name: property.title,
                                propertyTypes: property.propertyTypes,
                                address: address,
                                summary: property.description,
                                createdAt: property.createdAt,
                                onTap: () {
                                  context.push<bool>(
                                    RouteNames.propertyDetail,
                                    extra: property,
                                  );
                                },
                                status: property.status,
                                stats: [
                                  PreviewStat(
                                    value: rooms.length.toString(),
                                    label: 'Phòng',
                                    emoji: '🛏️',
                                  ),
                                  PreviewStat(
                                    value: displayRoom != null
                                        ? ReviewHelper.formatAreaLabel(
                                            displayRoom.area.toString(),
                                          )
                                        : '—',
                                    label: 'Diện tích',
                                    emoji: '📐',
                                  ),
                                  PreviewStat(
                                    value: displayRoom != null
                                        ? displayRoom.maxTenants.toString()
                                        : '—',
                                    label: 'Người / phòng',
                                    emoji: '👥',
                                  ),
                                ],
                                bottomWidget: PropertyBottom(
                                  property: property,
                                ),
                              );
                            },
                          );
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<PropertyModel> _getFilteredProperties(
    PropertyListLoaded state,
    PropertyFilter filter,
  ) {
    switch (filter) {
      case PropertyFilter.pending:
        return state.pendingItems;
      case PropertyFilter.approved:
        return state.approvedItems;
      case PropertyFilter.rejected:
        return state.rejectedItems;
      case PropertyFilter.hidden:
        return state.hiddenItems;
      case PropertyFilter.all:
        return state.properties;
    }
  }
}
