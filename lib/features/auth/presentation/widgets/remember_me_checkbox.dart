import 'package:flutter/material.dart';
import 'package:taskflow/core/constants/app_strings.dart';
import 'package:taskflow/core/theme/app_spacing.dart';

final class RememberMeCheckbox extends StatelessWidget {
  const RememberMeCheckbox({required this.value, required this.onChanged, super.key});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Checkbox(
                value: value,
                onChanged: (checked) => onChanged(checked ?? false),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(AppStrings.loginRememberMe, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
