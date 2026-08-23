import 'package:flutter/material.dart';
import 'package:taskflow/core/theme/app_colors.dart';
import 'package:taskflow/core/theme/app_motion.dart';
import 'package:taskflow/core/theme/app_radius.dart';
import 'package:taskflow/core/theme/app_typography.dart';

abstract final class AppTheme {
  static ThemeData dark() {
    final colorScheme = AppColors.darkColorScheme();
    final textTheme = AppTypography.textTheme(AppColors.darkOnSurface);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.darkBackground,
      canvasColor: AppColors.darkBackground,
      textTheme: textTheme,
      dividerColor: AppColors.darkDivider,
      dividerTheme: const DividerThemeData(thickness: 1, space: 1, color: AppColors.darkDivider),
      splashFactory: InkRipple.splashFactory,
      pageTransitionsTheme: _pageTransitionsTheme,
      elevatedButtonTheme: _elevatedButtonTheme(colorScheme),
      outlinedButtonTheme: _outlinedButtonTheme(colorScheme),
      textButtonTheme: _textButtonTheme(colorScheme),
      inputDecorationTheme: _inputDecorationTheme(
        fillColor: AppColors.darkSurfaceElevated,
        borderColor: AppColors.darkDivider,
        hintColor: AppColors.darkOnSurfaceMuted,
        focusColor: colorScheme.primary,
      ),
      cardTheme: _cardTheme(AppColors.darkSurface, AppColors.darkDivider),
      chipTheme: _chipTheme(colorScheme, AppColors.darkSurfaceElevated),
      dialogTheme: _dialogTheme(AppColors.darkSurfaceElevated),
      bottomSheetTheme: _bottomSheetTheme(AppColors.darkSurfaceElevated),
      snackBarTheme: _snackBarTheme(AppColors.darkSurfaceElevated, AppColors.darkOnSurface),
      popupMenuTheme: _popupMenuTheme(
        surface: AppColors.darkSurfaceElevated,
        border: AppColors.darkDivider,
        textColor: AppColors.darkOnSurface,
      ),
      dropdownMenuTheme: _dropdownMenuTheme(
        surface: AppColors.darkSurfaceElevated,
        border: AppColors.darkDivider,
      ),
    );
  }

  static ThemeData light() {
    final colorScheme = AppColors.lightColorScheme();
    final textTheme = AppTypography.textTheme(AppColors.lightOnSurface);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.lightBackground,
      canvasColor: AppColors.lightBackground,
      textTheme: textTheme,
      dividerColor: AppColors.lightDivider,
      dividerTheme: const DividerThemeData(thickness: 1, space: 1, color: AppColors.lightDivider),
      splashFactory: InkRipple.splashFactory,
      pageTransitionsTheme: _pageTransitionsTheme,
      elevatedButtonTheme: _elevatedButtonTheme(colorScheme),
      outlinedButtonTheme: _outlinedButtonTheme(colorScheme),
      textButtonTheme: _textButtonTheme(colorScheme),
      inputDecorationTheme: _inputDecorationTheme(
        fillColor: AppColors.lightSurfaceElevated,
        borderColor: AppColors.lightDivider,
        hintColor: AppColors.lightOnSurfaceMuted,
        focusColor: colorScheme.primary,
      ),
      cardTheme: _cardTheme(AppColors.lightSurface, AppColors.lightDivider),
      chipTheme: _chipTheme(colorScheme, AppColors.lightSurfaceElevated),
      dialogTheme: _dialogTheme(AppColors.lightSurfaceElevated),
      bottomSheetTheme: _bottomSheetTheme(AppColors.lightSurfaceElevated),
      snackBarTheme: _snackBarTheme(AppColors.lightSurfaceElevated, AppColors.lightOnSurface),
      popupMenuTheme: _popupMenuTheme(
        surface: AppColors.lightSurfaceElevated,
        border: AppColors.lightDivider,
        textColor: AppColors.lightOnSurface,
      ),
      dropdownMenuTheme: _dropdownMenuTheme(
        surface: AppColors.lightSurfaceElevated,
        border: AppColors.lightDivider,
      ),
    );
  }

  static const PageTransitionsTheme _pageTransitionsTheme = PageTransitionsTheme(
    builders: {
      TargetPlatform.android: ZoomPageTransitionsBuilder(),
      // TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      // TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
    },
  );

  static ElevatedButtonThemeData _elevatedButtonTheme(ColorScheme colorScheme) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        disabledBackgroundColor: colorScheme.onSurface.withOpacity(0.08),
        disabledForegroundColor: colorScheme.onSurface.withOpacity(0.32),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.inputRadius),
        animationDuration: AppMotion.micro,
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    );
  }

  static OutlinedButtonThemeData _outlinedButtonTheme(ColorScheme colorScheme) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colorScheme.onSurface,
        side: BorderSide(color: colorScheme.onSurface.withOpacity(0.14)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.inputRadius),
        animationDuration: AppMotion.micro,
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    );
  }

  static TextButtonThemeData _textButtonTheme(ColorScheme colorScheme) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colorScheme.primary,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.inputRadius),
        animationDuration: AppMotion.micro,
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    );
  }

  static InputDecorationTheme _inputDecorationTheme({
    required Color fillColor,
    required Color borderColor,
    required Color hintColor,
    required Color focusColor,
  }) {
    OutlineInputBorder border(Color color, {double width = 1}) {
      return OutlineInputBorder(
        borderRadius: AppRadius.inputRadius,
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return InputDecorationTheme(
      filled: true,
      fillColor: fillColor,
      hintStyle: TextStyle(color: hintColor, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: border(borderColor),
      enabledBorder: border(borderColor),
      focusedBorder: border(focusColor, width: 1.5),
      errorBorder: border(AppColors.danger),
      focusedErrorBorder: border(AppColors.danger, width: 1.5),
    );
  }

  static CardThemeData _cardTheme(Color surface, Color border) {
    return CardThemeData(
      color: surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.cardRadius,
        side: BorderSide(color: border, width: 1),
      ),
    );
  }

  static ChipThemeData _chipTheme(ColorScheme colorScheme, Color background) {
    return ChipThemeData(
      backgroundColor: background,
      selectedColor: colorScheme.primary.withOpacity(0.16),
      labelStyle: TextStyle(color: colorScheme.onSurface, fontSize: 12, fontWeight: FontWeight.w600),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.pillRadius),
      side: BorderSide.none,
    );
  }

  static DialogThemeData _dialogTheme(Color surface) {
    return DialogThemeData(
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.dialogRadius),
    );
  }

  static BottomSheetThemeData _bottomSheetTheme(Color surface) {
    return BottomSheetThemeData(
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.sheetRadius),
    );
  }

  static SnackBarThemeData _snackBarTheme(Color surface, Color onSurface) {
    return SnackBarThemeData(
      backgroundColor: surface,
      contentTextStyle: TextStyle(color: onSurface, fontSize: 14),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.inputRadius),
    );
  }

  static PopupMenuThemeData _popupMenuTheme({
    required Color surface,
    required Color border,
    required Color textColor,
  }) {
    return PopupMenuThemeData(
      color: surface,
      surfaceTintColor: Colors.transparent,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.cardRadius,
        side: BorderSide(color: border, width: 1),
      ),
      textStyle: TextStyle(
        color: textColor,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  static DropdownMenuThemeData _dropdownMenuTheme({
    required Color surface,
    required Color border,
  }) {
    return DropdownMenuThemeData(
      menuStyle: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(surface),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        elevation: const WidgetStatePropertyAll(4),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: AppRadius.cardRadius,
            side: BorderSide(color: border, width: 1),
          ),
        ),
      ),
    );
  }
}
