import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:taskflow/app/shell/app_shell.dart';
import 'package:taskflow/core/theme/app_theme.dart';

void main() {
  GoRouter buildRouter() {
    return GoRouter(
      initialLocation: '/home',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) => AppShell(navigationShell: navigationShell),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(path: '/home', builder: (context, state) => const Scaffold(body: Text('Home Screen'))),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/projects',
                  builder: (context, state) => const Scaffold(body: Text('Projects Screen')),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(path: '/tasks', builder: (context, state) => const Scaffold(body: Text('Tasks Screen'))),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/profile',
                  builder: (context, state) => const Scaffold(body: Text('Profile Screen')),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  testWidgets('renders all four bottom navigation destinations', (tester) async {
    await tester.pumpWidget(MaterialApp.router(theme: AppTheme.dark(), routerConfig: buildRouter()));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Projects'), findsOneWidget);
    expect(find.text('Tasks'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Home Screen'), findsOneWidget);
  });

  testWidgets('selecting a tab switches the visible branch content', (tester) async {
    await tester.pumpWidget(MaterialApp.router(theme: AppTheme.dark(), routerConfig: buildRouter()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Projects'));
    await tester.pumpAndSettle();

    expect(find.text('Projects Screen'), findsOneWidget);
    expect(find.text('Home Screen'), findsNothing);
  });
}
