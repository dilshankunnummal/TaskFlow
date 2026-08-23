import 'package:flutter/material.dart';
import 'package:taskflow/core/theme/app_radius.dart';
import 'package:taskflow/core/theme/app_spacing.dart';
import 'package:taskflow/core/widgets/buttons/app_icon_button.dart';
import 'package:taskflow/core/widgets/glass/glass_container.dart';

final class GlassPageHeader extends StatelessWidget {
  const GlassPageHeader({
    required this.title,
    super.key,
    this.onBack,
  });

  final String title;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
      child: GlassContainer(
        borderRadius: AppRadius.cardRadius,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
        child: Row(
          children: [
            AppIconButton(
              icon: Icons.arrow_back_rounded,
              tooltip: 'Back',
              onPressed: onBack,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(title, style: Theme.of(context).textTheme.titleMedium),
            ),
          ],
        ),
      ),
    );
  }
}