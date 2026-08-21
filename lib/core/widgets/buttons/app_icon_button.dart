import 'package:flutter/material.dart';
import 'package:taskflow/core/theme/app_motion.dart';

final class AppIconButton extends StatelessWidget {
  const AppIconButton({
    required this.icon,
    super.key,
    this.onPressed,
    this.tooltip,
    this.isSelected = false,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final button = AnimatedContainer(
      duration: AppMotion.micro,
      curve: AppMotion.curve,
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isSelected ? colorScheme.primary.withOpacity(0.14) : colorScheme.onSurface.withOpacity(0.06),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        color: isSelected ? colorScheme.primary : colorScheme.onSurface,
        splashRadius: 20,
      ),
    );

    if (tooltip == null) {
      return button;
    }
    return Tooltip(message: tooltip!, child: button);
  }
}
