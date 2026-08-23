import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:taskflow/app/shell/app_shell.dart';
import 'package:taskflow/app/shell/pages/coming_soon_page.dart';
import 'package:taskflow/core/router/app_routes.dart';
import 'package:taskflow/features/auth/presentation/pages/login_page.dart';
import 'package:taskflow/features/auth/presentation/pages/register_page.dart';
import 'package:taskflow/features/auth/presentation/pages/splash_page.dart';
import 'package:taskflow/features/home/presentation/pages/dashboard_page.dart';

final class AppRouter {
  const AppRouter._();

  static final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.root,
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: AppRoutes.root,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const DashboardPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.projects,
                builder: (context, state) => const ComingSoonPage(
                  title: 'Projects',
                  message: 'Project boards, filters, and details are coming soon.',
                  icon: Icons.folder_outlined,
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.tasks,
                builder: (context, state) => const ComingSoonPage(
                  title: 'Tasks',
                  message: 'Your assigned and tracked tasks will live here soon.',
                  icon: Icons.checklist_outlined,
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => const ComingSoonPage(
                  title: 'Profile',
                  message: 'Account details and settings are coming soon.',
                  icon: Icons.person_outline_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
