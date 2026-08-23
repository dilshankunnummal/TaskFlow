import 'package:flutter/material.dart';
import 'package:taskflow/core/theme/app_spacing.dart';

class ProjectDetailsPlaceholderPage extends StatelessWidget {
  final String projectId;

  const ProjectDetailsPlaceholderPage({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Project')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.construction_rounded, size: 40),
              const SizedBox(height: AppSpacing.lg),
              Text('Project details coming soon',
                  style: textTheme.titleMedium, textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.sm),
              Text('Project ID: $projectId',
                  style: textTheme.bodyMedium, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
