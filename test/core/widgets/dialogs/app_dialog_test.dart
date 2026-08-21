import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/core/widgets/dialogs/app_confirm_dialog.dart';
import 'package:taskflow/core/widgets/dialogs/app_dialog.dart';

import '../../../test_utils/pump_app.dart';

void main() {
  group('AppDialog', () {
    testWidgets('shows title and content when opened', (tester) async {
      await pumpApp(
        tester,
        Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () => AppDialog.show<void>(
                context,
                title: 'Delete project',
                content: const Text('This action cannot be undone.'),
              ),
              child: const Text('Open'),
            );
          },
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Delete project'), findsOneWidget);
      expect(find.text('This action cannot be undone.'), findsOneWidget);
    });
  });

  group('AppConfirmDialog', () {
    testWidgets('resolves true when confirm is tapped', (tester) async {
      bool? result;

      await pumpApp(
        tester,
        Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () async {
                result = await AppConfirmDialog.show(
                  context,
                  title: 'Delete task',
                  message: 'Are you sure?',
                );
              },
              child: const Text('Open'),
            );
          },
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      expect(result, isTrue);
    });

    testWidgets('resolves false when cancel is tapped', (tester) async {
      bool? result;

      await pumpApp(
        tester,
        Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () async {
                result = await AppConfirmDialog.show(
                  context,
                  title: 'Delete task',
                  message: 'Are you sure?',
                );
              },
              child: const Text('Open'),
            );
          },
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(result, isFalse);
    });
  });
}
