import 'dart:developer' as developer;

enum LogLevel { debug, info, warning, error }

abstract final class AppLogger {
  static void debug(String message, {String tag = 'TaskFlow'}) => _log(LogLevel.debug, message, tag);

  static void info(String message, {String tag = 'TaskFlow'}) => _log(LogLevel.info, message, tag);

  static void warning(String message, {String tag = 'TaskFlow'}) => _log(LogLevel.warning, message, tag);

  static void error(String message, {String tag = 'TaskFlow', Object? error, StackTrace? stackTrace}) {
    developer.log(
      _redact(message),
      name: tag,
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void _log(LogLevel level, String message, String tag) {
    developer.log(_redact(message), name: tag, level: _levelValue(level));
  }

  static int _levelValue(LogLevel level) {
    return switch (level) {
      LogLevel.debug => 500,
      LogLevel.info => 800,
      LogLevel.warning => 900,
      LogLevel.error => 1000,
    };
  }

  static final RegExp _tokenPattern = RegExp(
    r'(token|password|secret)"?\s*[:=]\s*"?[^",\s]+',
    caseSensitive: false,
  );

  static String _redact(String message) {
    return message.replaceAllMapped(_tokenPattern, (match) {
      final key = match.group(1);
      return '$key: [REDACTED]';
    });
  }
}
