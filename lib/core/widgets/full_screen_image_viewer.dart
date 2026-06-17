import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class FullScreenImageViewer extends StatefulWidget {
  const FullScreenImageViewer({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0,
  });

  final List<String> imageUrls;
  final int initialIndex;

  static Future<void> show(
    BuildContext context, {
    required List<String> imageUrls,
    int initialIndex = 0,
  }) {
    final effective = <String>[];
    final indexMap = <int, int>{};
    for (var i = 0; i < imageUrls.length; i++) {
      final u = imageUrls[i].trim();
      if (u.isEmpty) {
        continue;
      }
      indexMap[i] = effective.length;
      effective.add(u);
    }
    if (effective.isEmpty) {
      return Future.value();
    }
    var page = indexMap[initialIndex] ?? 0;
    if (page < 0 || page >= effective.length) {
      page = 0;
    }
    return Navigator.of(context, rootNavigator: true).push<void>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) =>
            FullScreenImageViewer(imageUrls: effective, initialIndex: page),
      ),
    );
  }

  static const Color _background = Color(0xFF000000);

  static bool _isNetworkUrl(String path) {
    final t = path.trim();
    return t.startsWith('http://') || t.startsWith('https://');
  }

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  late final PageController _pageController;
  late int _currentPage;

  @override
  void initState() {
    super.initState();
    final safeIndex = widget.initialIndex.clamp(0, widget.imageUrls.length - 1);
    _currentPage = safeIndex;
    _pageController = PageController(initialPage: safeIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FullScreenImageViewer._background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.surface),
        centerTitle: true,
        title: widget.imageUrls.length > 1
            ? Text(
                '${_currentPage + 1}/${widget.imageUrls.length}',
                style: TextStyle(
                  color: AppColors.surface,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  shadows: const [
                    Shadow(
                      color: Colors.black54,
                      blurRadius: 6,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              )
            : null,
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.imageUrls.length,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        itemBuilder: (context, index) {
          final source = widget.imageUrls[index];
          final child = FullScreenImageViewer._isNetworkUrl(source)
              ? CachedNetworkImage(
                  imageUrl: source.trim(),
                  fit: BoxFit.contain,
                  placeholder: (_, __) => Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.surface,
                      ),
                    ),
                  ),
                  errorWidget: (_, __, ___) => Icon(
                    Icons.broken_image_outlined,
                    color: AppColors.textDisabled,
                    size: 50,
                  ),
                )
              : Image.file(
                  File(source.trim()),
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.broken_image_outlined,
                    color: AppColors.textDisabled,
                    size: 50,
                  ),
                );
          return InteractiveViewer(
            minScale: 0.8,
            maxScale: 4,
            child: Center(child: child),
          );
        },
      ),
    );
  }
}
