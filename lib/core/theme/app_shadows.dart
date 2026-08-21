import 'package:flutter/material.dart';

abstract final class AppShadows {
  static List<BoxShadow> level1(bool isDark) {
    return [
      BoxShadow(
        color: Colors.black.withOpacity(isDark ? 0.28 : 0.06),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ];
  }

  static List<BoxShadow> level2(bool isDark) {
    return [
      BoxShadow(
        color: Colors.black.withOpacity(isDark ? 0.36 : 0.10),
        blurRadius: 24,
        offset: const Offset(0, 8),
      ),
    ];
  }

  static List<BoxShadow> glass(bool isDark) {
    return [
      BoxShadow(
        color: Colors.black.withOpacity(isDark ? 0.45 : 0.12),
        blurRadius: 32,
        offset: const Offset(0, 12),
      ),
      BoxShadow(
        color: Colors.white.withOpacity(isDark ? 0.04 : 0.6),
        blurRadius: 1,
        offset: const Offset(0, 1),
      ),
    ];
  }

  static const double glassBlurSigma = 24;
}
