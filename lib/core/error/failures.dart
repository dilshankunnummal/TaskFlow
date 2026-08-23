import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

final class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Something went wrong on the server.']);
}

final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection available.']);
}

final class TimeoutFailure extends Failure {
  const TimeoutFailure([super.message = 'The request timed out. Please try again.']);
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'The requested resource was not found.']);
}

final class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

final class CacheFailure extends Failure {
  const CacheFailure([super.message = 'No cached data is available.']);
}

final class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Your session has expired. Please sign in again.']);
}

final class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

final class PermissionFailure extends Failure {
  const PermissionFailure([super.message = 'You do not have permission to perform this action.']);
}

class OfflineFailure extends Failure {
  final dynamic cachedData;

  const OfflineFailure(this.cachedData, [super.message = 'You are offline']);
}

final class TaskNotFoundFailure extends Failure {
  const TaskNotFoundFailure([super.message = 'Task not found.']);
}

final class UserNotFoundFailure extends Failure {
  const UserNotFoundFailure([super.message = 'User not found.']);
}

final class InvalidOrganizationFailure extends Failure {
  const InvalidOrganizationFailure(
      [super.message = 'User does not belong to the task\'s organization.']);
}

final class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'An unexpected error occurred.']);
}