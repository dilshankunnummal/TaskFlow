import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taskflow/core/di/injection.dart';
import 'package:taskflow/core/theme/app_colors.dart';
import 'package:taskflow/core/widgets/layout/glass_page_header.dart';
import 'package:taskflow/features/tasks/presentation/bloc/task_create_bloc.dart';
import 'package:taskflow/features/tasks/presentation/bloc/task_create_event.dart';
import 'package:taskflow/features/tasks/presentation/bloc/task_create_state.dart';
import 'package:taskflow/features/tasks/presentation/widgets/task_form.dart';

final class TaskCreatePage extends StatelessWidget {
  final String projectId;

  const TaskCreatePage({required this.projectId, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TaskCreateBloc>(
      create: (_) => getIt<TaskCreateBloc>()..add(const LoadAssignees()),
      child: _TaskCreateView(projectId: projectId),
    );
  }
}

final class _TaskCreateView extends StatelessWidget {
  final String projectId;

  const _TaskCreateView({required this.projectId});

  void _handleStateChange(BuildContext context, TaskCreateState state) {
    if (state is TaskCreateSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task created successfully')),
      );
      context.pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<TaskCreateBloc, TaskCreateState>(
      listener: _handleStateChange,
      child: Scaffold(
        body: DecoratedBox(
          decoration: BoxDecoration(
            gradient: isDark
                ? AppColors.backgroundWashDark
                : AppColors.backgroundWashLight,
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GlassPageHeader(
                  title: 'Create Task',
                  onBack: () => context.pop(),
                ),
                Expanded(
                  child: BlocBuilder<TaskCreateBloc, TaskCreateState>(
                    builder: (context, state) {
                      final isLoading = state is TaskCreateLoading;
                      final errorMessage =
                          state is TaskCreateError ? state.message : '';

                      return TaskForm(
                        assignees: state.assignees,
                        isLoading: isLoading,
                        errorMessage: errorMessage,
                        submitButtonLabel: 'Create Task',
                        onSubmit: ({
                          required title,
                          required description,
                          required status,
                          required priority,
                          required assignee,
                          required dueDate,
                        }) {
                          context.read<TaskCreateBloc>().add(
                                CreateTaskSubmitted(
                                  projectId: projectId,
                                  title: title,
                                  description: description,
                                  status: status,
                                  priority: priority,
                                  assigneeId: assignee?.id,
                                  dueDate: dueDate,
                                ),
                              );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
