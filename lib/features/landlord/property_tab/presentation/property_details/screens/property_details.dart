import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../../../core/constants/app_sizes.dart';
import '../../../../../../core/route/app_routes.dart';
import '../../../../../../core/services/local_location_service.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_style.dart';
import '../../../../../../core/utils/property_helper.dart';
import '../../../../../../core/widgets/app_alerts.dart';
import '../../../../create_property/data/models/property_model.dart';
import '../../../../create_property/data/models/room_model.dart';
import '../../../../create_property/data/repositories/create_property_repository.dart';
import '../../../../create_property/presentation/shared_widgets/section_card.dart';
import '../../../../create_property/presentation/steps/step4/widgets/image_carousel.dart';
import '../../../../create_property/presentation/steps/step4/widgets/info_row.dart';
import '../../../../create_property/presentation/steps/step4/widgets/room_mini_card.dart';
import '../../../../create_property/presentation/steps/step4/room_preview_screen.dart';
import '../../../../../../core/utils/review_helper.dart';
import '../../../../../admin/approvals/presentation/property_request/widgets/pending_update_display_formatter.dart';
import '../../../../../admin/approvals/presentation/property_request/widgets/pending_value_banner.dart';
import '../../../blocs/property_details_reviews/property_details_reviews_cubit.dart';
import '../../../blocs/property_details_reviews/property_details_reviews_state.dart';
import '../../../blocs/property_list/property_list_cubit.dart';
import '../../../blocs/property_list/property_list_state.dart';
import '../widgets/property_amenities_and_rules.dart';
import '../widgets/property_map_section.dart';
import '../widgets/property_reviews_section.dart';

class PropertyDetailsScreen extends StatefulWidget {
  const PropertyDetailsScreen({super.key, required this.property});

  final PropertyModel property;

