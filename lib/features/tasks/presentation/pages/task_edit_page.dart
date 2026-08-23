import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taskflow/core/di/injection.dart';
import 'package:taskflow/core/theme/app_colors.dart';
import 'package:taskflow/core/theme/app_spacing.dart';
import 'package:taskflow/core/widgets/error_state_widget.dart';
import 'package:taskflow/core/widgets/layout/glass_page_header.dart';
import 'package:taskflow/core/widgets/skeleton_loader.dart';
import 'package:taskflow/features/tasks/presentation/bloc/task_edit_bloc.dart';
import 'package:taskflow/features/tasks/presentation/bloc/task_edit_event.dart';
import 'package:taskflow/features/tasks/presentation/bloc/task_edit_state.dart';
import 'package:taskflow/features/tasks/presentation/widgets/task_form.dart';

final class TaskEditPage extends StatelessWidget {
  final String taskId;

  const TaskEditPage({required this.taskId, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TaskEditBloc>(
      create: (_) => getIt<TaskEditBloc>()..add(LoadTaskForEditing(taskId)),
      child: _TaskEditView(taskId: taskId),
    );
  }
}

final class _TaskEditView extends StatelessWidget {
  final String taskId;

  const _TaskEditView({required this.taskId});

  void _handleStateChange(BuildContext context, TaskEditState state) {
    if (state is TaskEditSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task updated successfully')),
      );
      context.pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<TaskEditBloc, TaskEditState>(
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
                  title: 'Edit Task',
                  onBack: () => context.pop(),
                ),
                Expanded(
                  child: BlocBuilder<TaskEditBloc, TaskEditState>(
                    builder: (context, state) {
                      if ((state is TaskEditInitial || state is TaskEditLoading) &&
                          state.task == null) {
                        return const _TaskEditSkeleton();
                      }

                      if (state is TaskEditError && state.task == null) {
                        return ErrorStateWidget(
                          message: state.message,
                          onRetry: () => context
                              .read<TaskEditBloc>()
                              .add(LoadTaskForEditing(taskId)),
                        );
                      }

                      final task = state.task;
                      if (task == null) {
                        return const _TaskEditSkeleton();
                      }

                      final isSubmitting = state is TaskEditSubmitting;
                      final errorMessage =
                          state is TaskEditError ? state.message : '';

                      return TaskForm(
                        initialTask: task,
                        assignees: state.assignees,
                        isLoading: isSubmitting,
                        errorMessage: errorMessage,
                        submitButtonLabel: 'Update Task',
                        onSubmit: ({
                          required title,
                          required description,
                          required status,
                          required priority,
                          required assignee,
                          required dueDate,
                        }) {
                          context.read<TaskEditBloc>().add(
                                UpdateTaskSubmitted(
                                  id: task.id,
                                  projectId: task.projectId,
                                  title: title,
                                  description: description,
                                  status: status,
                                  priority: priority,
                                  assigneeId: assignee?.id,
                                  dueDate: dueDate,
                                  createdAt: task.createdAt,
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

class _TaskEditSkeleton extends StatelessWidget {
  const _TaskEditSkeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SkeletonBox(height: 56, width: double.infinity),
              SizedBox(height: AppSpacing.lg),
              SkeletonBox(height: 120, width: double.infinity),
              SizedBox(height: AppSpacing.lg),
              SkeletonBox(height: 56, width: double.infinity),
              SizedBox(height: AppSpacing.lg),
              SkeletonBox(height: 56, width: double.infinity),
              SizedBox(height: AppSpacing.xl),
              SkeletonBox(height: 48, width: double.infinity),
            ],
          ),
        ),
      ),
    );
  }
}
