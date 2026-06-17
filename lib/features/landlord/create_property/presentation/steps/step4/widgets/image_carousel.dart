import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../../../../core/theme/app_colors.dart';
import '../../../../../../../core/widgets/full_screen_image_viewer.dart';

class ImageCarousel extends StatefulWidget {
  const ImageCarousel({
    super.key,
    required this.images,
    this.enableFullscreenOnTap = true,
  });

  final List<String> images;
  final bool enableFullscreenOnTap;

  static bool _isNetworkUrl(String path) {
    final t = path.trim();
    return t.startsWith('http://') || t.startsWith('https://');
  }

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  final PageController _controller = PageController();
  final ValueNotifier<int> _currentIndex = ValueNotifier<int>(0);

  @override
  void dispose() {
    _controller.dispose();
    _currentIndex.dispose();
    super.dispose();
  }

  void _openFullscreen(BuildContext context, int tappedIndex) {
    if (!widget.enableFullscreenOnTap) {
      return;
    }
    final hasAny = widget.images.any((e) => e.trim().isNotEmpty);
    if (!hasAny) {
      return;
    }
    FullScreenImageViewer.show(
      context,
      imageUrls: widget.images,
      initialIndex: tappedIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        PageView.builder(
          controller: _controller,
          allowImplicitScrolling: true,
          itemCount: widget.images.length,
          onPageChanged: (index) => _currentIndex.value = index,
          itemBuilder: (context, index) {
            final imagePath = widget.images[index];

            if (ImageCarousel._isNetworkUrl(imagePath)) {
              final image = CachedNetworkImage(
                imageUrl: imagePath.trim(),
                fit: BoxFit.cover,
                memCacheWidth: 600,
                placeholder: (context, url) => Container(
                  color: AppColors.surfaceMuted,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppColors.surfaceMuted,
                  child: Icon(
                    Icons.broken_image_rounded,
                    color: AppColors.textDisabled,
                  ),
                ),
              );
              if (!widget.enableFullscreenOnTap) {
                return image;
              }
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _openFullscreen(context, index),
                child: image,
              );
            }
            final fileImage = Image.file(File(imagePath), fit: BoxFit.cover);
            if (!widget.enableFullscreenOnTap) {
              return fileImage;
            }
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _openFullscreen(context, index),
              child: fileImage,
            );
          },
        ),

        Positioned(
          bottom: 12,
          child: ValueListenableBuilder<int>(
            valueListenable: _currentIndex,
            builder: (context, currentIndex, child) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(widget.images.length, (index) {
                  final isActive = index == currentIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: isActive ? 18 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.surface
                          : AppColors.surface.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              );
            },
          ),
        ),
      ],
    );
  }
}
