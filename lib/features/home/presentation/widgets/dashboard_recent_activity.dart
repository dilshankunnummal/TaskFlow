import 'package:flutter/material.dart';
import 'package:taskflow/core/theme/app_spacing.dart';
import 'package:taskflow/core/utils/date_formatter.dart';
import 'package:taskflow/core/widgets/cards/app_card.dart';
import 'package:taskflow/core/widgets/chips/app_status_chip.dart';
import 'package:taskflow/core/widgets/empty/app_empty_state.dart';
import 'package:taskflow/features/home/domain/entities/activity_item_entity.dart';

final class DashboardRecentActivity extends StatelessWidget {
  const DashboardRecentActivity({required this.items, super.key});

  final List<ActivityItemEntity> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent Activity', style: theme.textTheme.titleLarge),
        const SizedBox(height: AppSpacing.md),
        if (items.isEmpty)
          const AppEmptyState(
            title: 'No recent activity',
            message: 'Task updates from your team will show up here.',
            icon: Icons.history_rounded,
          )
        else
          for (var index = 0; index < items.length; index++) ...[
            if (index > 0) const SizedBox(height: AppSpacing.md),
            _ActivityRow(item: items[index]),
          ],
      ],
    );
  }
}

final class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.item});

  final ActivityItemEntity item;

  String get _statusLabel => switch (item.status) {
        'done' => 'Done',
        'in_progress' => 'In Progress',
        'review' => 'In Review',
        'todo' => 'To Do',
        _ => item.status,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: theme.textTheme.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${item.projectName} · ${DateFormatter.relative(item.timestamp)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          AppStatusChip(label: _statusLabel, status: item.status),
        ],
      ),
    );
  }
}
