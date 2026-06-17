import 'package:flutter/material.dart';

import '../../../../../../core/services/local_location_service.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/utils/review_helper.dart';
import '../../../../../landlord/create_property/data/models/property_model.dart';
import '../../../../../landlord/create_property/presentation/shared_widgets/section_card.dart';
import '../../../../../landlord/create_property/presentation/steps/step4/widgets/info_row.dart';
import '../../property_request/widgets/pending_update_display_formatter.dart';
import '../../property_request/widgets/pending_value_banner.dart';

class PropertyDetailBuildingCostSection extends StatelessWidget {
  const PropertyDetailBuildingCostSection({
    super.key,
    required this.property,
    required this.pendingIndex,
  });

  final PropertyModel property;
  final PendingUpdateIndex? pendingIndex;

  @override
  Widget build(BuildContext context) {
    final wardName = LocalLocationService().wardDisplayName(
      city: property.city,
      value: property.ward,
    );
    final addressLine = pendingIndex?.buildPendingAddressLine(property);

    return SectionCard(
      emoji: '🏢',
      title: 'Tòa nhà & Chi phí',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PendingFieldBlock(
            pending: pendingIndex?.property('title'),
            pendingCaption: 'Tiêu đề',
            child: InfoRow(
              label: 'Tên:',
              value: ReviewHelper.orPlaceholder(property.title, '—'),
            ),
          ),
          PendingFieldBlock(
            pending: pendingIndex?.property('propertyTypes'),
            pendingCaption: 'Loại hình',
            child: InfoRowList(
              label: 'Loại hình:',
              value: property.propertyTypes,
            ),
          ),
          PendingFieldBlock(
            pending: addressLine,
            pendingCaption: 'Địa chỉ',
            child: InfoRow(
              label: 'Địa chỉ:',
              value: [
                property.streetAddress,
                wardName,
                property.city,
              ].where((e) => e.isNotEmpty).join(', '),
            ),
          ),
          PendingFieldBlock(
            pending: pendingIndex?.property('description'),
            pendingCaption: 'Mô tả',
            child: InfoRow(label: 'Mô tả chung:', value: property.description),
          ),
          const Divider(color: AppColors.divider, height: 20),
          PendingFieldBlock(
            pending: pendingIndex?.property('electricityPrice'),
            pendingCaption: 'Giá điện',
            child: InfoRow(
              label: 'Giá điện:',
              value: ReviewHelper.formatFeePerUnit(
                property.electricityPrice.toString(),
                'đ/kWh',
              ),
              highlight: true,
            ),
          ),
          PendingFieldBlock(
            pending: pendingIndex?.property('waterPrice'),
            pendingCaption: 'Giá nước',
            child: InfoRow(
              label: 'Giá nước:',
              value: ReviewHelper.formatFeePerUnit(
                property.waterPrice.toString(),
                'đ/m³',
              ),
              highlight: true,
            ),
          ),
          if (property.wifiPrice != null && property.wifiPrice! > 0)
            PendingFieldBlock(
              pending: pendingIndex?.property('wifiPrice'),
              pendingCaption: 'Tiền mạng',
              child: InfoRow(
                label: 'Tiền mạng:',
                value: ReviewHelper.formatFeePerUnit(
                  property.wifiPrice!.toString(),
                  'đ/tháng',
                ),
                highlight: true,
              ),
            ),
          if (property.parkingFee != null && property.parkingFee! > 0)
            PendingFieldBlock(
              pending: pendingIndex?.property('parkingFee'),
              pendingCaption: 'Phí gửi xe',
              child: InfoRow(
                label: 'Phí gửi xe:',
                value: ReviewHelper.formatFeePerUnit(
                  property.parkingFee!.toString(),
                  'đ/tháng',
                ),
                highlight: true,
              ),
            ),
          if (property.serviceFee != null && property.serviceFee! > 0) ...[
            PendingFieldBlock(
              pending: pendingIndex?.property('serviceFee'),
              pendingCaption: 'Phí dịch vụ',
              child: InfoRow(
                label: 'Phí dịch vụ:',
                value: ReviewHelper.formatFeePerUnit(
                  property.serviceFee!.toString(),
                  'đ/tháng',
                ),
                highlight: true,
              ),
            ),
            if (property.serviceDescription != null &&
                property.serviceDescription!.isNotEmpty)
              PendingFieldBlock(
                pending: pendingIndex?.property('serviceDescription'),
                pendingCaption: 'Mô tả phí DV',
                child: InfoRow(
                  label: 'Mô tả phí DV:',
                  value: property.serviceDescription!,
                ),
              ),
          ],
        ],
      ),
    );
  }
}
