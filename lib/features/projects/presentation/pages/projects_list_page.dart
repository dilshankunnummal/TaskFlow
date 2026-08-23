import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taskflow/core/constants/app_strings.dart';
import 'package:taskflow/core/di/injection.dart';
import 'package:taskflow/core/theme/app_spacing.dart';
import 'package:taskflow/core/widgets/empty_state_widget.dart';
import 'package:taskflow/core/widgets/error_state_widget.dart';
import 'package:taskflow/core/widgets/skeleton_loader.dart';
import 'package:taskflow/features/projects/presentation/bloc/projects_bloc.dart';
import 'package:taskflow/features/projects/presentation/bloc/projects_event.dart';
import 'package:taskflow/features/projects/presentation/bloc/projects_state.dart';
import 'package:taskflow/features/projects/presentation/widgets/project_card.dart';
import 'package:taskflow/features/projects/presentation/widgets/projects_search_bar.dart';
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

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final columns = _columnsForWidth(constraints.maxWidth);
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.lg,
                      AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
                  child: Row(
                    children: [
                      Expanded(
                          child:
                              Text('Projects', style: textTheme.headlineSmall)),
                      BlocBuilder<ProjectsBloc, ProjectsState>(
                        builder: (context, state) {
                          if (state is! ProjectsSuccess)
                            return const SizedBox.shrink();
                          return ProjectsSortMenu(
                            selected: state.sortOption,
                            onSelected: (option) => context
                                .read<ProjectsBloc>()
                                .add(SortProjects(option)),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: ProjectsSearchBar(
                    controller: _searchController,
                    onChanged: (query) =>
                        context.read<ProjectsBloc>().add(SearchProjects(query)),
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
    );
  }

  Widget _buildBody(BuildContext context, ProjectsState state, int columns) {
    if (state is ProjectsInitial || state is ProjectsLoading) {
      return ProjectsListSkeleton(columns: columns);
    }

    if (state is ProjectsEmpty) {
      return const EmptyStateWidget(
        icon: Icons.folder_open_rounded,
        title: 'No projects yet',
        message: 'Projects assigned to your organization will show up here.',
      );
    }

    if (state is ProjectsError) {
      return ErrorStateWidget(
        message: state.message,
        onRetry: () => context.read<ProjectsBloc>().add(const LoadProjects()),
      );
    }

    final success = state as ProjectsSuccess;

    return RefreshIndicator(
      onRefresh: () async {
        context.read<ProjectsBloc>().add(const RefreshProjects());
        await context
            .read<ProjectsBloc>()
            .stream
            .firstWhere((s) => s is! ProjectsLoading);
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
                                      context.push('/projects/${project.id}'),
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
