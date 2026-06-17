import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_style.dart';

class ApprovalsSubTab {
  const ApprovalsSubTab({required this.label, required this.count});

  final String label;
  final int count;
}

class ApprovalsSubTabs extends StatelessWidget {
  const ApprovalsSubTabs({
    super.key,
    required this.currentIndex,
    required this.tabs,
    required this.onChanged,
  });

  final int currentIndex;
  final List<ApprovalsSubTab> tabs;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          for (int i = 0; i < tabs.length; i++)
            Expanded(
              child: _UnderlineTab(
                label: tabs[i].label,
                count: tabs[i].count,
                selected: currentIndex == i,
                onTap: () => onChanged(i),
              ),
            ),
        ],
      ),
    );
  }
}

class _UnderlineTab extends StatelessWidget {
  const _UnderlineTab({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textMuted;
    return InkWell(
      onTap: onTap,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 14.h),
            child: Text(
              '$label ($count)',
              style: selected
                  ? AppTypography.bold14(color: color)
                  : AppTypography.medium14(color: color),
            ),
          ),
          Container(
            height: 3.h,
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}
