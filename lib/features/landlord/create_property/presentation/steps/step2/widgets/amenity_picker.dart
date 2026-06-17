import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../data/models/amenity_option.dart';
import 'amenity_chip.dart';


class AmenityPicker extends StatelessWidget {
  const AmenityPicker({
    super.key,
    required this.options,
    required this.activeLabels,
    required this.onToggle,
  });

  final List<AmenityOption> options;
  final Set<String> activeLabels;
  final ValueChanged<String> onToggle;

  static Set<String> defaultActive(List<AmenityOption> options) {
    return {for (final o in options) if (o.initiallyActive) o.label};
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10.w,
      runSpacing: 10.h,
      children: [
        for (final opt in options)
          AmenityChip(
            emoji: opt.emoji,
            label: opt.label,
            active: activeLabels.contains(opt.label),
            onTap: () => onToggle(opt.label),
          ),
      ],
    );
  }
}
