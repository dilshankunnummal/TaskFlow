abstract final class AppRoutes {
  static const String root = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String home = dashboard;
  static const String projects = '/projects';
  static const String createProject = '/projects/create';
  static const String projectDetail = '/projects/:projectId';
  static const String editProject = '/projects/:projectId/edit';
  static const String tasks = '/tasks';
  static const String projectTasks = '/projects/:projectId/tasks';
  static const String taskDetail = '/tasks/:taskId';
  static const String createTask = '/tasks/create';
  static const String profile = '/profile';
  static const String notifications = '/notifications';

  static String projectDetailPath(String projectId) => '/projects/$projectId';

  static String editProjectPath(String projectId) => '/projects/$projectId/edit';

  static String projectTasksPath(String projectId) => '/projects/$projectId/tasks';

  static String taskDetailPath(String taskId) => '/tasks/$taskId';

  static String createTaskPath(String projectId) => '/tasks/create?projectId=$projectId';
}