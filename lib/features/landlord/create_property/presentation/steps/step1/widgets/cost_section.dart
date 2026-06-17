import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../../../core/constants/app_sizes.dart';
import '../../../../blocs/step1/step1_cubit.dart';
import '../../../../blocs/step1/step1_state.dart';
import '../../../shared_widgets/filled_text_field.dart';
import '../../../shared_widgets/form_field_label.dart';
import '../../../shared_widgets/section_card.dart';
import '../../../shared_widgets/text_field_with_suffix.dart';

class CostSection extends StatelessWidget {
  const CostSection({
    super.key,
    required this.cubit,
    required this.state,
    required this.electricityController,
    required this.waterController,
    required this.wifiController,
    required this.parkingController,
    required this.serviceFeeController,
    required this.serviceDescriptionController,
  });

  final Step1Cubit cubit;
  final Step1State state;
  final TextEditingController electricityController;
  final TextEditingController waterController;
  final TextEditingController wifiController;
  final TextEditingController parkingController;
  final TextEditingController serviceFeeController;
  final TextEditingController serviceDescriptionController;

  @override
  Widget build(BuildContext context) {
    final digitsOnly = [FilteringTextInputFormatter.digitsOnly];
    final showErr = state.showErrors;
    return SectionCard(
      emoji: '💰',
      title: 'Chi phí mặc định',
      subtitle: 'Sẽ áp dụng chung cho toàn bộ phòng trong khu này.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FormFieldLabel(label: 'Giá điện', required: true),
                    AppSizes.gapH8,
                    TextFieldWithSuffix(
                      controller: electricityController,
                      suffix: 'đ/kWh',
                      hintText: '3500',
                      keyboardType: TextInputType.number,
                      inputFormatters: digitsOnly,
                      onChanged: cubit.updateElectricityPrice,
                      hasError: showErr && !state.isElectricityPriceValid,
                    ),
                  ],
                ),
              ),
              AppSizes.gapW12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FormFieldLabel(label: 'Giá nước', required: true),
                    AppSizes.gapH8,
                    TextFieldWithSuffix(
                      controller: waterController,
                      suffix: 'đ/m³',
                      hintText: '25.000',
                      keyboardType: TextInputType.number,
                      inputFormatters: digitsOnly,
                      onChanged: cubit.updateWaterPrice,
                      hasError: showErr && !state.isWaterPriceValid,
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSizes.gapH16,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FormFieldLabel(label: 'Giá mạng'),
                    AppSizes.gapH8,
                    TextFieldWithSuffix(
                      controller: wifiController,
                      suffix: 'đ/tháng',
                      hintText: '100.000',
                      keyboardType: TextInputType.number,
                      inputFormatters: digitsOnly,
                      onChanged: cubit.updateWifiPrice,
                    ),
                  ],
                ),
              ),
              AppSizes.gapW12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FormFieldLabel(label: 'Phí gửi xe'),
                    AppSizes.gapH8,
                    TextFieldWithSuffix(
                      controller: parkingController,
                      suffix: 'đ/tháng',
                      hintText: '100.000',
                      keyboardType: TextInputType.number,
                      inputFormatters: digitsOnly,
                      onChanged: cubit.updateParkingFee,
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSizes.gapH16,
          const FormFieldLabel(label: 'Phí dịch vụ chung'),
          AppSizes.gapH8,
          TextFieldWithSuffix(
            controller: serviceFeeController,
            suffix: 'đ/tháng',
            hintText: '150.000',
            keyboardType: TextInputType.number,
            inputFormatters: digitsOnly,
            onChanged: cubit.updateServiceFee,
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            child: state.hasServiceFee
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppSizes.gapH8,
                      const FormFieldLabel(
                        label: 'Mô tả chi tiết phí dịch vụ',
                        required: true,
                      ),
                      AppSizes.gapH8,
                      FilledTextField(
                        controller: serviceDescriptionController,
                        hintText: 'VD: Vệ sinh, internet chung, bảo trì...',
                        maxLines: 2,
                        onChanged: cubit.updateServiceDescription,
                        hasError: showErr && !state.isServiceDescriptionValid,
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
