import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

abstract final class AppReasonDialog {
  static Future<String?> show(
    BuildContext context, {
    required String title,
    required String description,
    String hintText = 'Bắt buộc nhập lý do...',
    String dismissLabel = 'Hủy',
    String confirmLabel = 'Xác nhận',
    int maxLength = 200,
    int maxLines = 4,
    bool barrierDismissible = true,
  }) async {
    return await showDialog<String>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (dialogContext) {
        return _ReasonDialogContent(
          title: title,
          description: description,
          hintText: hintText,
          dismissLabel: dismissLabel,
          confirmLabel: confirmLabel,
          maxLength: maxLength,
          maxLines: maxLines,
        );
      },
    );
  }
}

class _ReasonDialogContent extends StatefulWidget {
  const _ReasonDialogContent({
    required this.title,
    required this.description,
    required this.hintText,
    required this.dismissLabel,
    required this.confirmLabel,
    required this.maxLength,
    required this.maxLines,
  });

  final String title;
  final String description;
  final String hintText;
  final String dismissLabel;
  final String confirmLabel;
  final int maxLength;
  final int maxLines;

  @override
  State<_ReasonDialogContent> createState() => _ReasonDialogContentState();
}

class _ReasonDialogContentState extends State<_ReasonDialogContent> {
  late final TextEditingController _controller;
  late final ValueNotifier<bool> _isButtonEnabled;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _isButtonEnabled = ValueNotifier<bool>(false);
  }

  @override
  void dispose() {
    _controller.dispose();
    _isButtonEnabled.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      title: Text(
        widget.title,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.description,
            style: TextStyle(color: Colors.grey[600], fontSize: 14.sp),
          ),
          SizedBox(height: 16.h),
          TextField(
            controller: _controller,
            maxLength: widget.maxLength,
            maxLines: widget.maxLines,
            autofocus: true,
            onChanged: (val) {
              _isButtonEnabled.value = val.trim().isNotEmpty;
            },
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: TextStyle(fontSize: 14.sp, color: Colors.grey[400]),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: EdgeInsets.all(12.w),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
      actionsPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            widget.dismissLabel,
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ValueListenableBuilder<bool>(
          valueListenable: _isButtonEnabled,
          builder: (context, enabled, _) {
            return FilledButton(
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20.w),
              ),
              onPressed: enabled
                  ? () => Navigator.pop(context, _controller.text.trim())
                  : null,
              child: Text(widget.confirmLabel),
            );
          },
        ),
      ],
    );
  }
}
