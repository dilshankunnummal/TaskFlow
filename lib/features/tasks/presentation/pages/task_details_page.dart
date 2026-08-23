import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taskflow/core/di/injection.dart';
import 'package:taskflow/core/router/app_routes.dart';
import 'package:taskflow/core/theme/app_breakpoints.dart';
import 'package:taskflow/core/theme/app_colors.dart';
import 'package:taskflow/core/theme/app_radius.dart';
import 'package:taskflow/core/theme/app_spacing.dart';
import 'package:taskflow/core/utils/date_formatter.dart';
import 'package:taskflow/core/widgets/avatars/app_avatar.dart';
import 'package:taskflow/core/widgets/cards/app_card.dart';
import 'package:taskflow/core/widgets/chips/app_status_chip.dart';
import 'package:taskflow/core/widgets/dialogs/app_bottom_sheet.dart';
import 'package:taskflow/core/widgets/dialogs/app_confirm_dialog.dart';
import 'package:taskflow/core/widgets/dialogs/app_dialog.dart';
import 'package:taskflow/core/widgets/empty_state_widget.dart';
import 'package:taskflow/core/widgets/error_state_widget.dart';
import 'package:taskflow/core/widgets/inputs/app_text_field.dart';
import 'package:taskflow/core/widgets/skeleton_loader.dart';
import 'package:taskflow/features/tasks/domain/entities/organization_member.dart';
import 'package:taskflow/features/tasks/domain/entities/task.dart';
import 'package:taskflow/features/tasks/domain/entities/task_assignee.dart';
import 'package:taskflow/features/tasks/domain/entities/task_comment.dart';
import 'package:taskflow/features/tasks/presentation/bloc/task_assignment_bloc.dart';
import 'package:taskflow/features/tasks/presentation/bloc/task_assignment_event.dart';
import 'package:taskflow/features/tasks/presentation/bloc/task_assignment_state.dart';
import 'package:taskflow/features/tasks/presentation/bloc/task_delete_bloc.dart';
import 'package:taskflow/features/tasks/presentation/bloc/task_delete_event.dart';
import 'package:taskflow/features/tasks/presentation/bloc/task_delete_state.dart';
import 'package:taskflow/features/tasks/presentation/bloc/task_details_bloc.dart';
import 'package:taskflow/features/tasks/presentation/bloc/task_details_event.dart';
import 'package:taskflow/features/tasks/presentation/bloc/task_details_state.dart';

class TaskDetailsPage extends StatelessWidget {
  const TaskDetailsPage({required this.taskId, super.key});

  final String taskId;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<TaskDetailsBloc>()..add(LoadTaskDetails(taskId)),
        ),
        BlocProvider(
          create: (_) => getIt<TaskDeleteBloc>(),
        ),
        BlocProvider(
          create: (_) => getIt<TaskAssignmentBloc>(),
        ),
      ],
      child: TaskDetailsView(taskId: taskId),
    );
  }
}

class TaskDetailsView extends StatelessWidget {
  const TaskDetailsView({required this.taskId, super.key});

  final String taskId;

  void _handleDeleteListener(BuildContext context, TaskDeleteState state) {
    if (state is TaskDeleteSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task deleted successfully')),
      );
      context.pop(true);
    } else if (state is TaskDeleteError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  }

