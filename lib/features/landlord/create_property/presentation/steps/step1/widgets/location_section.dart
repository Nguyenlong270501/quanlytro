import 'package:flutter/material.dart';

import '../../../../../../../core/constants/app_sizes.dart';
import '../../../../../../../core/constants/property_constants.dart';
import '../../../../blocs/step1/step1_cubit.dart';
import '../../../../blocs/step1/step1_state.dart';
import '../../../shared_widgets/filled_text_field.dart';
import '../../../shared_widgets/form_field_label.dart';
import '../../../shared_widgets/section_card.dart';
import 'filled_dropdown_field.dart';
import 'map_picker_tile.dart';
import 'ward_autocomplete_field.dart';

class LocationSection extends StatelessWidget {
  const LocationSection({
    super.key,
    required this.cubit,
    required this.state,
    required this.wardController,
    required this.streetController,
    required this.coordinateText,
    required this.onOpenMapPicker,
  });

  final Step1Cubit cubit;
  final Step1State state;
  final TextEditingController wardController;
  final TextEditingController streetController;
  final String? coordinateText;
  final VoidCallback onOpenMapPicker;

  @override
  Widget build(BuildContext context) {
    final showErr = state.showErrors;
    return SectionCard(
      emoji: '📍',
      title: 'Vị trí khu trọ',
      subtitle:
          'Vui lòng ghim tọa độ trên bản đồ trước khi điền địa chỉ và kiểm tra lại sau ghi ghim. \nLưu ý: Ghim chuẩn xác sẽ giúp tin đăng của bạn hiển thị đúng vị trí trên bản đồ tìm kiếm.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MapPickerTile(
            required: true,
            hasError: showErr && !state.isLocationPinned,
            coordinateText: coordinateText,
            onTap: onOpenMapPicker,
          ),
          AppSizes.gapH16,
          const FormFieldLabel(label: 'Tỉnh / Thành phố', required: true),
          AppSizes.gapH8,
          FilledDropdownField(
            options: PropertyConstants.cities,
            value: state.city,
            hintText: 'Hà Nội',
            onChanged: cubit.updateCity,
            hasError: showErr && !state.isCityValid,
          ),
          AppSizes.gapH16,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FormFieldLabel(label: 'Phường / Xã ', required: true),
                    AppSizes.gapH8,
                    WardAutocompleteField(
                      controller: wardController,
                      city: state.city,
                      hintText: 'Gõ để tìm (VD: cau giay, Hoan Kiem)...',
                      onChanged: cubit.updateWard,
                      hasError: showErr && !state.isWardValid,
                    ),
                  ],
                ),
              ),
              AppSizes.gapW12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FormFieldLabel(
                      label: 'Số nhà, Đường',
                      required: true,
                    ),
                    AppSizes.gapH8,
                    FilledTextField(
                      controller: streetController,
                      hintText: '100 Xuân Thủy',
                      onChanged: cubit.updateStreet,
                      hasError: showErr && !state.isStreetValid,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
