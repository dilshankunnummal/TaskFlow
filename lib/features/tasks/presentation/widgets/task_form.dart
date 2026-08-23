import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:taskflow/core/theme/app_breakpoints.dart';
import 'package:taskflow/core/theme/app_spacing.dart';
import 'package:taskflow/core/widgets/buttons/app_primary_button.dart';
import 'package:taskflow/core/widgets/cards/app_card.dart';
import 'package:taskflow/core/widgets/error/app_error_banner.dart';
import 'package:taskflow/core/widgets/inputs/app_dropdown_field.dart';
import 'package:taskflow/core/widgets/inputs/app_text_field.dart';
import 'package:taskflow/features/tasks/domain/entities/task.dart';
import 'package:taskflow/features/tasks/domain/entities/task_assignee.dart';

class TaskForm extends StatefulWidget {
  final Task? initialTask;
  final List<TaskAssignee> assignees;
  final bool isLoading;
  final String errorMessage;
  final String submitButtonLabel;
  final void Function({
    required String title,
    required String description,
    required TaskStatus status,
    required TaskPriority priority,
    required TaskAssignee? assignee,
    required DateTime? dueDate,
  }) onSubmit;

  const TaskForm({
    required this.assignees,
    required this.isLoading,
    required this.errorMessage,
    required this.submitButtonLabel,
    required this.onSubmit,
    this.initialTask,
    super.key,
  });

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _dueDateController;

  late TaskStatus _status;
  late TaskPriority _priority;
  TaskAssignee? _assignee;
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    final task = widget.initialTask;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController = TextEditingController(text: task?.description ?? '');
    _dueDate = task?.dueDate;
    _dueDateController = TextEditingController(
      text: _dueDate != null ? DateFormat.yMMMd().format(_dueDate!) : '',
    );
    _status = task?.status ?? TaskStatus.todo;
    _priority = task?.priority ?? TaskPriority.medium;

