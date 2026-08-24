import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:taskflow/core/theme/app_colors.dart';
import 'package:taskflow/core/theme/app_radius.dart';
import 'package:taskflow/core/theme/app_spacing.dart';
import 'package:taskflow/core/widgets/cards/app_card.dart';
import 'package:taskflow/core/widgets/skeleton_loader.dart';
import 'package:taskflow/features/projects/domain/entities/project.dart';

class ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback onTap;
  final VoidCallback? onDeleteRequested;
  final bool isDeleting;

  const ProjectCard({
    super.key,
    required this.project,
    required this.onTap,
    this.onDeleteRequested,
    this.isDeleting = false,
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
    // While deleting, swap the entire card for an animated skeleton so the
    // user sees a shimmer placeholder instead of a spinner over blurred content.
    if (isDeleting) {
      return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: AppRadius.cardRadius,
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.08),
          ),
        ),
        child: const ProjectCardSkeleton(),
      );
    }

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
              if (onDeleteRequested != null) ...[
                const SizedBox(width: AppSpacing.xs),
                _ProjectCardMenu(
                  enabled: true,
                  onDelete: onDeleteRequested!,
                ),
              ],
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

class _ProjectCardMenu extends StatelessWidget {
  const _ProjectCardMenu({
    required this.enabled,
    required this.onDelete,
  });

  final bool enabled;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 28,
      height: 28,
      child: PopupMenuButton<String>(
        enabled: enabled,
        padding: EdgeInsets.zero,
        tooltip: 'Project options',
        icon: Icon(
          Icons.more_vert_rounded,
          size: 18,
          color: colorScheme.onSurfaceVariant,
        ),
        onSelected: (value) {
          if (value == 'delete') {
            onDelete();
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'delete',
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.delete_outline_rounded, size: 18, color: colorScheme.error),
                const SizedBox(width: AppSpacing.sm),
                Text('Delete', style: TextStyle(color: colorScheme.error)),
              ],
            ),
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