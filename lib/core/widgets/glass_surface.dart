import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:taskflow/core/theme/app_colors.dart';
import 'package:taskflow/core/theme/app_radius.dart';
import 'package:taskflow/core/theme/app_shadows.dart';

class GlassSurface extends StatelessWidget {
  final Widget child;
  final BorderRadius? radius;
  final EdgeInsetsGeometry? padding;

  const GlassSurface({
    super.key,
    required this.child,
    this.radius,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderRadius = radius ?? AppRadius.cardRadius;
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: AppShadows.glassBlurSigma, sigmaY: AppShadows.glassBlurSigma),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: isDark ? AppColors.glassSurfaceDark : AppColors.glassSurfaceLight,
            borderRadius: borderRadius,
            border: Border.all(
              color: isDark ? AppColors.glassBorderDark : AppColors.glassBorderLight,
              width: 1,
            ),
            boxShadow: AppShadows.glass(isDark),
          ),
          child: child,
        ),
      ),
    );
  }
}