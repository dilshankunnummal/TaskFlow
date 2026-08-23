import 'package:flutter/material.dart';
import 'package:taskflow/core/theme/app_spacing.dart';

class TaskDetailsPlaceholderPage extends StatelessWidget {
  const TaskDetailsPlaceholderPage({required this.taskId, super.key});

  final String taskId;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Task')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.construction_rounded, size: 40),
              const SizedBox(height: AppSpacing.lg),
              Text('Task details coming soon', style: textTheme.titleMedium, textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.sm),
              Text('Task ID: $taskId', style: textTheme.bodyMedium, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}