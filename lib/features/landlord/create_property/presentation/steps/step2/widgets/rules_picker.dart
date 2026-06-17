import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../../core/constants/app_sizes.dart';
import '../../../../../../../core/constants/property_constants.dart';
import '../../../../../../../core/theme/app_colors.dart';
import '../../../shared_widgets/filled_text_field.dart';
import 'amenity_chip.dart';


class RulesPicker extends StatefulWidget {
  const RulesPicker({
    super.key,
    required this.activeRules,
    required this.curfew,
    required this.notes,
    required this.onToggleRule,
    required this.onPickCurfew,
    required this.onChangeNotes,
    this.curfewHasError = false,
  });

  final Set<String> activeRules;
  final String curfew;
  final String notes;
  final ValueChanged<String> onToggleRule;
  final Future<void> Function() onPickCurfew;
  final ValueChanged<String> onChangeNotes;
  final bool curfewHasError;

  @override
  State<RulesPicker> createState() => _RulesPickerState();
}

class _RulesPickerState extends State<RulesPicker> {
  late final TextEditingController _curfewController;
  late final TextEditingController _notesController;

  bool get _showCurfewField => !widget.activeRules.contains(RuleKeys.freeTime);

  @override
  void initState() {
    super.initState();
    _curfewController = TextEditingController(text: widget.curfew);
    _notesController = TextEditingController(text: widget.notes);
  }

  @override
  void didUpdateWidget(covariant RulesPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.curfew != _curfewController.text) {
      _curfewController.text = widget.curfew;
    }
    if (widget.notes != _notesController.text) {
      _notesController.text = widget.notes;
    }
  }

  @override
  void dispose() {
    _curfewController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10.w,
          runSpacing: 10.h,
          children: [
            AmenityChip(
              emoji: '🗝️',
              label: 'Không chung chủ',
              active: widget.activeRules.contains(RuleKeys.noShared),
              onTap: () => widget.onToggleRule(RuleKeys.noShared),
            ),
            AmenityChip(
              emoji: '🐾',
              label: 'Cho nuôi Pet',
              active: widget.activeRules.contains(RuleKeys.allowPet),
              onTap: () => widget.onToggleRule(RuleKeys.allowPet),
            ),
            AmenityChip(
              emoji: '🕛',
              label: 'Giờ giấc tự do',
              active: widget.activeRules.contains(RuleKeys.freeTime),
              onTap: () => widget.onToggleRule(RuleKeys.freeTime),
            ),
            AmenityChip(
              emoji: '🛵',
              label: 'Xe điện',
              active: widget.activeRules.contains(RuleKeys.electricBike),
              onTap: () => widget.onToggleRule(RuleKeys.electricBike),
            ),
          ],
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: _showCurfewField
              ? Padding(
                  padding: EdgeInsets.only(top: 12.h),
                  child: FilledTextField(
                    controller: _curfewController,
                    hintText: 'Giờ đóng cửa (VD: 23:00) *',
                    readOnly: true,
                    hasError: widget.curfewHasError,
                    onTap: () => widget.onPickCurfew(),
                    suffix: Padding(
                      padding: EdgeInsets.only(right: 12.w),
                      child: Icon(
                        Icons.access_time,
                        size: 18.sp,
                        color: widget.curfewHasError
                            ? AppColors.danger
                            : AppColors.textMuted,
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
        AppSizes.gapH12,
        FilledTextField(
          controller: _notesController,
          hintText: 'Ghi chú thêm nội quy khác (Không bắt buộc)...',
          maxLines: 4,
          minLines: 3,
          onChanged: widget.onChangeNotes,
        ),
      ],
    );
  }
}
