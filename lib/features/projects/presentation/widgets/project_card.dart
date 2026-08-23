import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:taskflow/core/theme/app_colors.dart';
import 'package:taskflow/core/theme/app_radius.dart';
import 'package:taskflow/core/theme/app_spacing.dart';
import 'package:taskflow/core/widgets/cards/app_card.dart';
import 'package:taskflow/features/projects/domain/entities/project.dart';

class ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback onTap;

  const ProjectCard({
    super.key,
    required this.project,
    required this.onTap,
  });

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

    final statusColor = AppColors.statusColor(
      _statusKey(project.status),
    );

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  project.name,
                  style: textTheme.titleSmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              _StatusBadge(
                label: _statusLabel(project.status),
                color: statusColor,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xs),

          Text(
            project.description,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: AppSpacing.sm),

          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _InfoItem(
                icon: Icons.checklist_rounded,
                text: '${project.taskCount} tasks',
              ),
              _InfoItem(
                icon: Icons.schedule_rounded,
                text: DateFormat.yMMMd().format(project.createdAt),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: AppRadius.pillRadius,
      ),
      child: Text(
        label,
        style: textTheme.labelSmall?.copyWith(color: color),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}