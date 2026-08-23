import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taskflow/core/constants/app_strings.dart';
import 'package:taskflow/core/di/injection.dart';
import 'package:taskflow/core/router/app_routes.dart';
import 'package:taskflow/core/theme/app_radius.dart';
import 'package:taskflow/core/theme/app_spacing.dart';
import 'package:taskflow/core/widgets/dialogs/app_confirm_dialog.dart';
import 'package:taskflow/core/widgets/empty_state_widget.dart';
import 'package:taskflow/core/widgets/error_state_widget.dart';
import 'package:taskflow/core/widgets/glass/glass_container.dart';
import 'package:taskflow/core/widgets/skeleton_loader.dart';
import 'package:taskflow/features/projects/domain/entities/project.dart';
import 'package:taskflow/features/projects/presentation/bloc/projects_bloc.dart';
import 'package:taskflow/features/projects/presentation/bloc/projects_event.dart';
import 'package:taskflow/features/projects/presentation/bloc/projects_state.dart';
import 'package:taskflow/features/projects/presentation/widgets/project_card.dart';
import 'package:taskflow/features/projects/presentation/widgets/projects_search_bar.dart';
import 'package:taskflow/features/notifications/presentation/widgets/notification_badge_button.dart';
import 'package:taskflow/features/projects/presentation/widgets/projects_sort_menu.dart';

class ProjectsListPage extends StatelessWidget {
  const ProjectsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProjectsBloc>()..add(const LoadProjects()),
      child: const ProjectsListView(),
    );
  }
}

class ProjectsListView extends StatefulWidget {
  const ProjectsListView({super.key});

  @override
  State<ProjectsListView> createState() => _ProjectsListViewState();
}

class _ProjectsListViewState extends State<ProjectsListView> {
  final _searchController = TextEditingController();

  ProjectsState? _lastContentState;
  String? _deletingProjectId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int _columnsForWidth(double width) {
    if (width >= 1100) return 3;
    if (width >= 700) return 2;
    return 1;
  }

  Future<void> _handleCreateProject(BuildContext context) async {
    final projectsBloc = context.read<ProjectsBloc>();
    final created = await context.push<bool>(AppRoutes.createProject);
    if (created == true) {
      projectsBloc.add(const RefreshProjects());
    }
  }

  Future<void> _handleOpenProject(BuildContext context, Project project) async {
    final projectsBloc = context.read<ProjectsBloc>();
    final deleted = await context.push<bool>('/projects/${project.id}');
    if (deleted == true && context.mounted) {
      projectsBloc.add(const RefreshProjects());
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Project deleted')));
    }
  }

  Future<void> _handleDeleteProject(
      BuildContext context,
      Project project,
      ) async {
    final bloc = context.read<ProjectsBloc>();

    await AppConfirmDialog.show(
      context,
      title: 'Delete project',
      message:
      'Delete "${project.name}"? This will permanently remove the project and its tasks. This cannot be undone.',
      confirmLabel: 'Delete',
      cancelLabel: 'Cancel',
      isDestructive: true,
      onConfirm: () async {
        bloc.add(DeleteProject(project.id));

        await bloc.stream.firstWhere(
              (state) =>
          state is ProjectDeleteSuccess || state is ProjectDeleteFailure,
        );
      },
    );
  }

