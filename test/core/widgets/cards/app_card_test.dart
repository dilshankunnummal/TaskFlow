import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/core/widgets/cards/app_card.dart';

import '../../../test_utils/pump_app.dart';

void main() {
  group('AppCard', () {
    testWidgets('renders its child content', (tester) async {
      await pumpApp(tester, const AppCard(child: Text('Enterprise Glass Redesign')));

      expect(find.text('Enterprise Glass Redesign'), findsOneWidget);
    });

    testWidgets('invokes onTap when tapped', (tester) async {
      var tapCount = 0;
      await pumpApp(
        tester,
        AppCard(onTap: () => tapCount++, child: const Text('Tap me')),
      );

      await tester.tap(find.byType(AppCard));
      expect(tapCount, 1);
    });
  });
}
