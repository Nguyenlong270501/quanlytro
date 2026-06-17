import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/constants/app_sizes.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_style.dart';
import '../../../blocs/create_property/create_property_cubit.dart';
import '../../../blocs/step1/step1_cubit.dart';
import '../../../blocs/step2/step2_cubit.dart';
import '../../../blocs/step2/step2_state.dart';
import '../../../blocs/step3/step3_cubit.dart';
import '../../../blocs/step3/step3_state.dart';
import '../../../data/models/preview_stat.dart';
import '../../../data/models/property_model.dart';
import '../../../../../../core/utils/review_helper.dart';
import '../../shared_widgets/section_card.dart';
import 'widgets/image_carousel.dart';
import 'widgets/info_row.dart';
import 'widgets/property_card.dart';
import 'widgets/room_mini_card.dart';
import 'room_preview_screen.dart';
import 'widgets/summary_chip.dart';

class StepReviewScreen extends StatelessWidget {
  const StepReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final step1 = context.watch<Step1Cubit>().state;
    final step2 = context.watch<Step2Cubit>().state;
    final step3 = context.watch<Step3Cubit>().state;
    final firstRoom = step3.rooms.isNotEmpty ? step3.rooms[0] : null;
    final (pricePrefix, priceValue) = ReviewHelper.priceRangeLabel(step3.rooms);

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KHỐI 1: GIAO DIỆN HIỂN THỊ
          if (firstRoom != null) ...[
            SectionCard(
              emoji: '👀',
              title: 'Giao diện hiển thị',
              child: PropertyCard(
                imageUrl: firstRoom.imageUrls,
                pricePrefix: pricePrefix,
                priceValue: priceValue,
                name: ReviewHelper.orPlaceholder(
                  step1.name,
                  'Chưa đặt tên khu trọ',
                ),
                propertyTypes: step1.propertyTypes,
                address: ReviewHelper.buildAddress(step1),
                summary: ReviewHelper.orPlaceholder(
                  step1.description,
                  'Chưa có mô tả chung.',
                ),
                status: PropertyStatus.pending,
                createdAt: DateTime.now(),
                onTap: null,
                stats: [
                  PreviewStat(
                    value: step3.rooms.length.toString(),
                    label: 'Phòng',
                    emoji: '🛏️',
                  ),
                  PreviewStat(
                    value: ReviewHelper.formatAreaLabel(
                      firstRoom.area.toString(),
                    ),
                    label: 'Diện tích',
                    emoji: '📐',
                  ),
                  PreviewStat(
                    value: firstRoom.maxTenants.toString(),
                    label: 'Người / phòng',
                    emoji: '👥',
                  ),
                ],
              ),
            ),
          ],
          AppSizes.gapH16,

