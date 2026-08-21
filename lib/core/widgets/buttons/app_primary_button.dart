import 'package:flutter/material.dart';
import 'package:taskflow/core/theme/app_colors.dart';
import 'package:taskflow/core/theme/app_motion.dart';
import 'package:taskflow/core/theme/app_radius.dart';
import 'package:taskflow/core/theme/app_spacing.dart';

final class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    required this.label,
    super.key,
    this.onPressed,
    this.isLoading = false,
    this.leadingIcon,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? leadingIcon;
  final bool expand;

  bool get _isEnabled => onPressed != null && !isLoading;

  @override
  Widget build(BuildContext context) {
    final child = AnimatedSwitcher(
      duration: AppMotion.micro,
      child: isLoading
          ? const SizedBox(
              key: ValueKey('loading'),
              height: 18,
              width: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          : Row(
              key: const ValueKey('label'),
              mainAxisSize: MainAxisSize.min,
              children: [
                if (leadingIcon != null) ...[
                  Icon(leadingIcon, size: 18, color: Colors.white),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Text(label, style: const TextStyle(color: Colors.white)),
              ],
            ),
    );

    return Opacity(
      opacity: _isEnabled || isLoading ? 1 : 0.5,
      child: SizedBox(
        width: expand ? double.infinity : null,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: _isEnabled ? AppColors.brandGradient : null,
            color: _isEnabled ? null : Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
            borderRadius: AppRadius.inputRadius,
          ),
          child: ElevatedButton(
            onPressed: _isEnabled ? onPressed : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md + 2),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
