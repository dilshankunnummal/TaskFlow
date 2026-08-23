import 'package:flutter/material.dart';
import 'package:taskflow/core/widgets/buttons/app_primary_button.dart';
import 'package:taskflow/core/widgets/buttons/app_text_button.dart';
import 'package:taskflow/core/widgets/dialogs/app_dialog.dart';

final class AppConfirmDialog {
  const AppConfirmDialog._();

  static Future<bool> show(
      BuildContext context, {
        required String title,
        required String message,
        String confirmLabel = 'Confirm',
        String cancelLabel = 'Cancel',
        bool isDestructive = false,
        Future<void> Function()? onConfirm,
      }) async {
    final result = await AppDialog.show<bool>(
      context,
      title: title,
      content: Text(message, style: Theme.of(context).textTheme.bodyMedium),
      actions: [
        AppTextButton(
          label: cancelLabel,
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(false),
        ),
        SizedBox(
          width: 140,
          child: AppPrimaryButton(
            label: confirmLabel,
            onPressed: () async {
              if (onConfirm != null) {
                await onConfirm();
              }
              if (context.mounted) {
                Navigator.of(context, rootNavigator: true).pop(true);
              }
            },
          ),
        ),
      ],
    );
    return result ?? false;
  }
}