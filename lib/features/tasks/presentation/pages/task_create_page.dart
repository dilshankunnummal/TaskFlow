import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:taskflow/core/di/injection.dart';
import 'package:taskflow/core/theme/app_breakpoints.dart';
import 'package:taskflow/core/theme/app_colors.dart';
import 'package:taskflow/core/theme/app_radius.dart';
import 'package:taskflow/core/theme/app_spacing.dart';
import 'package:taskflow/core/widgets/buttons/app_primary_button.dart';
import 'package:taskflow/core/widgets/cards/app_card.dart';
import 'package:taskflow/core/widgets/error/app_error_banner.dart';
import 'package:taskflow/core/widgets/inputs/app_dropdown_field.dart';
import 'package:taskflow/core/widgets/inputs/app_text_field.dart';
import 'package:taskflow/core/widgets/layout/glass_page_header.dart';
import 'package:taskflow/features/tasks/domain/entities/task.dart';
import 'package:taskflow/features/tasks/domain/entities/task_assignee.dart';
import 'package:taskflow/features/tasks/presentation/bloc/task_create_bloc.dart';
import 'package:taskflow/features/tasks/presentation/bloc/task_create_event.dart';
import 'package:taskflow/features/tasks/presentation/bloc/task_create_state.dart';

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

final class _TaskCreateView extends StatefulWidget {
  final String projectId;

  const _TaskCreateView({required this.projectId});

  @override
  State<_TaskCreateView> createState() => _TaskCreateViewState();
}

