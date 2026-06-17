import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/constants/app_sizes.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_style.dart';

Future<String?> showRejectReasonDialog(
  BuildContext context, {
  required String fullName,
}) {
  return showDialog<String>(
    context: context,
    builder: (_) => RejectReasonDialog(fullName: fullName),
  );
}

class RejectReasonDialog extends StatefulWidget {
  const RejectReasonDialog({super.key, required this.fullName});

  final String fullName;

  @override
  State<RejectReasonDialog> createState() => _RejectReasonDialogState();
}

class _RejectReasonDialogState extends State<RejectReasonDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
  }

  void _onChanged() => setState(() {});

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = _controller.text.trim().isNotEmpty;
    final name = widget.fullName.trim().isEmpty
        ? 'người dùng này'
        : widget.fullName;
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      title: Text(
        'Từ chối hồ sơ',
        style: AppTypography.bold16(color: AppColors.textPrimary),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nhập lý do từ chối hồ sơ của $name:',
            style: AppTypography.medium14(color: AppColors.textSecondary),
          ),
          AppSizes.gapH12,
          TextField(
            controller: _controller,
            maxLines: 3,
            maxLength: 200,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            style: AppTypography.medium14(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Ví dụ: Ảnh không rõ nét...',
              hintStyle: AppTypography.medium14(color: AppColors.textMuted),
              filled: true,
              fillColor: AppColors.accentSoft,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 12.h,
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Huỷ',
            style: AppTypography.bold14(color: AppColors.textSecondary),
          ),
        ),
        TextButton(
          onPressed: canSubmit
              ? () => Navigator.of(context).pop(_controller.text)
              : null,
          child: Text(
            'Xác nhận',
            style: AppTypography.bold14(
              color: canSubmit ? AppColors.error : AppColors.textMuted,
            ),
          ),
        ),
      ],
    );
  }
}
