abstract final class AppConstants {
  static const String appName = 'TaskFlow';
  static const String appVersion = '0.1.0';

  static const int defaultPageSize = 20;
  static const int maxSearchResults = 50;

  static const Duration snackBarDuration = Duration(seconds: 3);
  static const Duration debounceDuration = Duration(milliseconds: 350);

  static const int maxTitleLength = 120;
  static const int maxDescriptionLength = 2000;
}
