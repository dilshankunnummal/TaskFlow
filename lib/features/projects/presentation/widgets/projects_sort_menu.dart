import 'package:flutter/material.dart';
import 'package:taskflow/features/projects/presentation/bloc/projects_state.dart';

class ProjectsSortMenu extends StatelessWidget {
  final ProjectSortOption selected;
  final ValueChanged<ProjectSortOption> onSelected;

  const ProjectsSortMenu({super.key, required this.selected, required this.onSelected});

  String _label(ProjectSortOption option) {
    switch (option) {
      case ProjectSortOption.newest:
        return 'Newest';
      case ProjectSortOption.oldest:
        return 'Oldest';
      case ProjectSortOption.alphabetical:
        return 'Alphabetical';
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<ProjectSortOption>(
      initialValue: selected,
      icon: const Icon(Icons.sort_rounded),
      tooltip: 'Sort projects',
      onSelected: onSelected,
      itemBuilder: (context) => ProjectSortOption.values
          .map(
            (option) => PopupMenuItem(
          value: option,
          child: Row(
            children: [
              if (option == selected) const Icon(Icons.check_rounded, size: 18) else const SizedBox(width: 18),
              const SizedBox(width: 8),
              Text(_label(option)),
            ],
          ),
        ),
      )
          .toList(),
    );
  }
}