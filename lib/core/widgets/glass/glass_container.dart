import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:taskflow/core/theme/app_colors.dart';
import 'package:taskflow/core/theme/app_shadows.dart';

final class GlassContainer extends StatelessWidget {
  const GlassContainer({
    required this.child,
    super.key,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.padding,
    this.blurSigma = AppShadows.glassBlurSigma,
    this.withShadow = true,
  });

  final Widget child;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry? padding;
  final double blurSigma;
  final bool withShadow;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.glassSurfaceDark : AppColors.glassSurfaceLight;
    final borderColor = isDark ? AppColors.glassBorderDark : AppColors.glassBorderLight;

    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: withShadow ? AppShadows.glass(isDark) : null,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: borderRadius,
              border: Border.all(color: borderColor, width: 1),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
