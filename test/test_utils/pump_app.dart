import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/core/theme/app_theme.dart';

Widget wrapWithApp(Widget child) {
  return MaterialApp(
    theme: AppTheme.dark(),
    home: Scaffold(body: Center(child: child)),
  );
}

Future<void> pumpApp(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(wrapWithApp(child));
  await tester.pumpAndSettle();
}
