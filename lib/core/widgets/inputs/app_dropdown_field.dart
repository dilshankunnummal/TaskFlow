import 'package:flutter/material.dart';
import 'package:taskflow/core/theme/app_spacing.dart';

final class AppDropdownField<T> extends StatelessWidget {
  const AppDropdownField({
    required this.value,
    required this.items,
    required this.itemLabelBuilder,
    super.key,
    this.label,
    this.onChanged,
  });

  final T? value;
  final List<T> items;
  final String Function(T item) itemLabelBuilder;
  final String? label;
  final ValueChanged<T?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: AppSpacing.sm),
        ],
        DropdownButtonFormField<T>(
          initialValue: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
          items: [
            for (final item in items)
              DropdownMenuItem<T>(value: item, child: Text(itemLabelBuilder(item))),
          ],
          onChanged: onChanged,
        ),
      ],
    );
  }
}
