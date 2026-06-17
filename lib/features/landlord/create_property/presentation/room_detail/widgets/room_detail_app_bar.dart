import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_style.dart';
import 'close_button.dart';

class RoomDetailAppBar extends StatelessWidget {
  const RoomDetailAppBar({super.key, 
    required this.isEdit,
    required this.onClose,
    required this.onSave,
  });

  final bool isEdit;
  final VoidCallback onClose;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 8.w, 12.h),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.divider, width: 1)),
      ),
      child: Row(
        children: [
          ButtonClose(onTap: onClose),
          Expanded(
            child: Text(
              'Chi tiết phòng',
              textAlign: TextAlign.center,
              style: AppTypography.bold16(color: AppColors.textPrimary),
            ),
          ),
          InkWell(
            onTap: onSave,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              child: Text(
                isEdit ? 'Cập nhật' : 'Lưu',
                style: AppTypography.bold14(color: AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}