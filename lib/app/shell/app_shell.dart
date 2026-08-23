import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:taskflow/app/shell/widgets/app_bottom_navigation.dart';

final class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: AppBottomNavigation(navigationShell: navigationShell),
    );
  }
}