          // KHỐI 2: TÒA NHÀ & CHI PHÍ
          SectionCard(
            emoji: '🏢',
            title: 'Tòa nhà & Chi phí',
            trailing: _buildEditButton(context, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InfoRow(
                  label: 'Tên:',
                  value: ReviewHelper.orPlaceholder(step1.name, '—'),
                ),
                InfoRowList(label: 'Loại hình:', value: step1.propertyTypes),
                step1.minimumRentalDuration.isEmpty ||
                        step1.minimumRentalDuration == '0'
                    ? Text(
                        'Không có yêu cầu thuê tối thiểu',
                        style: AppTypography.medium14(
                          color: AppColors.textSecondary,
                        ),
                      )
                    : InfoRow(
                        label: 'Thời gian thuê tối thiểu:',
                        value: '${step1.minimumRentalDuration} tháng',
                      ),
                InfoRow(
                  label: 'Địa chỉ:',
                  value: ReviewHelper.buildAddress(step1),
                ),
                const Divider(color: AppColors.divider, height: 20),
                InfoRow(
                  label: 'Giá điện:',
                  value: ReviewHelper.formatFeePerUnit(
                    step1.electricityPrice,
                    'đ/kWh',
                  ),
                  highlight: true,
                ),
                InfoRow(
                  label: 'Giá nước:',
                  value: ReviewHelper.formatFeePerUnit(
                    step1.waterPrice,
                    'đ/m³',
                  ),
                  highlight: true,
                ),
                if (step1.serviceFee != null &&
                    step1.serviceFee!.isNotEmpty) ...[
                  InfoRow(
                    label: 'Phí dịch vụ:',
                    value: ReviewHelper.formatFeePerUnit(
                      step1.serviceFee!,
                      'đ/tháng',
                    ),
                    highlight: true,
                  ),
                  if (step1.serviceDescription != null &&
                      step1.serviceDescription!.trim().isNotEmpty)
                    InfoRow(
                      label: 'Mô tả phí DV:',
                      value: step1.serviceDescription!.trim(),
                    ),
                  if (step1.wifiPrice != null && step1.wifiPrice!.isNotEmpty)
                    InfoRow(
                      label: 'Tiền mạng:',
                      value: ReviewHelper.formatFeePerUnit(
                        step1.wifiPrice!,
                        'đ/tháng',
                      ),
                      highlight: true,
                    ),
                  if (step1.parkingFee != null && step1.parkingFee!.isNotEmpty)
                    InfoRow(
                      label: 'Phí gửi xe:',
                      value: ReviewHelper.formatFeePerUnit(
                        step1.parkingFee!,
                        'đ/tháng',
                      ),
                      highlight: true,
                    ),
                  if (step2.imageUrls.isNotEmpty) ...[
                    Text(
                      'Ảnh tòa nhà:',
                      style: AppTypography.medium14(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    AppSizes.gapH8,
                    Container(
                      width: double.infinity,
                      height: 150.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: ImageCarousel(images: step2.imageUrls),
                    ),
                  ],
                ],
              ],
            ),
          ),
          AppSizes.gapH16,

          // KHỐI 3: TIỆN ÍCH & NỘI QUY
          SectionCard(
            emoji: '✨',
            title: 'Tiện ích',
            trailing: _buildEditButton(context, 1),
            child: _buildAmenitiesRules(
              step2,
              ReviewHelper.getAmenities(step2),
            ),
          ),
          AppSizes.gapH16,
          SectionCard(
            emoji: '📜',
            title: 'Nội quy',
            trailing: _buildEditButton(context, 1),
            child: _buildAmenitiesRules(step2, ReviewHelper.getRules(step2)),
          ),
          AppSizes.gapH16,

          // KHỐI 4: CHI TIẾT PHÒNG
          SectionCard(
            emoji: '🛏️',
            title: 'Chi tiết phòng (${step3.rooms.length} phòng)',
            child: _buildRoomList(context, step3),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenitiesRules(Step2State s, List<Map<String, String>> chips) {
    final hasNotes = s.ruleNotes.trim().isNotEmpty;

    if (chips.isEmpty && !hasNotes) {
      return Text(
        'Chưa chọn tiện ích hoặc nội quy nào.',
        style: AppTypography.medium12(color: AppColors.textMuted),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (chips.isNotEmpty)
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: chips
                .map((c) => SummaryChip(emoji: c['emoji']!, label: c['label']!))
                .toList(),
          ),
        if (hasNotes) ...[
          AppSizes.gapH8,
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.textMuted.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: AppColors.textMuted.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 1.h),
                  child: Icon(
                    Icons.info_outline,
                    size: 16.sp,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Ghi chú nội quy: ',
                          style: AppTypography.bold12(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        TextSpan(
                          text: s.ruleNotes.trim(),
                          style: AppTypography.medium12(
                            color: AppColors.textMuted,
                          ).copyWith(height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRoomList(BuildContext context, Step3State s) {
    final roomList = s.rooms;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: 250.h),
      child: ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: roomList.length,
        separatorBuilder: (context, index) => SizedBox(height: 10.h),
        itemBuilder: (context, index) {
          final room = roomList[index];
          return RoomMiniCard(
            name: room.roomName,
            priceLabel: '${ReviewHelper.formatPrice(room.price)} đ/tháng',
            onTap: () => openRoomPreviewScreen(
              context,
              room: room,
              isReadOnly: true,
              roomIndex: index,
            ),
          );
        },
      ),
    );
  }

  Widget _buildEditButton(BuildContext context, int stepIndex) {
    return InkWell(
      onTap: () {
        context.read<CreatePropertyNavCubit>().editStep(stepIndex);
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.edit_outlined, size: 14.sp, color: AppColors.primary),
            SizedBox(width: 4.w),
            Text('Sửa', style: AppTypography.bold12(color: AppColors.primary)),
          ],
        ),
      ),
    );
  }
}