  void _handleAssignmentListener(
      BuildContext context, TaskAssignmentState state) {
    if (state is TaskAssignmentSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task assignee updated')),
      );
      context.read<TaskDetailsBloc>().add(RefreshTaskDetails(taskId));
    } else if (state is TaskAssignmentError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<TaskDeleteBloc, TaskDeleteState>(
          listener: _handleDeleteListener,
        ),
        BlocListener<TaskAssignmentBloc, TaskAssignmentState>(
          listener: _handleAssignmentListener,
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Task Details'),
          actions: [
            BlocBuilder<TaskDetailsBloc, TaskDetailsState>(
              buildWhen: (prev, curr) =>
                  (prev is TaskDetailsSuccess) != (curr is TaskDetailsSuccess),
              builder: (context, state) {
                if (state is! TaskDetailsSuccess) return const SizedBox.shrink();
                return Row(
                  children: [
                    IconButton(
                      key: const Key('editTaskButton'),
                      icon: const Icon(Icons.edit_outlined),
                      tooltip: 'Edit Task',
                      onPressed: () async {
                        final updated = await context.push<bool>(
                          AppRoutes.editTaskPath(taskId),
                        );
                        if (updated == true && context.mounted) {
                          context
                              .read<TaskDetailsBloc>()
                              .add(RefreshTaskDetails(taskId));
                        }
                      },
                    ),
                    IconButton(
                      key: const Key('deleteTaskButton'),
                      icon: const Icon(Icons.delete_outline_rounded),
                      tooltip: 'Delete Task',
                      onPressed: () async {
                        final confirmed = await AppConfirmDialog.show(
                          context,
                          title: 'Delete Task',
                          message:
                              'Delete "${state.task.title}"?\nThis action cannot be undone.',
                          confirmLabel: 'Delete',
                          cancelLabel: 'Cancel',
                          isDestructive: true,
                        );
                        if (confirmed == true && context.mounted) {
                          context
                              .read<TaskDeleteBloc>()
                              .add(DeleteTaskRequested(taskId));
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded),
                      tooltip: 'Refresh',
                      onPressed: () => context
                          .read<TaskDetailsBloc>()
                          .add(RefreshTaskDetails(taskId)),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return BlocBuilder<TaskDetailsBloc, TaskDetailsState>(
              builder: (context, state) =>
                  _buildBody(context, state, constraints.maxWidth),
            );
          },
        ),
      ),
    ));
  }

  Widget _buildBody(
    BuildContext context,
    TaskDetailsState state,
    double width,
  ) {
    final isWide =
        AppBreakpoints.isTablet(width) || AppBreakpoints.isDesktop(width);

    if (state is TaskDetailsInitial || state is TaskDetailsLoading) {
      return _TaskDetailsSkeleton(isWide: isWide);
    }

    if (state is TaskDetailsEmpty) {
      return const EmptyStateWidget(
        icon: Icons.task_alt_rounded,
        title: 'Task not found',
        message: 'This task does not exist or may have been removed.',
      );
    }

    if (state is TaskDetailsError) {
      return ErrorStateWidget(
        message: state.message,
        onRetry: () =>
            context.read<TaskDetailsBloc>().add(LoadTaskDetails(taskId)),
      );
    }

    if (state is TaskDetailsSuccess) {
      return _SuccessBody(taskId: taskId, state: state, isWide: isWide);
    }

    return _TaskDetailsSkeleton(isWide: isWide);
  }
}

class _SuccessBody extends StatelessWidget {
  const _SuccessBody({
    required this.taskId,
    required this.state,
    required this.isWide,
  });

  final String taskId;
  final TaskDetailsSuccess state;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state.isStale) ...[
            const _StaleBanner(),
            const SizedBox(height: AppSpacing.md),
          ],
          if (isWide)
            _TabletLayout(state: state)
          else
            _MobileLayout(state: state),
        ],
      ),
    );
  }
}

class _MobileLayout extends StatelessWidget {
  const _MobileLayout({required this.state});

  final TaskDetailsSuccess state;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TaskHeaderCard(task: state.task),
        const SizedBox(height: AppSpacing.lg),
        _TaskDetailsCard(task: state.task),
        const SizedBox(height: AppSpacing.lg),
        _AssigneeCard(task: state.task, assignee: state.assignee),
        const SizedBox(height: AppSpacing.lg),
        _CommentsCard(comments: state.comments),
      ],
    );
  }
}

class _TabletLayout extends StatelessWidget {
  const _TabletLayout({required this.state});

  final TaskDetailsSuccess state;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            children: [
              _TaskHeaderCard(task: state.task),
              const SizedBox(height: AppSpacing.lg),
              _TaskDetailsCard(task: state.task),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _AssigneeCard(task: state.task, assignee: state.assignee),
              const SizedBox(height: AppSpacing.lg),
              _CommentsCard(comments: state.comments),
            ],
          ),
        ),
      ],
    );
  }
}

class _TaskHeaderCard extends StatelessWidget {
  const _TaskHeaderCard({required this.task});

  final Task task;

  String _statusLabel(TaskStatus status) => switch (status) {
        TaskStatus.todo => 'Todo',
        TaskStatus.inProgress => 'In Progress',
        TaskStatus.review => 'Review',
        TaskStatus.done => 'Done',
      };

  String _statusKey(TaskStatus status) => switch (status) {
        TaskStatus.todo => 'todo',
        TaskStatus.inProgress => 'in_progress',
        TaskStatus.review => 'info',
        TaskStatus.done => 'done',
      };

