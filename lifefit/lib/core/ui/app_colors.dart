import 'package:flutter/material.dart';

/// Brand palette — primary #19BDAA, background #F9FAFB.
abstract final class AppColors {
  static const background = Color(0xFFF9FAFB);

  static const primary = Color(0xFF19BDAA);
  static const primaryDark = Color(0xFF0E9485);
  static const primaryLight = Color(0xFF2DD4C4);

  /// Neutral headings (not a competing brand hue).
  static const textPrimary = Color(0xFF1E293B);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, primary, primaryDark],
  );
}
