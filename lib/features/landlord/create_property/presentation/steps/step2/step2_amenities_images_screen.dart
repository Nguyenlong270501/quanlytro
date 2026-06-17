import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/constants/app_sizes.dart';
import '../../../../../../core/constants/property_constants.dart';
import '../../../blocs/step2/step2_cubit.dart';
import '../../../blocs/step2/step2_state.dart';
import '../../shared_widgets/section_card.dart';
import 'widgets/amenity_picker.dart';
import 'widgets/image_grid_picker.dart';
import 'widgets/rules_picker.dart';
import '../../../../../../core/services/image_picker_service.dart';

class StepAmenitiesImagesScreen extends StatelessWidget {
  const StepAmenitiesImagesScreen({super.key});

  Future<void> _pickCurfew(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 23, minute: 0),
    );
    if (picked == null || !context.mounted) return;
    final hh = picked.hour.toString().padLeft(2, '0');
    final mm = picked.minute.toString().padLeft(2, '0');
    context.read<Step2Cubit>().updateCurfew('$hh:$mm');
  }

  Future<void> _pickImages(BuildContext context) async {
    final picker = ImagePickerService();
    final files = await picker.pickMultipleImages();
    if (files.isEmpty || !context.mounted) return;

    final cubit = context.read<Step2Cubit>();
    for (var file in files) {
      cubit.addImage(file.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<Step2Cubit, Step2State>(
      builder: (context, state) {
        final cubit = context.read<Step2Cubit>();
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionCard(
                emoji: '✨',
                title: 'Tiện ích chung',
                subtitle: 'Chọn các tiện ích dùng chung cho cả khu.',
                child: AmenityPicker(
                  options: PropertyConstants.amenities,
                  activeLabels: state.activeAmenities,
                  onToggle: cubit.toggleAmenity,
                ),
              ),
              AppSizes.gapH16,
              SectionCard(
                emoji: '📋',
                title: 'Nội quy & Đặc điểm',
                subtitle: 'Những quy định giúp khách thuê dễ dàng quyết định.',
                child: RulesPicker(
                  activeRules: state.activeRules,
                  curfew: state.curfew,
                  notes: state.ruleNotes,
                  onToggleRule: cubit.toggleRule,
                  onPickCurfew: () => _pickCurfew(context),
                  onChangeNotes: cubit.updateRuleNotes,
                  curfewHasError: state.showErrors && !state.isCurfewValid,
                ),
              ),
              AppSizes.gapH16,
              SectionCard(
                emoji: '📸',
                title: 'Hình ảnh chung',
                subtitle:
                    'Có thể tải lên ảnh mặt tiền, nhà xe hoặc lối đi chung ',
                child: ImageGridPicker(
                  urls: state.imageUrls,
                  onAdd: () => _pickImages(context),
                  onRemoveAt: cubit.removeImageAt,
                  maxCount: Step2State.maxImages,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
