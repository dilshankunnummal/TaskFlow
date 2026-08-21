import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/core/widgets/buttons/app_primary_button.dart';

import '../../../test_utils/pump_app.dart';

void main() {
  group('AppPrimaryButton', () {
    testWidgets('renders label and responds to tap when enabled', (tester) async {
      var tapCount = 0;
      await pumpApp(
        tester,
        AppPrimaryButton(label: 'Continue', onPressed: () => tapCount++),
      );

      expect(find.text('Continue'), findsOneWidget);
      await tester.tap(find.byType(AppPrimaryButton));
      await tester.pumpAndSettle();
      expect(tapCount, 1);
    });

    testWidgets('shows a progress indicator and ignores taps while loading', (tester) async {
      var tapCount = 0;
      await pumpApp(
        tester,
        AppPrimaryButton(label: 'Continue', isLoading: true, onPressed: () => tapCount++),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.tap(find.byType(AppPrimaryButton));
      await tester.pumpAndSettle();
      expect(tapCount, 0);
    });

    testWidgets('is visually disabled when onPressed is null', (tester) async {
      await pumpApp(tester, const AppPrimaryButton(label: 'Continue'));

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });
  });
}
