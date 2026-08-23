import 'package:flutter/material.dart';
import 'package:taskflow/core/widgets/inputs/app_search_field.dart';

class ProjectsSearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final TextEditingController controller;

  const ProjectsSearchBar({
    super.key,
    required this.onChanged,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return AppSearchField(
      controller: controller,
      hintText: 'Search projects',
      onChanged: onChanged,
      trailing: ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, _) {
          if (value.text.isEmpty) return const SizedBox.shrink();
          return SizedBox(
            width: 24,
            height: 24,
            child: IconButton(
              icon: const Icon(Icons.close_rounded, size: 18),
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {
                controller.clear();
                onChanged('');
              },
            ),
          );
        },
      ),
    );
  }
}