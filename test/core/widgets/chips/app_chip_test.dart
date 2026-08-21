import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/core/widgets/chips/app_chip.dart';
import 'package:taskflow/core/widgets/chips/app_status_chip.dart';

import '../../../test_utils/pump_app.dart';

void main() {
  group('AppChip', () {
    testWidgets('renders label and responds to tap', (tester) async {
      var tapCount = 0;
      await pumpApp(
        tester,
        AppChip(label: 'Active', onTap: () => tapCount++),
      );

      expect(find.text('Active'), findsOneWidget);
      await tester.tap(find.byType(AppChip));
      expect(tapCount, 1);
    });
  });

  group('AppStatusChip', () {
    testWidgets('renders the provided status label', (tester) async {
      await pumpApp(
        tester,
        const AppStatusChip(label: 'In progress', status: 'in_progress'),
      );

      expect(find.text('In progress'), findsOneWidget);
    });
  });
}
