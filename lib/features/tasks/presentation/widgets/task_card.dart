import 'package:flutter/material.dart';
import 'package:taskflow/core/theme/app_colors.dart';
import 'package:taskflow/core/theme/app_radius.dart';
import 'package:taskflow/core/theme/app_spacing.dart';
import 'package:taskflow/core/utils/date_formatter.dart';
import 'package:taskflow/core/widgets/cards/app_card.dart';
import 'package:taskflow/core/widgets/chips/app_status_chip.dart';
import 'package:taskflow/features/tasks/domain/entities/task.dart';

final class TaskCard extends StatelessWidget {
  const TaskCard({required this.task, required this.onTap, super.key});

  final Task task;
  final VoidCallback onTap;

  String _statusLabel(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return 'Todo';
      case TaskStatus.inProgress:
        return 'In progress';
      case TaskStatus.review:
        return 'Review';
      case TaskStatus.done:
        return 'Done';
    }
  }

  String _statusKey(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return 'todo';
      case TaskStatus.inProgress:
        return 'in_progress';
      case TaskStatus.review:
        return 'info';
      case TaskStatus.done:
        return 'done';
    }
  }

  String _priorityLabel(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
      case TaskPriority.urgent:
        return 'Urgent';
    }
  }

  Color _priorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return AppColors.success;
      case TaskPriority.medium:
        return AppColors.info;
      case TaskPriority.high:
        return AppColors.warning;
      case TaskPriority.urgent:
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
      onTap: onTap,
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