abstract final class SecureStorageKeys {
  static const String accessToken = 'taskflow.access_token';
  static const String refreshToken = 'taskflow.refresh_token';
  static const String accessTokenExpiresAt = 'taskflow.access_token_expires_at';
  static const String currentUserId = 'taskflow.current_user_id';
  static const String currentOrgId = 'taskflow.current_org_id';
  static const String currentUserRole = 'taskflow.current_user_role';
  static const String loginTimestamp = 'taskflow.login_timestamp';
}

abstract final class HiveBoxNames {
  static const String projectsCache = 'taskflow_projects_cache';
  static const String tasksCache = 'taskflow_tasks_cache';
  static const String notificationsCache = 'taskflow_notifications_cache';
}

abstract final class PreferenceKeys {
  static const String themeMode = 'taskflow.theme_mode';
  static const String debugForceOffline = 'taskflow.debug_force_offline';
}