    if (task?.assigneeId != null) {
      for (final a in widget.assignees) {
        if (a.id == task!.assigneeId) {
          _assignee = a;
          break;
        }
      }
    }
  }

  @override
  void didUpdateWidget(TaskForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_assignee == null && widget.initialTask?.assigneeId != null && widget.assignees.isNotEmpty) {
      for (final a in widget.assignees) {
        if (a.id == widget.initialTask!.assigneeId) {
          setState(() {
            _assignee = a;
          });
          break;
        }
      }
    }
  }

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

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSubmit(
        title: _titleController.text,
        description: _descriptionController.text,
        status: _status,
        priority: _priority,
        assignee: _assignee,
        dueDate: _dueDate,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = widget.isLoading;
    final showBanner = widget.errorMessage.isNotEmpty;

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
                  AppErrorBanner(message: widget.errorMessage),
                  const SizedBox(height: AppSpacing.lg),
                ],
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = AppBreakpoints.isTablet(constraints.maxWidth) ||
                        AppBreakpoints.isDesktop(constraints.maxWidth);

                    if (isWide) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: AppCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppTextField(
                                    key: const Key('taskTitleField'),
                                    controller: _titleController,
                                    label: 'Task Title',
                                    hintText: 'Enter task title',
                                    enabled: !isLoading,
                                    validator: (value) =>
                                        value == null || value.trim().isEmpty
                                            ? 'Title is required'
                                            : null,
                                  ),
                                  const SizedBox(height: AppSpacing.lg),
                                  AppTextField(
                                    key: const Key('taskDescriptionField'),
                                    controller: _descriptionController,
                                    label: 'Description',
                                    hintText: 'Enter description',
                                    enabled: !isLoading,
                                    maxLines: 4,
                                    minLines: 3,
                                    validator: (value) =>
                                        value == null || value.trim().isEmpty
                                            ? 'Description is required'
                                            : null,
                                  ),
                                  const SizedBox(height: AppSpacing.lg),
                                  GestureDetector(
                                    onTap: isLoading ? null : () => _selectDate(context),
                                    child: AbsorbPointer(
                                      child: AppTextField(
                                        key: const Key('taskDueDateField'),
                                        controller: _dueDateController,
                                        label: 'Due Date',
                                        hintText: 'Select due date (optional)',
                                        prefixIcon: Icons.calendar_today_rounded,
                                        enabled: !isLoading,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.lg),
                          Expanded(
                            child: AppCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppDropdownField<TaskStatus>(
                                    key: const Key('taskStatusField'),
                                    value: _status,
                                    items: TaskStatus.values,
                                    label: 'Status',
                                    itemLabelBuilder: (item) => switch (item) {
                                      TaskStatus.todo => 'Todo',
                                      TaskStatus.inProgress => 'In Progress',
                                      TaskStatus.review => 'Review',
                                      TaskStatus.done => 'Done',
                                    },
                                    onChanged: isLoading
                                        ? null
                                        : (value) {
                                            if (value != null) {
                                              setState(() => _status = value);
                                            }
                                          },
                                  ),
                                  const SizedBox(height: AppSpacing.lg),
                                  AppDropdownField<TaskPriority>(
                                    key: const Key('taskPriorityField'),
                                    value: _priority,
                                    items: TaskPriority.values,
                                    label: 'Priority',
                                    itemLabelBuilder: (item) => switch (item) {
                                      TaskPriority.low => 'Low',
                                      TaskPriority.medium => 'Medium',
                                      TaskPriority.high => 'High',
                                      TaskPriority.urgent => 'Urgent',
                                    },
                                    onChanged: isLoading
                                        ? null
                                        : (value) {
                                            if (value != null) {
                                              setState(() => _priority = value);
                                            }
                                          },
                                  ),
                                  const SizedBox(height: AppSpacing.lg),
                                  AppDropdownField<TaskAssignee>(
                                    key: const Key('taskAssigneeField'),
                                    value: _assignee,
                                    items: widget.assignees,
                                    label: 'Assignee',
                                    itemLabelBuilder: (item) => item.name,
                                    onChanged: isLoading
                                        ? null
                                        : (value) {
                                            setState(() => _assignee = value);
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppTextField(
                            key: const Key('taskTitleField'),
                            controller: _titleController,
                            label: 'Task Title',
                            hintText: 'Enter task title',
                            enabled: !isLoading,
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                    ? 'Title is required'
                                    : null,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          AppTextField(
                            key: const Key('taskDescriptionField'),
                            controller: _descriptionController,
                            label: 'Description',
                            hintText: 'Enter description',
                            enabled: !isLoading,
                            maxLines: 4,
                            minLines: 3,
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                    ? 'Description is required'
                                    : null,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          AppDropdownField<TaskStatus>(
                            key: const Key('taskStatusField'),
                            value: _status,
                            items: TaskStatus.values,
                            label: 'Status',
                            itemLabelBuilder: (item) => switch (item) {
                              TaskStatus.todo => 'Todo',
                              TaskStatus.inProgress => 'In Progress',
                              TaskStatus.review => 'Review',
                              TaskStatus.done => 'Done',
                            },
                            onChanged: isLoading
                                ? null
                                : (value) {
                                    if (value != null) {
                                      setState(() => _status = value);
                                    }
                                  },
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          AppDropdownField<TaskPriority>(
                            key: const Key('taskPriorityField'),
                            value: _priority,
                            items: TaskPriority.values,
                            label: 'Priority',
                            itemLabelBuilder: (item) => switch (item) {
                              TaskPriority.low => 'Low',
                              TaskPriority.medium => 'Medium',
                              TaskPriority.high => 'High',
                              TaskPriority.urgent => 'Urgent',
                            },
                            onChanged: isLoading
                                ? null
                                : (value) {
                                    if (value != null) {
                                      setState(() => _priority = value);
                                    }
                                  },
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          GestureDetector(
                            onTap: isLoading ? null : () => _selectDate(context),
                            child: AbsorbPointer(
                              child: AppTextField(
                                key: const Key('taskDueDateField'),
                                controller: _dueDateController,
                                label: 'Due Date',
                                hintText: 'Select due date (optional)',
                                prefixIcon: Icons.calendar_today_rounded,
                                enabled: !isLoading,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          AppDropdownField<TaskAssignee>(
                            key: const Key('taskAssigneeField'),
                            value: _assignee,
                            items: widget.assignees,
                            label: 'Assignee',
                            itemLabelBuilder: (item) => item.name,
                            onChanged: isLoading
                                ? null
                                : (value) {
                                    setState(() => _assignee = value);
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
                  label: widget.submitButtonLabel,
                  isLoading: isLoading,
                  onPressed: isLoading ? null : _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