  @override
  State<PropertyDetailsScreen> createState() => _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState extends State<PropertyDetailsScreen> {
  final ScrollController _scrollController = ScrollController();
  static const double _loadMoreThreshold = 120;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }
    final position = _scrollController.position;
    if (position.pixels < position.maxScrollExtent - _loadMoreThreshold) {
      return;
    }
    final cubit = context.read<PropertyDetailsReviewsCubit>();
    final state = cubit.state;
    if (state.isLoadingMore || !state.canLoadMore) {
      return;
    }
    cubit.loadMore();
  }

  PropertyModel _merge(PropertyListState listState) {
    if (listState is PropertyListLoaded) {
      for (final p in listState.properties) {
        if (p.propertyId == widget.property.propertyId) return p;
      }
    }
    return widget.property;
  }

  Future<bool> _persistRoomEdit(BuildContext context, RoomModel updated) async {
    final listState = context.read<PropertyListCubit>().state;
    final currentProperty = _merge(listState);
    final rooms = List<RoomModel>.from(
      currentProperty.rooms ?? const <RoomModel>[],
    );
    final index = rooms.indexWhere((r) => r.roomId == updated.roomId);
    if (index < 0) return false;

    final repo = context.read<CreatePropertyRepository>();
    final priorImages = List<String>.from(rooms[index].imageUrls);
    final submittedRoom = updated.copyWith(
      propertyId: widget.property.propertyId,
    );
    final result = await repo.persistRoomEdit(
      propertyId: widget.property.propertyId,
      previousImageUrls: priorImages,
      room: submittedRoom,
    );
    if (!context.mounted) return false;
    return result.fold(
      (message) {
        Alerts.of(context).showError(message);
        return false;
      },
      (savedRoom) {
        final nextRooms = List<RoomModel>.from(rooms);
        nextRooms[index] = savedRoom;
        context.read<PropertyListCubit>().applyLocalPropertyUpdate(
          currentProperty.copyWith(
            rooms: nextRooms,
            updatedAt: DateTime.now(),
          ),
        );
        Alerts.of(context).showSuccess('Đã cập nhật phòng.');
        return true;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PropertyListCubit, PropertyListState>(
      builder: (context, listState) {
        final merged = _merge(listState);
        final rooms = merged.rooms ?? [];

        rooms.sort((a, b) => compareNatural(a.roomName, b.roomName));
        final wardName = LocalLocationService().wardDisplayName(
          city: merged.city,
          value: merged.ward,
        );

        return Scaffold(
          backgroundColor: AppColors.scaffoldBackground,
          appBar: AppBar(
            title: Text(
              'Chi tiết nhà trọ',
              style: AppTypography.bold18(color: AppColors.textPrimary),
            ),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: AppColors.textPrimary),
            actions: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.edit, color: AppColors.textPrimary),
                  onPressed: () async {
                    await context.push<bool>(
                      RouteNames.editProperty,
                      extra: merged,
                    );
                  },
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            controller: _scrollController,
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (merged.hasPendingUpdate) ...[
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: AppColors.pendingEditSoft,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: AppColors.pendingEditBorder),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.schedule_outlined,
                          color: AppColors.pendingEditText,
                          size: 20.sp,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            'Bạn có chỉnh sửa đang chờ admin duyệt. '
                            'Nội dung hiển thị là bản đang công bố.',
                            style: AppTypography.medium12(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (merged.pendingUpdate != null) ...[
                    AppSizes.gapH10,
                    Text(
                      'Các thay đổi đang chờ duyệt',
                      style: AppTypography.bold14(color: AppColors.textPrimary),
                    ),
                    AppSizes.gapH8,
                    ...PendingUpdateDisplayFormatter.format(
                      property: merged,
                      pending: merged.pendingUpdate!,
                    ).map((line) => PendingValueBanner(line: line)),
                  ],
                  AppSizes.gapH12,
                ],
                if (merged.rejectedReason != null &&
                    merged.rejectedReason!.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      border: Border.all(color: AppColors.error),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lý do bị từ chối:',
                          style: AppTypography.bold14(color: AppColors.error),
                        ),
                        AppSizes.gapH4,
                        Text(
                          merged.rejectedReason!,
                          style: AppTypography.medium12(color: AppColors.error),
                        ),
                      ],
                    ),
                  ),
                  AppSizes.gapH8,
                ],
                if (merged.imageUrls != null &&
                    merged.imageUrls!.isNotEmpty) ...[
                  SectionCard(
                    emoji: '📸',
                    title: 'Hình ảnh chung bên ngoài',
                    child: Container(
                      height: 200.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: ImageCarousel(images: merged.imageUrls!),
                    ),
                  ),
                ],
                AppSizes.gapH16,
                SectionCard(
                  emoji: '🏢',
                  title: 'Tòa nhà & Chi phí',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InfoRow(
                        label: 'Tên:',
                        value: ReviewHelper.orPlaceholder(merged.title, '—'),
                      ),
                      InfoRowList(
                        label: 'Loại hình:',
                        value: [merged.propertyTypes.join(', ')],
                      ),
                      InfoRow(
                        label: 'Địa chỉ:',
                        value: [
                          merged.streetAddress,
                          wardName,
                          merged.city,
                        ].where((e) => e.isNotEmpty).join(', '),
                      ),
                      InfoRow(label: 'Mô tả chung:', value: merged.description),
                      merged.minimumRentalDuration == 0
                          ? Text(
                              'Không có yêu cầu thuê tối thiểu',
                              style: AppTypography.medium14(
                                color: AppColors.textSecondary,
                              ),
                            )
                          : InfoRow(
                              label: 'Thời gian thuê tối thiểu:',
                              value: '${merged.minimumRentalDuration} tháng',
                            ),
                      const Divider(color: AppColors.divider, height: 20),
                      InfoRow(
                        label: 'Giá điện:',
                        value: ReviewHelper.formatFeePerUnit(
                          merged.electricityPrice.toString(),
                          'đ/kWh',
                        ),
                        highlight: true,
                      ),
                      InfoRow(
                        label: 'Giá nước:',
                        value: ReviewHelper.formatFeePerUnit(
                          merged.waterPrice.toString(),
                          'đ/m³',
                        ),
                        highlight: true,
                      ),
                      if (merged.wifiPrice != null && merged.wifiPrice! > 0)
                        InfoRow(
                          label: 'Tiền mạng:',
                          value: ReviewHelper.formatFeePerUnit(
                            merged.wifiPrice!.toString(),
                            'đ/tháng',
                          ),
                          highlight: true,
                        ),
                      if (merged.parkingFee != null && merged.parkingFee! > 0)
                        InfoRow(
                          label: 'Phí gửi xe:',
                          value: ReviewHelper.formatFeePerUnit(
                            merged.parkingFee!.toString(),
                            'đ/tháng',
                          ),
                          highlight: true,
                        ),
                      if (merged.serviceFee != null &&
                          merged.serviceFee! > 0) ...[
                        InfoRow(
                          label: 'Phí dịch vụ:',
                          value: ReviewHelper.formatFeePerUnit(
                            merged.serviceFee!.toString(),
                            'đ/tháng',
                          ),
                          highlight: true,
                        ),
                        if (merged.serviceDescription != null &&
                            merged.serviceDescription!.isNotEmpty)
                          InfoRow(
                            label: 'Mô tả phí DV:',
                            value: merged.serviceDescription!,
                          ),
                      ],
                    ],
                  ),
                ),
                AppSizes.gapH16,
                SectionCard(
                  emoji: '✨',
                  title: 'Tiện ích',
                  child: PropertyFacilitiesSection(property: merged),
                ),
                AppSizes.gapH16,
                SectionCard(
                  emoji: '📜',
                  title: 'Nội quy',
                  child: PropertyRulesSection(property: merged),
                ),
                AppSizes.gapH16,
                SectionCard(
                  emoji: '🛏️',
                  title: 'Danh sách phòng trọ: (${rooms.length} phòng)',
                  child: _buildRoomList(context, rooms),
                ),
                AppSizes.gapH16,
                SectionCard(
                  title: 'Vị trí trên bản đồ',
                  emoji: '📍',
                  child: PropertyMapSection(
                    location: LatLng(
                      merged.location!.latitude,
                      merged.location!.longitude,
                    ),
                    fullAddress: PropertyHelper.propertyLocationSubtitle(
                      merged,
                    ),
                  ),
                ),
                AppSizes.gapH16,
                BlocBuilder<
                  PropertyDetailsReviewsCubit,
                  PropertyDetailsReviewsState
                >(
                  builder: (context, reviewsState) {
                    if (reviewsState.errorMessage != null &&
                        reviewsState.reviews.isEmpty) {
                      return Text(
                        reviewsState.errorMessage!,
                        style: AppTypography.medium12(color: AppColors.error),
                      );
                    }
                    if (reviewsState.reviews.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return PropertyReviewsSection(
                      property: merged,
                      reviews: reviewsState.reviews,
                      isLoadingMore: reviewsState.isLoadingMore,
                      onNearEnd: () {
                        final cubit = context
                            .read<PropertyDetailsReviewsCubit>();
                        final state = cubit.state;
                        if (!state.isLoadingMore && state.canLoadMore) {
                          cubit.loadMore();
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRoomList(BuildContext context, List<RoomModel> rooms) {
    if (rooms.isEmpty) {
      return Text(
        'Không có dữ liệu phòng.',
        style: AppTypography.medium12(color: AppColors.textMuted),
      );
    }

    final itemHeight = 58.h;
    final separatorHeight = 10.h;
    final visibleCount = rooms.length.clamp(1, 3);
    final listHeight =
        visibleCount * itemHeight + (visibleCount - 1) * separatorHeight;

    return SizedBox(
      height: listHeight,
      child: ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: rooms.length,
        separatorBuilder: (_, __) => SizedBox(height: separatorHeight),
        itemBuilder: (context, index) {
          final room = rooms[index];

          return RoomMiniCard(
            name: room.roomName,
            priceLabel: '${ReviewHelper.formatPrice(room.price)} đ/tháng',
            onTap: () {
              openRoomPreviewScreen(
                context,
                room: room,
                isReadOnly: false,
                persistRoomEdit: (updated) =>
                    _persistRoomEdit(context, updated),
              );
            },
          );
        },
      ),
    );
  }
}