final class _TaskCreateViewState extends State<_TaskCreateView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dueDateController = TextEditingController();

  TaskStatus _status = TaskStatus.todo;
  TaskPriority _priority = TaskPriority.medium;
  TaskAssignee? _assignee;
  DateTime? _dueDate;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() {
        _dueDate = picked;
        _dueDateController.text = DateFormat.yMMMd().format(picked);
      });
    }
  }

  void _submit(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<TaskCreateBloc>().add(
            CreateTaskSubmitted(
              projectId: widget.projectId,
              title: _titleController.text,
              description: _descriptionController.text,
              status: _status,
              priority: _priority,
              assigneeId: _assignee?.id,
              dueDate: _dueDate,
            ),
          );
    }
  }

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
                      final showBanner =
                          state is TaskCreateError && errorMessage.isNotEmpty;

                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 800),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (showBanner) ...[
                                    AppErrorBanner(message: errorMessage),
                                    const SizedBox(height: AppSpacing.lg),
                                  ],
                                  LayoutBuilder(
                                    builder: (context, constraints) {
                                      final isWide =
                                          AppBreakpoints.isTablet(
                                                  constraints.maxWidth) ||
                                              AppBreakpoints.isDesktop(
                                                  constraints.maxWidth);

                                      if (isWide) {
                                        return Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: AppCard(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    AppTextField(
                                                      key: const Key(
                                                          'taskTitleField'),
                                                      controller:
                                                          _titleController,
                                                      label: 'Task Title',
                                                      hintText:
                                                          'Enter task title',
                                                      enabled: !isLoading,
                                                      validator: (value) =>
                                                          value == null ||
                                                                  value
                                                                      .trim()
                                                                      .isEmpty
                                                              ? 'Title is required'
                                                              : null,
                                                    ),
                                                    const SizedBox(
                                                        height: AppSpacing.lg),
                                                    AppTextField(
                                                      key: const Key(
                                                          'taskDescriptionField'),
                                                      controller:
                                                          _descriptionController,
                                                      label: 'Description',
                                                      hintText:
                                                          'Enter description',
                                                      enabled: !isLoading,
                                                      maxLines: 4,
                                                      minLines: 3,
                                                      validator: (value) =>
                                                          value == null ||
                                                                  value
                                                                      .trim()
                                                                      .isEmpty
                                                              ? 'Description is required'
                                                              : null,
                                                    ),
                                                    const SizedBox(
                                                        height: AppSpacing.lg),
                                                    GestureDetector(
                                                      onTap: isLoading
                                                          ? null
                                                          : () => _selectDate(
                                                              context),
                                                      child: AbsorbPointer(
                                                        child: AppTextField(
                                                          key: const Key(
                                                              'taskDueDateField'),
                                                          controller:
                                                              _dueDateController,
                                                          label: 'Due Date',
                                                          hintText:
                                                              'Select due date (optional)',
                                                          prefixIcon: Icons
                                                              .calendar_today_rounded,
                                                          enabled: !isLoading,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                                width: AppSpacing.lg),
                                            Expanded(
                                              child: AppCard(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    AppDropdownField<
                                                        TaskStatus>(
                                                      key: const Key(
                                                          'taskStatusField'),
                                                      value: _status,
                                                      items: TaskStatus.values,
                                                      label: 'Status',
                                                      itemLabelBuilder:
                                                          (item) => switch (
                                                              item) {
                                                        TaskStatus.todo =>
                                                          'Todo',
                                                        TaskStatus.inProgress =>
                                                          'In Progress',
                                                        TaskStatus.review =>
                                                          'Review',
                                                        TaskStatus.done =>
                                                          'Done',
                                                      },
                                                      onChanged: isLoading
                                                          ? null
                                                          : (value) {
                                                              if (value !=
                                                                  null) {
                                                                setState(() =>
                                                                    _status =
                                                                        value);
                                                              }
                                                            },
                                                    ),
                                                    const SizedBox(
                                                        height: AppSpacing.lg),
                                                    AppDropdownField<
                                                        TaskPriority>(
                                                      key: const Key(
                                                          'taskPriorityField'),
                                                      value: _priority,
                                                      items:
                                                          TaskPriority.values,
                                                      label: 'Priority',
                                                      itemLabelBuilder:
                                                          (item) => switch (
                                                              item) {
                                                        TaskPriority.low =>
                                                          'Low',
                                                        TaskPriority.medium =>
                                                          'Medium',
                                                        TaskPriority.high =>
                                                          'High',
                                                        TaskPriority.urgent =>
                                                          'Urgent',
                                                      },
                                                      onChanged: isLoading
                                                          ? null
                                                          : (value) {
                                                              if (value !=
                                                                  null) {
                                                                setState(() =>
                                                                    _priority =
                                                                        value);
                                                              }
                                                            },
                                                    ),
                                                    const SizedBox(
                                                        height: AppSpacing.lg),
                                                    AppDropdownField<
                                                        TaskAssignee>(
                                                      key: const Key(
                                                          'taskAssigneeField'),
                                                      value: _assignee,
                                                      items: state.assignees,
                                                      label: 'Assignee',
                                                      itemLabelBuilder:
                                                          (item) => item.name,
                                                      onChanged: isLoading
                                                          ? null
                                                          : (value) {
                                                              setState(() =>
                                                                  _assignee =
                                                                      value);
                                                            },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      }

                                      return AppCard(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            AppTextField(
                                              key: const Key('taskTitleField'),
                                              controller: _titleController,
                                              label: 'Task Title',
                                              hintText: 'Enter task title',
                                              enabled: !isLoading,
                                              validator: (value) => value ==
                                                          null ||
                                                      value.trim().isEmpty
                                                  ? 'Title is required'
                                                  : null,
                                            ),
                                            const SizedBox(
                                                height: AppSpacing.lg),
                                            AppTextField(
                                              key: const Key(
                                                  'taskDescriptionField'),
                                              controller:
                                                  _descriptionController,
                                              label: 'Description',
                                              hintText: 'Enter description',
                                              enabled: !isLoading,
                                              maxLines: 4,
                                              minLines: 3,
                                              validator: (value) => value ==
                                                          null ||
                                                      value.trim().isEmpty
                                                  ? 'Description is required'
                                                  : null,
                                            ),
                                            const SizedBox(
                                                height: AppSpacing.lg),
                                            AppDropdownField<TaskStatus>(
                                              key: const Key('taskStatusField'),
                                              value: _status,
                                              items: TaskStatus.values,
                                              label: 'Status',
                                              itemLabelBuilder: (item) =>
                                                  switch (item) {
                                                TaskStatus.todo => 'Todo',
                                                TaskStatus.inProgress =>
                                                  'In Progress',
                                                TaskStatus.review => 'Review',
                                                TaskStatus.done => 'Done',
                                              },
                                              onChanged: isLoading
                                                  ? null
                                                  : (value) {
                                                      if (value != null) {
                                                        setState(() =>
                                                            _status = value);
                                                      }
                                                    },
                                            ),
                                            const SizedBox(
                                                height: AppSpacing.lg),
                                            AppDropdownField<TaskPriority>(
                                              key: const Key(
                                                  'taskPriorityField'),
                                              value: _priority,
                                              items: TaskPriority.values,
                                              label: 'Priority',
                                              itemLabelBuilder: (item) =>
                                                  switch (item) {
                                                TaskPriority.low => 'Low',
                                                TaskPriority.medium => 'Medium',
                                                TaskPriority.high => 'High',
                                                TaskPriority.urgent => 'Urgent',
                                              },
                                              onChanged: isLoading
                                                  ? null
                                                  : (value) {
                                                      if (value != null) {
                                                        setState(() =>
                                                            _priority = value);
                                                      }
                                                    },
                                            ),
                                            const SizedBox(
                                                height: AppSpacing.lg),
                                            GestureDetector(
                                              onTap: isLoading
                                                  ? null
                                                  : () => _selectDate(context),
                                              child: AbsorbPointer(
                                                child: AppTextField(
                                                  key: const Key(
                                                      'taskDueDateField'),
                                                  controller:
                                                      _dueDateController,
                                                  label: 'Due Date',
                                                  hintText:
                                                      'Select due date (optional)',
                                                  prefixIcon: Icons
                                                      .calendar_today_rounded,
                                                  enabled: !isLoading,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                                height: AppSpacing.lg),
                                            AppDropdownField<TaskAssignee>(
                                              key: const Key(
                                                  'taskAssigneeField'),
                                              value: _assignee,
                                              items: state.assignees,
                                              label: 'Assignee',
                                              itemLabelBuilder: (item) =>
                                                  item.name,
                                              onChanged: isLoading
                                                  ? null
                                                  : (value) {
                                                      setState(() =>
                                                          _assignee = value);
                                                    },
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: AppSpacing.xl),
                                  AppPrimaryButton(
                                    key: const Key('submitTaskButton'),
                                    label: 'Create Task',
                                    isLoading: isLoading,
                                    onPressed: isLoading
                                        ? null
                                        : () => _submit(context),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
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
