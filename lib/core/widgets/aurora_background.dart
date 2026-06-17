import 'package:flutter/material.dart';
import 'dart:ui' show ImageFilter;

class AuroraBackground extends StatelessWidget {
  const AuroraBackground({
    super.key,
    this.blurSigma = 60,
    this.darkMode = true,
  });

  /// Higher values = softer but more expensive.
  final double blurSigma;

  /// If you want a lighter background for light theme.
  final bool darkMode;

  @override
  Widget build(BuildContext context) {
    final base = darkMode
        ? const [
            Color(0xFF0A0A12), // ink
            Color(0xFF0B0A18), // purple-black
            Color(0xFF05060A), // near-black
          ]
        : const [
            Color(0xFFF4F7FF), // airy light
            Color(0xFFEFF3FF),
            Color(0xFFECEBFF),
          ];

    return RepaintBoundary(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Base gradient (full size)
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: base,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Glows (painted first, then blurred together below)
          Positioned(
            top: -140,
            left: -120,
            child: _GlowCircle(
              size: 360,
              colors: darkMode
                  ? const [Color(0xFF7C66FF), Color(0x00140B3A)]
                  : const [Color(0xFF8B7CFF), Color(0x00FFFFFF)],
            ),
          ),
          Positioned(
            top: -180,
            right: -140,
            child: _GlowCircle(
              size: 520,
              colors: darkMode
                  ? const [Color(0xFFB39BFF), Color(0x000B0620)]
                  : const [Color(0xFFB7A7FF), Color(0x00FFFFFF)],
            ),
          ),
          Positioned(
            bottom: -180,
            left: -140,
            child: _GlowCircle(
              size: 520,
              colors: darkMode
                  ? const [Color(0xFFFFB36B), Color(0x00180A06)]
                  : const [Color(0xFFFFC58F), Color(0x00FFFFFF)],
            ),
          ),

          // Blur is costly on real devices during scroll — skip when [blurSigma] <= 0.
          if (blurSigma > 0)
            ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
                child: const SizedBox.expand(),
              ),
            ),

          // Subtle vignette for depth (similar to screenshot)
          IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.05,
                  colors: darkMode
                      ? const [Color(0x00000000), Color(0xCC000000)]
                      : const [Color(0x00FFFFFF), Color(0x22000000)],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  const _GlowCircle({required this.size, required this.colors});

  final double size;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: colors),
        ),
      ),
    );
  }
}
