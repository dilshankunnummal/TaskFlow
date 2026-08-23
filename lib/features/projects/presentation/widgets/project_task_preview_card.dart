import 'package:flutter/material.dart';
import 'package:taskflow/core/theme/app_colors.dart';
import 'package:taskflow/core/theme/app_radius.dart';
import 'package:taskflow/core/theme/app_spacing.dart';
import 'package:taskflow/core/utils/date_formatter.dart';
import 'package:taskflow/core/widgets/cards/app_card.dart';
import 'package:taskflow/core/widgets/chips/app_status_chip.dart';
import 'package:taskflow/features/projects/domain/entities/project_task.dart';

final class ProjectTaskPreviewCard extends StatelessWidget {
  const ProjectTaskPreviewCard({required this.task, super.key});

  final ProjectTask task;

  String _statusLabel(ProjectTaskStatus status) {
    switch (status) {
      case ProjectTaskStatus.todo:
        return 'Todo';
      case ProjectTaskStatus.inProgress:
        return 'In progress';
      case ProjectTaskStatus.review:
        return 'Review';
      case ProjectTaskStatus.done:
        return 'Done';
    }
  }

  String _statusKey(ProjectTaskStatus status) {
    switch (status) {
      case ProjectTaskStatus.todo:
        return 'todo';
      case ProjectTaskStatus.inProgress:
        return 'in_progress';
      case ProjectTaskStatus.review:
        return 'info';
      case ProjectTaskStatus.done:
        return 'done';
    }
  }

  String _priorityLabel(ProjectTaskPriority priority) {
    switch (priority) {
      case ProjectTaskPriority.low:
        return 'Low';
      case ProjectTaskPriority.medium:
        return 'Medium';
      case ProjectTaskPriority.high:
        return 'High';
      case ProjectTaskPriority.urgent:
        return 'Urgent';
    }
  }

  Color _priorityColor(ProjectTaskPriority priority) {
    switch (priority) {
      case ProjectTaskPriority.low:
        return AppColors.success;
      case ProjectTaskPriority.medium:
        return AppColors.info;
      case ProjectTaskPriority.high:
        return AppColors.warning;
      case ProjectTaskPriority.urgent:
        return AppColors.danger;
    }
  }

  String _formatAssignee(String? assigneeId) {
    if (assigneeId == null) {
      return 'Unassigned';
    }
    final normalized = assigneeId.replaceAll('_', ' ').trim();
    if (normalized.isEmpty) {
      return 'Unassigned';
    }
    return normalized[0].toUpperCase() + normalized.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final priorityColor = _priorityColor(task.priority);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  task.title,
                  style: textTheme.titleSmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              AppStatusChip(
                label: _statusLabel(task.status),
                status: _statusKey(task.status),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
                decoration: BoxDecoration(
                  color: priorityColor.withOpacity(0.14),
                  borderRadius: AppRadius.pillRadius,
                ),
                child: Text(
                  _priorityLabel(task.priority),
                  style: textTheme.labelSmall?.copyWith(color: priorityColor),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person_outline_rounded, size: 16, color: colorScheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    _formatAssignee(task.assigneeId),
                    style: textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
              if (task.dueDate != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.event_outlined, size: 16, color: colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      DateFormatter.shortDate(task.dueDate!),
                      style: textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}