  void _handleProjectsListener(BuildContext context, ProjectsState state) {
    if (state is ProjectsSuccess || state is ProjectsEmpty) {
      setState(() {
        _lastContentState = state;
        _deletingProjectId = null;
      });
      return;
    }

    if (state is ProjectDeleteInProgress) {
      setState(() => _deletingProjectId = state.projectId);
      return;
    }

    if (state is ProjectDeleteSuccess) {
      setState(() => _deletingProjectId = null);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Project deleted')));
      return;
    }

    if (state is ProjectDeleteFailure) {
      setState(() => _deletingProjectId = null);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(state.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return BlocListener<ProjectsBloc, ProjectsState>(
      listener: _handleProjectsListener,
      child: Scaffold(
        floatingActionButton: _CreateProjectFab(
          onPressed: () => _handleCreateProject(context),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final columns = _columnsForWidth(constraints.maxWidth);
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.lg,
                        AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
                    child: SizedBox(
                      height: 48,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                              child: Text('Projects',
                                  style: textTheme.headlineSmall)),
                          const NotificationBadgeButton(),
                          const SizedBox(width: AppSpacing.xs),
                          BlocBuilder<ProjectsBloc, ProjectsState>(
                            builder: (context, state) {
                              final content = _resolveContentState(state);
                              if (content is! ProjectsSuccess)
                                return const SizedBox.shrink();
                              return ProjectsSortMenu(
                                selected: content.sortOption,
                                onSelected: (option) => context
                                    .read<ProjectsBloc>()
                                    .add(SortProjects(option)),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: ProjectsSearchBar(
                      controller: _searchController,
                      onChanged: (query) => context
                          .read<ProjectsBloc>()
                          .add(SearchProjects(query)),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Expanded(
                    child: BlocBuilder<ProjectsBloc, ProjectsState>(
                      builder: (context, state) =>
                          _buildBody(context, state, columns),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  ProjectsState? _resolveContentState(ProjectsState state) {
    if (state is ProjectsSuccess || state is ProjectsEmpty) {
      return state;
    }
    if (state is ProjectDeleteInProgress ||
        state is ProjectDeleteSuccess ||
        state is ProjectDeleteFailure) {
      return _lastContentState;
    }
    return null;
  }

  Widget _buildBody(BuildContext context, ProjectsState state, int columns) {
    final content = _resolveContentState(state);

    if (content is ProjectsSuccess) {
      return _buildSuccessBody(context, content, columns);
    }

    if (content is ProjectsEmpty) {
      return const EmptyStateWidget(
        icon: Icons.folder_open_rounded,
        title: 'No projects yet',
        message: 'Projects assigned to your organization will show up here.',
      );
    }

    if (state is ProjectsInitial || state is ProjectsLoading) {
      return ProjectsListSkeleton(columns: columns);
    }

    if (state is ProjectsError) {
      return ErrorStateWidget(
        message: state.message,
        onRetry: () => context.read<ProjectsBloc>().add(const LoadProjects()),
      );
    }

    return ProjectsListSkeleton(columns: columns);
  }

  Widget _buildSuccessBody(
      BuildContext context, ProjectsSuccess success, int columns) {
    return RefreshIndicator(
      onRefresh: () async {
        final bloc = context.read<ProjectsBloc>();
        final future = bloc.stream.firstWhere(
          (s) =>
              s is ProjectsSuccess || s is ProjectsEmpty || s is ProjectsError,
          orElse: () => bloc.state,
        );
        bloc.add(const RefreshProjects());
        await future.timeout(const Duration(seconds: 3),
            onTimeout: () => bloc.state);
      },
      child: Column(
        children: [
          if (success.isStale) const _StaleBanner(),
          Expanded(
            child: success.visibleProjects.isEmpty
                ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(
                  height: 320,
                  child: EmptyStateWidget(
                    icon: Icons.search_off_rounded,
                    title: 'No matching projects',
                    message: 'Try a different search term.',
                  ),
                ),
              ],
            )
                : LayoutBuilder(
              builder: (context, gridConstraints) {
                const spacing = AppSpacing.lg;
                final totalSpacing = spacing * (columns - 1);
                final itemWidth =
                    (gridConstraints.maxWidth - totalSpacing) / columns;

                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: [
                      for (final project in success.visibleProjects)
                        SizedBox(
                          width: itemWidth,
                          child: ProjectCard(
                            project: project,
                            onTap: () =>
                                _handleOpenProject(context, project),
                            onDeleteRequested: () =>
                                _handleDeleteProject(context, project),
                            isDeleting: _deletingProjectId == project.id,
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

class _CreateProjectFab extends StatelessWidget {
  const _CreateProjectFab({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 90),
      child: GlassContainer(
        borderRadius: AppRadius.pillRadius,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: 56,
              height: 56,
              child: Icon(
                Icons.add_rounded,
                color: colorScheme.primary,
              ),
            ),
          ),
        ),
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
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      child: Row(
        children: [
          Icon(Icons.cloud_off_rounded,
              size: 16, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              AppStrings.offlineMessage,
              style: textTheme.labelSmall
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}