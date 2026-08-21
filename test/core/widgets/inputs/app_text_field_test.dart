import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/core/widgets/inputs/app_text_field.dart';

import '../../../test_utils/pump_app.dart';

void main() {
  group('AppTextField', () {
    testWidgets('renders label and hint text', (tester) async {
      await pumpApp(
        tester,
        const AppTextField(label: 'Email', hintText: 'you@example.com'),
      );

      expect(find.text('Email'), findsOneWidget);
      expect(find.text('you@example.com'), findsOneWidget);
    });

    testWidgets('renders validation error text when provided', (tester) async {
      await pumpApp(
        tester,
        const AppTextField(label: 'Email', errorText: 'Email is required.'),
      );

      expect(find.text('Email is required.'), findsOneWidget);
    });

    testWidgets('forwards typed input through onChanged', (tester) async {
      String? latestValue;
      await pumpApp(
        tester,
        AppTextField(label: 'Email', onChanged: (value) => latestValue = value),
      );

      await tester.enterText(find.byType(TextField), 'admin@taskflow.io');
      expect(latestValue, 'admin@taskflow.io');
    });
  });
}
