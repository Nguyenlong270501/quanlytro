import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../../core/constants/app_sizes.dart';
import '../../../../../../../core/constants/property_constants.dart';
import '../../../../../../../core/theme/app_colors.dart';
import '../../../../../../../core/theme/app_style.dart';
import '../../../../blocs/step1/step1_cubit.dart';
import '../../../../blocs/step1/step1_state.dart';
import '../../../shared_widgets/filled_text_field.dart';
import '../../../shared_widgets/form_field_label.dart';
import '../../../shared_widgets/section_card.dart';

class BasicInfoSection extends StatelessWidget {
  const BasicInfoSection({
    super.key,
    required this.cubit,
    required this.state,
    required this.nameController,
    required this.minDurationController,
    required this.descriptionController,
    required this.onUnfocusRequested,
  });

  final Step1Cubit cubit;
  final Step1State state;
  final TextEditingController nameController;
  final TextEditingController minDurationController;
  final TextEditingController descriptionController;
  final VoidCallback onUnfocusRequested;

  @override
  Widget build(BuildContext context) {
    final showErr = state.showErrors;
    return SectionCard(
      emoji: '🏢',
      title: 'Thông tin cơ bản',
      subtitle: 'Thông tin chung để khách thuê nhận diện khu trọ của bạn.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FormFieldLabel(label: 'Tên khu trọ', required: true),
          AppSizes.gapH8,
          FilledTextField(
            controller: nameController,
            hintText: 'VD: Trọ xịn Cầu Giấy, CCMN Sinh Viên...',
            onChanged: cubit.updateName,
            hasError: showErr && !state.isNameValid,
          ),
          AppSizes.gapH16,
          const FormFieldLabel(label: 'Loại hình', required: true),
          AppSizes.gapH8,
          SizedBox(
            width: double.infinity,
            child: Wrap(
              spacing: 10.w,
              runSpacing: 10.h,
              children: PropertyConstants.propertyTypes.map((type) {
                final normalizedType = type.trim();
                final isSelected = state.propertyTypes.any(
                  (selectedType) => selectedType.trim() == normalizedType,
                );
                return FilterChip(
                  label: Text(
                    type,
                    style: AppTypography.medium12(
                      color: isSelected
                          ? AppColors.surface
                          : AppColors.textPrimary,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (_) {
                    cubit.togglePropertyType(normalizedType);
                    onUnfocusRequested();
                  },
                  showCheckmark: false,
                  backgroundColor: AppColors.surface,
                  selectedColor: AppColors.primary,
                  elevation: 0,
                  pressElevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.primary.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                );
              }).toList(),
            ),
          ),
          if (showErr && !state.isPropertyTypeValid)
            Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: Text(
                'Vui lòng chọn ít nhất 1 loại hình',
                style: AppTypography.medium12(color: AppColors.danger),
              ),
            ),
          AppSizes.gapH16,
          const FormFieldLabel(
            label: 'Thời gian thuê tối thiểu (tháng)',
            required: false,
          ),
          AppSizes.gapH8,
          FilledTextField(
            controller: minDurationController,
            hintText: 'Không nhập nếu không có yêu cầu',
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: cubit.updateMinimumRentalDuration,
          ),
          AppSizes.gapH16,
          const FormFieldLabel(label: 'Mô tả chung', required: true),
          AppSizes.gapH8,
          FilledTextField(
            controller: descriptionController,
            hintText: 'Mô tả ngắn gọn về không gian, an ninh, láng giềng...',
            maxLines: 4,
            minLines: 3,
            onChanged: cubit.updateDescription,
            hasError: showErr && !state.isDescriptionValid,
          ),
        ],
      ),
    );
  }
}