  String _priorityLabel(TaskPriority priority) => switch (priority) {
        TaskPriority.low => 'Low',
        TaskPriority.medium => 'Medium',
        TaskPriority.high => 'High',
        TaskPriority.urgent => 'Urgent',
      };

  Color _priorityColor(TaskPriority priority) => switch (priority) {
        TaskPriority.low => AppColors.success,
        TaskPriority.medium => AppColors.info,
        TaskPriority.high => AppColors.warning,
        TaskPriority.urgent => AppColors.danger,
      };

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final priorityColor = _priorityColor(task.priority);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(task.title, style: textTheme.titleLarge),
              ),
              const SizedBox(width: AppSpacing.md),
              AppStatusChip(
                label: _statusLabel(task.status),
                status: _statusKey(task.status),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: priorityColor.withOpacity(0.14),
              borderRadius: AppRadius.pillRadius,
            ),
            child: Text(
              _priorityLabel(task.priority),
              style: TextStyle(
                color: priorityColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskDetailsCard extends StatelessWidget {
  const _TaskDetailsCard({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Details', style: textTheme.titleSmall),
          const SizedBox(height: AppSpacing.md),
          if (task.description.isNotEmpty) ...[
            Text(
              'Description',
              style: textTheme.labelSmall
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(task.description, style: textTheme.bodyMedium),
            const SizedBox(height: AppSpacing.lg),
          ],
          _DetailRow(
            icon: Icons.event_outlined,
            label: 'Due Date',
            value: task.dueDate != null
                ? DateFormatter.shortDate(task.dueDate!)
                : 'No due date',
            valueColor:
                task.dueDate != null && DateFormatter.isOverdue(task.dueDate!)
                    ? AppColors.danger
                    : null,
          ),
          const SizedBox(height: AppSpacing.md),
          _DetailRow(
            icon: Icons.calendar_today_outlined,
            label: 'Created',
            value: DateFormatter.shortDate(task.createdAt),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '$label:',
          style: textTheme.labelMedium
              ?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          value,
          style: textTheme.labelMedium?.copyWith(
            color: valueColor ?? colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _AssigneeCard extends StatelessWidget {
  const _AssigneeCard({
    required this.task,
    required this.assignee,
  });

  final Task task;
  final TaskAssignee? assignee;

  void _showAssignUserModal(BuildContext context) {
    final assignmentBloc = context.read<TaskAssignmentBloc>();
    assignmentBloc.add(
      LoadOrganizationMembers(
        projectId: task.projectId,
        currentAssigneeId: assignee?.id,
      ),
    );

    final width = MediaQuery.of(context).size.width;
    final isTablet =
        AppBreakpoints.isTablet(width) || AppBreakpoints.isDesktop(width);

    final content = _AssignUserModalContent(
      task: task,
      currentAssigneeId: assignee?.id,
      assignmentBloc: assignmentBloc,
    );

    if (isTablet) {
      AppDialog.show(
        context,
        title: 'Assign User',
        content: SizedBox(
          width: 480,
          height: 480,
          child: content,
        ),
      );
    } else {
      AppBottomSheet.show(
        context,
        child: SizedBox(
          height: 480,
          child: content,
        ),
      );
    }
  }

  Future<void> _handleRemoveAssignee(BuildContext context) async {
    final confirmed = await AppConfirmDialog.show(
      context,
      title: 'Remove Assignee',
      message:
          'Are you sure you want to remove the assignee from "${task.title}"?',
      confirmLabel: 'Remove',
      cancelLabel: 'Cancel',
      isDestructive: true,
    );
    if (confirmed == true && context.mounted) {
      context.read<TaskAssignmentBloc>().add(RemoveUserFromTask(task.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Assignee', style: textTheme.titleSmall),
              if (assignee == null)
                TextButton.icon(
                  key: const Key('assignUserButton'),
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed: () => _showAssignUserModal(context),
                  icon: const Icon(Icons.person_add_outlined, size: 16),
                  label: const Text('Assign User'),
                )
              else
                Row(
                  children: [
                    TextButton.icon(
                      key: const Key('changeAssigneeButton'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                      onPressed: () => _showAssignUserModal(context),
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: const Text('Change'),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    TextButton.icon(
                      key: const Key('removeAssigneeButton'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                      onPressed: () => _handleRemoveAssignee(context),
                      icon: const Icon(Icons.person_remove_outlined, size: 16),
                      label: Text(
                        'Remove',
                        style: TextStyle(color: colorScheme.error),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (assignee == null)
            _UnassignedRow(
              textTheme: textTheme,
              colorScheme: colorScheme,
            )
          else
            _AssigneeRow(
              assignee: assignee!,
              textTheme: textTheme,
              colorScheme: colorScheme,
            ),
        ],
      ),
    );
  }
}

class _UnassignedRow extends StatelessWidget {
  const _UnassignedRow({
    required this.textTheme,
    required this.colorScheme,
  });

  final TextTheme textTheme;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            shape: BoxShape.circle,
            border: Border.all(
              color: colorScheme.outline.withOpacity(0.4),
              width: 1.5,
            ),
          ),
          child: Icon(
            Icons.person_outline_rounded,
            color: colorScheme.onSurfaceVariant,
            size: 20,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Text(
          'No assignee',
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}

class _AssignUserModalContent extends StatefulWidget {
  const _AssignUserModalContent({
    required this.task,
    required this.currentAssigneeId,
    required this.assignmentBloc,
  });

  final Task task;
  final String? currentAssigneeId;
  final TaskAssignmentBloc assignmentBloc;

  @override
  State<_AssignUserModalContent> createState() =>
      _AssignUserModalContentState();
}

class _AssignUserModalContentState extends State<_AssignUserModalContent> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return BlocProvider.value(
      value: widget.assignmentBloc,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Assign User', style: textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            key: const Key('assignUserSearchField'),
            controller: _searchController,
            hintText: 'Search members...',
            prefixIcon: Icons.search_rounded,
            onChanged: (query) => setState(() => _searchQuery = query),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: BlocBuilder<TaskAssignmentBloc, TaskAssignmentState>(
              builder: (context, state) {
                if (state is TaskAssignmentLoading ||
                    state is TaskAssignmentInitial) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is TaskAssignmentError) {
                  return ErrorStateWidget(
                    message: state.message,
                    onRetry: () => widget.assignmentBloc.add(
                      LoadOrganizationMembers(
                        projectId: widget.task.projectId,
                        currentAssigneeId: widget.currentAssigneeId,
                      ),
                    ),
                  );
                }

                if (state is TaskAssignmentLoaded) {
                  final filteredMembers = state.members.where((m) {
                    final q = _searchQuery.trim().toLowerCase();
                    if (q.isEmpty) return true;
                    return m.name.toLowerCase().contains(q) ||
                        m.email.toLowerCase().contains(q);
                  }).toList();

                  if (filteredMembers.isEmpty) {
                    return const EmptyStateWidget(
                      icon: Icons.people_outline_rounded,
                      title: 'No members found',
                      message: 'No organization members match your search.',
                    );
                  }

                  return ListView.separated(
                    itemCount: filteredMembers.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final member = filteredMembers[index];
                      final isCurrent =
                          member.id == widget.currentAssigneeId;
                      final roleLabel = member.role == 'org_admin'
                          ? 'Org Admin'
                          : 'Member';

                      return ListTile(
                        key: Key('memberTile_${member.id}'),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        tileColor: isCurrent
                            ? colorScheme.primaryContainer.withOpacity(0.2)
                            : colorScheme.surfaceContainerHighest
                                .withOpacity(0.3),
                        leading: AppAvatar(name: member.name, size: 40),
                        title: Text(
                          member.name,
                          style: textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          member.email,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: AppSpacing.xs,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                roleLabel,
                                style: textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                            if (isCurrent) ...[
                              const SizedBox(width: AppSpacing.sm),
                              Icon(
                                Icons.check_circle_rounded,
                                color: colorScheme.primary,
                                size: 20,
                              ),
                            ],
                          ],
                        ),
                        onTap: () {
                          widget.assignmentBloc.add(
                            AssignUserToTask(
                              taskId: widget.task.id,
                              userId: member.id,
                            ),
                          );
                          Navigator.of(context).pop();
                        },
                      );
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AssigneeRow extends StatelessWidget {
  const _AssigneeRow({
    required this.assignee,
    required this.textTheme,
    required this.colorScheme,
  });

  final TaskAssignee assignee;
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppAvatar(name: assignee.name, size: 40),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                assignee.name,
                style:
                    textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(
                assignee.email,
                style: textTheme.labelSmall
                    ?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CommentsCard extends StatelessWidget {
  const _CommentsCard({required this.comments});

  final List<TaskComment> comments;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Comments', style: textTheme.titleSmall),
              if (comments.isNotEmpty) ...[
                const SizedBox(width: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm, vertical: 2),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: AppRadius.pillRadius,
                  ),
                  child: Text(
                    '${comments.length}',
                    style: textTheme.labelSmall
                        ?.copyWith(color: colorScheme.onPrimaryContainer),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (comments.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                child: Column(
                  children: [
                    Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 32,
                      color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'No comments yet',
                      style: textTheme.bodySmall
                          ?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            )
          else
            ...comments.asMap().entries.map((entry) {
              final isLast = entry.key == comments.length - 1;
              return Column(
                children: [
                  _CommentItem(comment: entry.value),
                  if (!isLast) ...[
                    const SizedBox(height: AppSpacing.md),
                    Divider(
                      color: colorScheme.outlineVariant.withOpacity(0.5),
                      height: 1,
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                ],
              );
            }),
        ],
      ),
    );
  }
}

class _CommentItem extends StatelessWidget {
  const _CommentItem({required this.comment});

  final TaskComment comment;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppAvatar(name: comment.authorName, size: 32),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      comment.authorName,
                      style: textTheme.labelMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text(
                    DateFormatter.relative(comment.createdAt),
                    style: textTheme.labelSmall
                        ?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(comment.body, style: textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}

class _TaskDetailsSkeleton extends StatelessWidget {
  const _TaskDetailsSkeleton({required this.isWide});

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Widget card(Widget child) => Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: AppRadius.cardRadius,
            border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.08),
            ),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: child,
        );

    final headerSkeleton = card(
      const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: SkeletonBox(height: 22, width: 200)),
              SizedBox(width: AppSpacing.sm),
              SkeletonBox(
                height: 24,
                width: 72,
                radius: BorderRadius.all(Radius.circular(999)),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          SkeletonBox(
            height: 20,
            width: 62,
            radius: BorderRadius.all(Radius.circular(999)),
          ),
        ],
      ),
    );

    final detailsSkeleton = card(
      const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(height: 14, width: 56),
          SizedBox(height: AppSpacing.md),
          SkeletonBox(height: 12, width: 80),
          SizedBox(height: AppSpacing.xs),
          SkeletonBox(height: 14, width: double.infinity),
          SizedBox(height: AppSpacing.xs),
          SkeletonBox(height: 14, width: 240),
          SizedBox(height: AppSpacing.lg),
          Row(children: [
            SkeletonBox(height: 14, width: 64),
            SizedBox(width: AppSpacing.sm),
            SkeletonBox(height: 14, width: 96),
          ]),
          SizedBox(height: AppSpacing.md),
          Row(children: [
            SkeletonBox(height: 14, width: 64),
            SizedBox(width: AppSpacing.sm),
            SkeletonBox(height: 14, width: 96),
          ]),
        ],
      ),
    );

    final assigneeSkeleton = card(
      const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(height: 14, width: 72),
          SizedBox(height: AppSpacing.md),
          Row(
            children: [
              SkeletonBox(
                height: 40,
                width: 40,
                radius: BorderRadius.all(Radius.circular(999)),
              ),
              SizedBox(width: AppSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(height: 14, width: 120),
                  SizedBox(height: AppSpacing.xs),
                  SkeletonBox(height: 12, width: 160),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    final commentsSkeleton = card(
      const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(height: 14, width: 80),
          SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(
                height: 32,
                width: 32,
                radius: BorderRadius.all(Radius.circular(999)),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(height: 12, width: 100),
                    SizedBox(height: AppSpacing.xs),
                    SkeletonBox(height: 14, width: double.infinity),
                    SizedBox(height: AppSpacing.xs),
                    SkeletonBox(height: 14, width: 180),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: isWide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(children: [
                    headerSkeleton,
                    const SizedBox(height: AppSpacing.lg),
                    detailsSkeleton,
                  ]),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  flex: 2,
                  child: Column(children: [
                    assigneeSkeleton,
                    const SizedBox(height: AppSpacing.lg),
                    commentsSkeleton,
                  ]),
                ),
              ],
            )
          : Column(
              children: [
                headerSkeleton,
                const SizedBox(height: AppSpacing.lg),
                detailsSkeleton,
                const SizedBox(height: AppSpacing.lg),
                assigneeSkeleton,
                const SizedBox(height: AppSpacing.lg),
                commentsSkeleton,
              ],
            ),
    );
  }
}

class _StaleBanner extends StatelessWidget {
  const _StaleBanner();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: AppRadius.cardRadius,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_off_rounded,
              size: 16, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'You are offline. Showing cached task details.',
              style: textTheme.labelSmall
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}
