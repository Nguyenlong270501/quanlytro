import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/constants/app_sizes.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_style.dart';
import '../../../../../../core/widgets/full_screen_image_viewer.dart';

class IdCardSection extends StatelessWidget {
  const IdCardSection({
    super.key,
    required this.frontUrl,
    required this.backUrl,
  });

  final String frontUrl;
  final String backUrl;

  static bool _isNetworkUrl(String s) {
    final t = s.trim();
    return t.startsWith('http://') || t.startsWith('https://');
  }

  List<String> _gallery() {
    final u = <String>[];
    if (_isNetworkUrl(frontUrl)) {
      u.add(frontUrl.trim());
    }
    if (_isNetworkUrl(backUrl)) {
      u.add(backUrl.trim());
    }
    return u;
  }

  @override
  Widget build(BuildContext context) {
    final gallery = _gallery();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ảnh căn cước công dân',
          style: AppTypography.bold14(color: AppColors.textPrimary),
        ),
        AppSizes.gapH12,
        Row(
          children: [
            Expanded(
              child: _CccdViewTile(
                sideLabel: 'Mặt trước',
                imageUrl: frontUrl,
                onTapNetwork: _isNetworkUrl(frontUrl) && gallery.isNotEmpty
                    ? () {
                        final i = gallery.indexOf(frontUrl.trim());
                        FullScreenImageViewer.show(
                          context,
                          imageUrls: gallery,
                          initialIndex: i >= 0 ? i : 0,
                        );
                      }
                    : null,
              ),
            ),
            AppSizes.gapW12,
            Expanded(
              child: _CccdViewTile(
                sideLabel: 'Mặt sau',
                imageUrl: backUrl,
                onTapNetwork: _isNetworkUrl(backUrl) && gallery.isNotEmpty
                    ? () {
                        final i = gallery.indexOf(backUrl.trim());
                        FullScreenImageViewer.show(
                          context,
                          imageUrls: gallery,
                          initialIndex: i >= 0 ? i : 0,
                        );
                      }
                    : null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CccdViewTile extends StatelessWidget {
  const _CccdViewTile({
    required this.sideLabel,
    required this.imageUrl,
    this.onTapNetwork,
  });

  final String sideLabel;
  final String imageUrl;
  final VoidCallback? onTapNetwork;

  static bool _isNetworkUrl(String s) {
    final t = s.trim();
    return t.startsWith('http://') || t.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    final trimmed = imageUrl.trim();
    final hasUrl = trimmed.isNotEmpty && _isNetworkUrl(trimmed);

    return Material(
      color: AppColors.surfaceMuted,
      borderRadius: BorderRadius.circular(16.r),
      child: AspectRatio(
        aspectRatio: 1.15,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (hasUrl)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onTapNetwork,
                  child: Image.network(
                    trimmed,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      }
                      return Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 2,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.broken_image_outlined,
                          color: AppColors.textSecondary,
                        ),
                        AppSizes.gapH4,
                        Text(
                          'Lỗi tải ảnh',
                          style: AppTypography.medium12(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ColoredBox(
                  color: AppColors.surfaceMuted,
                  child: Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: AppColors.textDisabled,
                    ),
                  ),
                ),
              Positioned(
                left: 8.w,
                top: 8.h,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    sideLabel,
                    style: AppTypography.bold10(color: AppColors.surface),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
