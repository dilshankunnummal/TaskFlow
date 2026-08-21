sealed class AppException implements Exception {
  const AppException(this.message);

  final String message;
}

final class ServerException extends AppException {
  const ServerException([super.message = 'Something went wrong on the server.']);
}

final class NetworkException extends AppException {
  const NetworkException([super.message = 'No internet connection available.']);
}

final class TimeoutException extends AppException {
  const TimeoutException([super.message = 'The request timed out. Please try again.']);
}

final class NotFoundException extends AppException {
  const NotFoundException([super.message = 'The requested resource was not found.']);
}

final class ValidationException extends AppException {
  const ValidationException(super.message);
}

final class CacheException extends AppException {
  const CacheException([super.message = 'No cached data is available.']);
}

final class UnauthorizedException extends AppException {
  const UnauthorizedException([super.message = 'Your session has expired. Please sign in again.']);
}

final class AuthException extends AppException {
  const AuthException(super.message);
}

final class PermissionException extends AppException {
  const PermissionException([super.message = 'You do not have permission to perform this action.']);
}
