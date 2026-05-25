import 'package:flutter/material.dart';

import '../app_colors.dart';

/// Path for the bundled FitLife brand image.
abstract final class FitLifeAssets {
  static const logo = 'assets/FitLife-Logo.png';
}

/// FitLifeLogo — brand mark from assets; optional wordmark and icon-only crop.
class FitLifeLogo extends StatelessWidget {
  final double height;
  final bool showWordmark;
  /// When true, shows only the top mark (hides text baked into the PNG).
  final bool clipToMark;

  const FitLifeLogo({
    super.key,
    this.height = 160,
    this.showWordmark = false,
    this.clipToMark = false,
  });

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      FitLifeAssets.logo,
      height: height,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      errorBuilder: (_, __, ___) => Icon(
        Icons.image_not_supported_outlined,
        size: height * 0.4,
        color: Colors.grey,
      ),
    );

    final mark = clipToMark
        ? ClipRect(
            child: Align(
              alignment: Alignment.topCenter,
              heightFactor: 0.58,
              child: image,
            ),
          )
        : image;

    if (!showWordmark) return mark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        SizedBox(height: height * 0.06),
        // Widget: App name
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Fit',
                style: TextStyle(
                  color: const Color(0xFF1E293B),
                  fontSize: height * 0.2,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              TextSpan(
                text: 'Life',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: height * 0.2,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
