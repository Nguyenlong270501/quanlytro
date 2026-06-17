import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/constants/app_sizes.dart';
import '../../../../../../core/constants/property_constants.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_style.dart';
import '../../../../create_property/data/models/property_model.dart';
import '../../../../create_property/presentation/steps/step4/widgets/summary_chip.dart';

class PropertyFacilitiesSection extends StatelessWidget {
  const PropertyFacilitiesSection({super.key, required this.property});

  final PropertyModel property;

  @override
  Widget build(BuildContext context) {
    final facilities = property.facilities ?? [];
    if (facilities.isEmpty) {
      return Text(
        'Chưa chọn tiện ích nào.',
        style: AppTypography.medium12(color: AppColors.textMuted),
      );
    }

    final chipWidgets = facilities.map((facility) {
      final matchedOption = PropertyConstants.amenities.where(
        (a) => a.label == facility,
      );
      final emoji = matchedOption.isNotEmpty ? matchedOption.first.emoji : '✅';
      return SummaryChip(emoji: emoji, label: facility);
    }).toList();

    return Wrap(spacing: 8.w, runSpacing: 8.h, children: chipWidgets);
  }
}

class PropertyRulesSection extends StatelessWidget {
  const PropertyRulesSection({super.key, required this.property});

  final PropertyModel property;

  @override
  Widget build(BuildContext context) {
    final selectedRules = property.rules ?? [];
    final notes = (property.rulesDescription ?? '').trim();
    final hasNotes = notes.isNotEmpty;
    final curfew = (property.curfewTime ?? '').trim();

    final chipWidgets = <Widget>[];

    for (final option in PropertyConstants.rentalRules) {
      final isActive = selectedRules.contains(option.key);

      chipWidgets.add(
        SummaryChip(
          emoji: option.displayEmoji(isActive),
          label: option.displayLabel(isActive),
        ),
      );
    }

    if (!selectedRules.contains(RuleKeys.freeTime) && curfew.isNotEmpty) {
      chipWidgets.add(SummaryChip(emoji: '🕛', label: 'Đóng cửa $curfew'));
    }

    if (chipWidgets.isEmpty && !hasNotes) {
      return Text(
        'Chưa chọn nội quy nào.',
        style: AppTypography.medium12(color: AppColors.textMuted),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (chipWidgets.isNotEmpty)
          Wrap(spacing: 8.w, runSpacing: 8.h, children: chipWidgets),
        if (hasNotes) ...[
          if (chipWidgets.isNotEmpty) AppSizes.gapH10,
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
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
                          text: notes,
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
}

/// Giữ tương thích — gộp cả hai (ưu tiên dùng section riêng).
class PropertyAmenitiesAndRules extends StatelessWidget {
  const PropertyAmenitiesAndRules({super.key, required this.property});

  final PropertyModel property;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PropertyFacilitiesSection(property: property),
        AppSizes.gapH12,
        PropertyRulesSection(property: property),
      ],
    );
  }
}
