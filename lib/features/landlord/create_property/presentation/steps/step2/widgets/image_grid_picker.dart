import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../../core/theme/app_colors.dart';
import '../../../../../../../core/theme/app_style.dart';

class ImageGridPicker extends StatelessWidget {
  const ImageGridPicker({
    super.key,
    required this.urls,
    required this.onAdd,
    required this.onRemoveAt,
    this.maxCount,
    this.hasError = false,
  });

  final List<String> urls;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemoveAt;


  final int? maxCount;
  final bool hasError;

  bool get _canAdd => maxCount == null || urls.length < maxCount!;

  @override
  Widget build(BuildContext context) {
    const crossAxisCount = 3;
    final spacing = 10.w;
    return GridView.count(
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: spacing,
      crossAxisSpacing: spacing,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        if (_canAdd) _AddImageTile(onTap: onAdd, hasError: hasError),
        for (var i = 0; i < urls.length; i++)
          _ImageTile(
            url: urls[i],
            onDelete: () => onRemoveAt(i),
          ),
      ],
    );
  }
}

class _AddImageTile extends StatelessWidget {
  const _AddImageTile({required this.onTap, this.hasError = false});

  final VoidCallback onTap;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final borderColor = hasError ? AppColors.danger : AppColors.border;
    final iconColor = hasError ? AppColors.danger : AppColors.textMuted;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add,
              size: 24.sp,
              color: iconColor,
            ),
            SizedBox(height: 2.h),
            Text(
              'Thêm ảnh',
              style: AppTypography.medium10(color: iconColor),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageTile extends StatelessWidget {
  const _ImageTile({required this.url, required this.onDelete});

  final String url;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isNetwork = url.startsWith('http');
    final Widget imageWidget = isNetwork
        ? Image.network(
            url,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return Container(
                color: AppColors.surfaceMuted,
                alignment: Alignment.center,
                child: SizedBox(
                  width: 18.w,
                  height: 18.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.textMuted,
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) => Container(
              color: AppColors.surfaceMuted,
              alignment: Alignment.center,
              child: Icon(
                Icons.image_not_supported_outlined,
                size: 18.sp,
                color: AppColors.textMuted,
              ),
            ),
          )
        : Image.file(
            File(url),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: AppColors.surfaceMuted,
              alignment: Alignment.center,
              child: Icon(
                Icons.image_not_supported_outlined,
                size: 18.sp,
                color: AppColors.textMuted,
              ),
            ),
          );

    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: imageWidget,
        ),
        Positioned(
          top: 6.h,
          right: 6.w,
          child: _DeleteButton(onTap: onDelete),
        ),
      ],
    );
  }
}

class _DeleteButton extends StatelessWidget {
  const _DeleteButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 22.w,
        height: 22.w,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.close,
          size: 12.sp,
          color: Colors.white,
        ),
      ),
    );
  }
}
