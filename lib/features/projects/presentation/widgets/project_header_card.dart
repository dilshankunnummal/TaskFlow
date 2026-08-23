import 'package:flutter/material.dart';
import 'package:taskflow/core/theme/app_spacing.dart';
import 'package:taskflow/core/utils/date_formatter.dart';
import 'package:taskflow/core/widgets/cards/app_card.dart';
import 'package:taskflow/core/widgets/chips/app_status_chip.dart';
import 'package:taskflow/features/projects/domain/entities/project.dart';

final class ProjectHeaderCard extends StatelessWidget {
  const ProjectHeaderCard({required this.project, super.key});

  final Project project;

  String _statusLabel(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.active:
        return 'Active';
      case ProjectStatus.planning:
        return 'Planning';
      case ProjectStatus.onHold:
        return 'On hold';
      case ProjectStatus.archived:
        return 'Archived';
    }
  }

  String _statusKey(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.active:
        return 'active';
      case ProjectStatus.planning:
        return 'info';
      case ProjectStatus.onHold:
        return 'warning';
      case ProjectStatus.archived:
        return 'danger';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  project.name,
                  style: textTheme.headlineSmall,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              AppStatusChip(
                label: _statusLabel(project.status),
                status: _statusKey(project.status),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            project.description,
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.schedule_rounded, size: 16, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Created ${DateFormatter.shortDate(project.createdAt)}',
                style: textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
