import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taskflow/core/constants/app_strings.dart';
import 'package:taskflow/core/di/injection.dart';
import 'package:taskflow/core/router/app_routes.dart';
import 'package:taskflow/core/theme/app_breakpoints.dart';
import 'package:taskflow/core/theme/app_radius.dart';
import 'package:taskflow/core/theme/app_spacing.dart';
import 'package:taskflow/core/widgets/empty_state_widget.dart';
import 'package:taskflow/core/widgets/error_state_widget.dart';
import 'package:taskflow/core/widgets/skeleton_loader.dart';
import 'package:taskflow/features/tasks/presentation/bloc/task_list_bloc.dart';
import 'package:taskflow/features/tasks/presentation/bloc/task_list_event.dart';
import 'package:taskflow/features/tasks/presentation/bloc/task_list_state.dart';
import 'package:taskflow/features/tasks/presentation/widgets/task_card.dart';

class TaskListPage extends StatelessWidget {
  const TaskListPage({required this.projectId, super.key});

  final String projectId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<TaskListBloc>()..add(LoadTasks(projectId)),
      child: TaskListView(projectId: projectId),
    );
  }
}

class TaskListView extends StatelessWidget {
  const TaskListView({required this.projectId, super.key});

  final String projectId;

  int _columnsForWidth(double width) {
    if (AppBreakpoints.isDesktop(width)) return 3;
    if (AppBreakpoints.isTablet(width)) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final columns = _columnsForWidth(constraints.maxWidth);
            return BlocBuilder<TaskListBloc, TaskListState>(
              builder: (context, state) => _buildBody(context, state, columns, textTheme),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, TaskListState state, int columns, TextTheme textTheme) {
    if (state is TaskListInitial || state is TaskListLoading) {
      return _TaskListSkeleton(columns: columns);
    }

    if (state is TaskListEmpty) {
      return const EmptyStateWidget(
        icon: Icons.task_alt_rounded,
        title: 'No tasks yet',
        message: 'Tasks assigned to this project will show up here.',
      );
    }

    if (state is TaskListError) {
      return ErrorStateWidget(
        message: state.message,
        onRetry: () => context.read<TaskListBloc>().add(LoadTasks(projectId)),
      );
    }

    if (state is TaskListSuccess) {
      return _buildSuccessBody(context, state, columns);
    }

    return _TaskListSkeleton(columns: columns);
  }

  Widget _buildSuccessBody(BuildContext context, TaskListSuccess success, int columns) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<TaskListBloc>().add(RefreshTasks(projectId));
        await context
            .read<TaskListBloc>()
            .stream
            .firstWhere((s) => s is TaskListSuccess || s is TaskListEmpty || s is TaskListError);
      },
      child: Column(
        children: [
          if (success.isStale) const _StaleBanner(),
          Expanded(
            child: LayoutBuilder(
              builder: (context, gridConstraints) {
                const spacing = AppSpacing.lg;
                final totalSpacing = spacing * (columns - 1);
                final itemWidth = (gridConstraints.maxWidth - totalSpacing) / columns;

                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: [
                      for (final task in success.tasks)
                        SizedBox(
                          width: itemWidth,
                          child: TaskCard(
                            task: task,
                            onTap: () => context.push(AppRoutes.taskDetailPath(task.id)),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
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
      color: colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      child: Row(
        children: [
          Icon(Icons.cloud_off_rounded, size: 16, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              AppStrings.offlineMessage,
              style: textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskCardSkeleton extends StatelessWidget {
  const _TaskCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.08)),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(height: 16, width: 160),
          SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              SkeletonBox(height: 20, width: 56, radius: BorderRadius.all(Radius.circular(999))),
              SizedBox(width: AppSpacing.sm),
              SkeletonBox(height: 16, width: 90),
            ],
          ),
        ],
      ),
    );
  }
}

class _TaskListSkeleton extends StatelessWidget {
  const _TaskListSkeleton({required this.columns, this.itemCount = 6});

  final int columns;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      physics: const AlwaysScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisExtent: 108,
        crossAxisSpacing: AppSpacing.lg,
        mainAxisSpacing: AppSpacing.lg,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) => const _TaskCardSkeleton(),
    );
  }
}