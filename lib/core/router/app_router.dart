import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:taskflow/app/shell/app_shell.dart';
import 'package:taskflow/app/shell/pages/coming_soon_page.dart';
import 'package:taskflow/core/router/app_routes.dart';
import 'package:taskflow/features/auth/presentation/pages/login_page.dart';
import 'package:taskflow/features/auth/presentation/pages/register_page.dart';
import 'package:taskflow/features/auth/presentation/pages/splash_page.dart';
import 'package:taskflow/features/home/presentation/pages/dashboard_page.dart';
import 'package:taskflow/features/projects/domain/entities/project.dart';
import 'package:taskflow/features/projects/presentation/pages/create_project_page.dart';
import 'package:taskflow/features/projects/presentation/pages/edit_project_page.dart';
import 'package:taskflow/features/projects/presentation/pages/project_details_page.dart';
import 'package:taskflow/features/projects/presentation/pages/projects_list_page.dart';
import 'package:taskflow/features/tasks/presentation/pages/task_details_placeholder_page.dart';
import 'package:taskflow/features/tasks/presentation/pages/task_list_page.dart';

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
      GoRoute(
        path: AppRoutes.createProject,
        name: 'createProject',
        builder: (context, state) => const CreateProjectPage(),
      ),
      GoRoute(
        path: AppRoutes.editProject,
        name: 'editProject',
        builder: (context, state) => EditProjectPage(
          project: state.extra as Project,
        ),
      ),
      GoRoute(
        path: AppRoutes.projectDetail,
        name: 'projectDetails',
        builder: (context, state) => ProjectDetailsPage(
          projectId: state.pathParameters['projectId']!,
        ),
      ),

      GoRoute(
        path: AppRoutes.projectTasks,
        name: 'projectTasks',
        builder: (context, state) => TaskListPage(
          projectId: state.pathParameters['projectId']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.taskDetail,
        name: 'taskDetails',
        builder: (context, state) => TaskDetailsPlaceholderPage(
          taskId: state.pathParameters['taskId']!,
        ),
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
                name: 'projects',
                builder: (context, state) => const ProjectsListPage(),
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