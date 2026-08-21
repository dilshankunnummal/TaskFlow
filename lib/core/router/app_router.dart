import 'package:go_router/go_router.dart';
import 'package:taskflow/core/router/app_routes.dart';
import 'package:taskflow/core/widgets/shell/bootstrap_placeholder_page.dart';

final class AppRouter {
  const AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.root,
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: AppRoutes.root,
        builder: (context, state) => const BootstrapPlaceholderPage(),
      ),
    ],
  );
}
