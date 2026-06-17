import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/constants/app_sizes.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_style.dart';
import '../../../../../../core/widgets/full_screen_image_viewer.dart';

class OptionalDocsSection extends StatelessWidget {
  const OptionalDocsSection({super.key, required this.urls});

  final List<String> urls;

  static bool _isNetworkUrl(String s) {
    final t = s.trim();
    return t.startsWith('http://') || t.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    final gallery = <String>[];
    final indexMap = <int, int>{};
    for (var i = 0; i < urls.length; i++) {
      if (_isNetworkUrl(urls[i])) {
        indexMap[i] = gallery.length;
        gallery.add(urls[i].trim());
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Giấy tờ liên quan đến phòng trọ',
          style: AppTypography.bold14(color: AppColors.textPrimary),
        ),
        AppSizes.gapH12,
        GridView.count(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
          childAspectRatio: 1.6,
          children: List.generate(urls.length, (i) {
            final url = urls[i];
            final openIndex = indexMap[i];
            return ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: _RemoteImage(
                url: url,
                onTapNetwork: openIndex != null && gallery.isNotEmpty
                    ? () => FullScreenImageViewer.show(
                        context,
                        imageUrls: gallery,
                        initialIndex: openIndex,
                      )
                    : null,
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _RemoteImage extends StatelessWidget {
  const _RemoteImage({required this.url, this.onTapNetwork});

  final String url;
  final VoidCallback? onTapNetwork;

  @override
  Widget build(BuildContext context) {
    if (url.trim().isEmpty) {
      return _ImageFallback(message: 'Chưa có ảnh');
    }
    final child = Image.network(
      url,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) {
          return child;
        }
        return Container(
          color: AppColors.accentSoft,
          alignment: Alignment.center,
          child: SizedBox(
            width: 24.w,
            height: 24.w,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) =>
          _ImageFallback(message: 'Không tải được ảnh'),
    );
    if (onTapNetwork == null) {
      return child;
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTapNetwork,
      child: child,
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.accentSoft,
      alignment: Alignment.center,
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              size: 24.sp,
              color: AppColors.textMuted,
            ),
            AppSizes.gapH6,
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.medium12(color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
