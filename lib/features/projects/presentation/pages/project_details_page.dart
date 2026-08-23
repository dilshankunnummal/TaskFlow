import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taskflow/core/constants/app_strings.dart';
import 'package:taskflow/core/di/injection.dart';
import 'package:taskflow/core/router/app_routes.dart';
import 'package:taskflow/core/theme/app_breakpoints.dart';
import 'package:taskflow/core/theme/app_spacing.dart';
import 'package:taskflow/core/widgets/empty_state_widget.dart';
import 'package:taskflow/core/widgets/error_state_widget.dart';
import 'package:taskflow/core/widgets/skeleton_loader.dart';
import 'package:taskflow/features/projects/domain/entities/project.dart';
import 'package:taskflow/features/projects/presentation/bloc/project_details_bloc.dart';
import 'package:taskflow/features/projects/presentation/bloc/project_details_event.dart';
import 'package:taskflow/features/projects/presentation/bloc/project_details_state.dart';
import 'package:taskflow/features/projects/presentation/widgets/project_header_card.dart';
import 'package:taskflow/features/projects/presentation/widgets/project_status_summary.dart';
import 'package:taskflow/features/projects/presentation/widgets/project_task_preview_card.dart';

final class ProjectDetailsPage extends StatelessWidget {
  const ProjectDetailsPage({required this.projectId, super.key});

  final String projectId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProjectDetailsBloc>(
      create: (_) => getIt<ProjectDetailsBloc>()..add(LoadProjectDetails(projectId)),
      child: ProjectDetailsView(projectId: projectId),
    );
  }
}

final class ProjectDetailsView extends StatelessWidget {
  const ProjectDetailsView({required this.projectId, super.key});

  final String projectId;

  Future<void> _handleRefresh(BuildContext context) {
    final bloc = context.read<ProjectDetailsBloc>();
    final completion = bloc.stream.firstWhere((state) => state is! ProjectDetailsLoading);
    bloc.add(RefreshProjectDetails(projectId));
    return completion;
  }

  Future<void> _handleEdit(BuildContext context, Project project) async {
    final detailsBloc = context.read<ProjectDetailsBloc>();
    final updated = await context.push<bool>(
      AppRoutes.editProjectPath(project.id),
      extra: project,
    );
    if (updated == true) {
      detailsBloc.add(RefreshProjectDetails(project.id));
    }
  }

  void _handleViewTasks(BuildContext context) {
    // context.push(AppRoutes.projectTasksPath(projectId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Project'),
        actions: [
          BlocBuilder<ProjectDetailsBloc, ProjectDetailsState>(
            builder: (context, state) {
              final project = switch (state) {
                ProjectDetailsSuccess(:final project) => project,
                ProjectDetailsEmpty(:final project) => project,
                _ => null,
              };
              if (project == null) {
                return const SizedBox.shrink();
              }
              return IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit project',
                onPressed: () => _handleEdit(context, project),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<ProjectDetailsBloc, ProjectDetailsState>(
          builder: (context, state) => _buildBody(context, state),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ProjectDetailsState state) {
    if (state is ProjectDetailsInitial || state is ProjectDetailsLoading) {
      return const _ProjectDetailsSkeleton();
    }

    if (state is ProjectDetailsError) {
      return ErrorStateWidget(
        message: state.message,
        onRetry: () => context.read<ProjectDetailsBloc>().add(LoadProjectDetails(projectId)),
      );
    }

    if (state is ProjectDetailsEmpty) {
      return RefreshIndicator(
        onRefresh: () => _handleRefresh(context),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.xxxl,
          ),
          children: [
            if (state.isStale) const _StaleBanner(),
            ProjectHeaderCard(project: state.project),
            const SizedBox(height: AppSpacing.xxl),
            Row(
              children: [
                Expanded(
                  child: Text('Tasks', style: Theme.of(context).textTheme.titleLarge),
                ),
                TextButton(
                  onPressed: () => _handleViewTasks(context),
                  child: const Text('View Tasks'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            InkWell(
              onTap: () => _handleViewTasks(context),
              borderRadius: BorderRadius.circular(AppSpacing.sm),
              child: const SizedBox(
                height: 320,
                child: EmptyStateWidget(
                  icon: Icons.checklist_rtl_rounded,
                  title: 'No tasks yet',
                  message: 'Tasks added to this project will show up here.',
                ),
              ),
            ),
          ],
        ),
      );
    }

    final success = state as ProjectDetailsSuccess;

    return RefreshIndicator(
      onRefresh: () => _handleRefresh(context),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isPhone = AppBreakpoints.isPhone(constraints.maxWidth);
          final columns = isPhone ? 1 : 2;
          const spacing = AppSpacing.lg;
          final itemWidth =
          columns == 1 ? constraints.maxWidth : (constraints.maxWidth - spacing) / columns;

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.xxxl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (success.isStale) const _StaleBanner(),
                ProjectHeaderCard(project: success.project),
                const SizedBox(height: AppSpacing.xxl),
                ProjectStatusSummary(taskSummary: success.taskSummary),
                const SizedBox(height: AppSpacing.xxl),
                Row(
                  children: [
                    Expanded(
                      child: Text('Tasks', style: Theme.of(context).textTheme.titleLarge),
                    ),
                    TextButton(
                      onPressed: () => _handleViewTasks(context),
                      child: const Text('View Tasks'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: [
                    for (final task in success.tasks)
                      SizedBox(
                        width: itemWidth,
                        child: ProjectTaskPreviewCard(task: task),
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

final class _ProjectDetailsSkeleton extends StatelessWidget {
  const _ProjectDetailsSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: const [
        SkeletonBox(height: 160),
        SizedBox(height: AppSpacing.xxl),
        Row(
          children: [
            Expanded(child: SkeletonBox(height: 96)),
            SizedBox(width: AppSpacing.lg),
            Expanded(child: SkeletonBox(height: 96)),
          ],
        ),
        SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(child: SkeletonBox(height: 96)),
            SizedBox(width: AppSpacing.lg),
            Expanded(child: SkeletonBox(height: 96)),
          ],
        ),
        SizedBox(height: AppSpacing.xxl),
        SkeletonBox(height: 88),
        SizedBox(height: AppSpacing.md),
        SkeletonBox(height: 88),
        SizedBox(height: AppSpacing.md),
        SkeletonBox(height: 88),
      ],
    );
  }
}

final class _StaleBanner extends StatelessWidget {
  const _StaleBanner();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
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