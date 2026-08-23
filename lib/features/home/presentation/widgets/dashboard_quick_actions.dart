import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:taskflow/core/router/app_routes.dart';
import 'package:taskflow/core/theme/app_spacing.dart';
import 'package:taskflow/core/widgets/cards/app_card.dart';

final class DashboardQuickActions extends StatelessWidget {
  const DashboardQuickActions({super.key});

  static const List<_QuickAction> _actions = [
    _QuickAction(label: 'Projects', icon: Icons.folder_outlined, route: AppRoutes.projects),
    _QuickAction(label: 'Profile', icon: Icons.person_outline_rounded, route: AppRoutes.profile),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        for (var index = 0; index < _actions.length; index++) ...[
          if (index > 0) const SizedBox(width: AppSpacing.md),
          Expanded(
            child: AppCard(
              onTap: () => context.go(_actions[index].route),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_actions[index].icon, color: theme.colorScheme.primary),
                  const SizedBox(height: AppSpacing.md),
                  Text(_actions[index].label, style: theme.textTheme.titleSmall),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

final class _QuickAction {
  const _QuickAction({required this.label, required this.icon, required this.route});

  final String label;
  final IconData icon;
  final String route;
}
