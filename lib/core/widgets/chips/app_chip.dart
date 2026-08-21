import 'package:flutter/material.dart';
import 'package:taskflow/core/theme/app_motion.dart';
import 'package:taskflow/core/theme/app_radius.dart';
import 'package:taskflow/core/theme/app_spacing.dart';

final class AppChip extends StatelessWidget {
  const AppChip({
    required this.label,
    super.key,
    this.icon,
    this.isSelected = false,
    this.onTap,
  });

  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final background = isSelected ? colorScheme.primary.withOpacity(0.16) : colorScheme.onSurface.withOpacity(0.06);
    final foreground = isSelected ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.8);

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.pillRadius,
      child: AnimatedContainer(
        duration: AppMotion.micro,
        curve: AppMotion.curve,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs + 2),
        decoration: BoxDecoration(color: background, borderRadius: AppRadius.pillRadius),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: foreground),
              const SizedBox(width: AppSpacing.xs),
            ],
            Text(label, style: TextStyle(color: foreground, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
