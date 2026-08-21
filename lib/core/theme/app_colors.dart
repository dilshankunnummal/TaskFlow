import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color seed = Color(0xFF5B5BF6);

  static const Color darkBackground = Color(0xFF0A0A0F);
  static const Color darkSurface = Color(0xFF121218);
  static const Color darkSurfaceElevated = Color(0xFF181820);
  static const Color darkDivider = Color(0x14FFFFFF);
  static const Color darkOnSurface = Color(0xFFEDEDF2);
  static const Color darkOnSurfaceMuted = Color(0xFF9A9AA8);

  static const Color lightBackground = Color(0xFFF6F6F9);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceElevated = Color(0xFFFBFBFD);
  static const Color lightDivider = Color(0x14000000);
  static const Color lightOnSurface = Color(0xFF16161D);
  static const Color lightOnSurfaceMuted = Color(0xFF6B6B78);

  static const Color success = Color(0xFF2FBE7A);
  static const Color warning = Color(0xFFE8A33D);
  static const Color danger = Color(0xFFE8543D);
  static const Color info = Color(0xFF3D8DE8);

  static const Color glassSurfaceDark = Color(0x1FFFFFFF);
  static const Color glassBorderDark = Color(0x1AFFFFFF);
  static const Color glassSurfaceLight = Color(0xB2FFFFFF);
  static const Color glassBorderLight = Color(0x1A000000);

  static const Gradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF5B5BF6), Color(0xFF8A5CF6)],
  );

  static const Gradient backgroundWashDark = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF15151F), Color(0xFF0A0A0F)],
  );

  static const Gradient backgroundWashLight = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF0F0F7), Color(0xFFF6F6F9)],
  );

  static ColorScheme darkColorScheme() {
    return ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.dark,
      surface: darkSurface,
      onSurface: darkOnSurface,
      error: danger,
    );
  }

  static ColorScheme lightColorScheme() {
    return ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.light,
      surface: lightSurface,
      onSurface: lightOnSurface,
      error: danger,
    );
  }

  static Color statusColor(String status) {
    return switch (status) {
      'success' || 'done' || 'active' => success,
      'warning' || 'in_progress' => warning,
      'danger' || 'blocked' || 'overdue' => danger,
      'info' || 'todo' => info,
      _ => info,
    };
  }
}
