import 'package:flutter/foundation.dart';
import 'package:taskflow/core/error/exceptions.dart';
import 'package:taskflow/core/error/failures.dart';

sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;

  bool get isFailure => this is ResultFailure<T>;

  R fold<R>(R Function(Failure failure) onFailure, R Function(T value) onSuccess) {
    final self = this;
    if (self is Success<T>) {
      return onSuccess(self.value);
    }
    return onFailure((self as ResultFailure<T>).failure);
  }

  T? get valueOrNull => this is Success<T> ? (this as Success<T>).value : null;

  Failure? get failureOrNull => this is ResultFailure<T> ? (this as ResultFailure<T>).failure : null;

  static Result<T> guardSync<T>(T Function() body) {
    try {
      return Success(body());
    } on AppException catch (exception, stackTrace) {
      debugPrint('[Result.guardSync] AppException: $exception\n$stackTrace');
      return ResultFailure(exception.toFailure());
    } catch (error, stackTrace) {
      debugPrint('[Result.guardSync] Unexpected error: $error\n$stackTrace');
      return const ResultFailure(UnknownFailure());
    }
  }

  static Future<Result<T>> guard<T>(Future<T> Function() body) async {
    try {
      final value = await body();
      return Success(value);
    } on AppException catch (exception, stackTrace) {
      debugPrint('[Result.guard] AppException: $exception\n$stackTrace');
      return ResultFailure(exception.toFailure());
    } catch (error, stackTrace) {
      debugPrint('[Result.guard] Unexpected error: $error\n$stackTrace');
      return const ResultFailure(UnknownFailure());
    }
  }
}

final class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;
}

final class ResultFailure<T> extends Result<T> {
  const ResultFailure(this.failure);

  final Failure failure;
}

extension AppExceptionToFailure on AppException {
  Failure toFailure() {
    final exception = this;
    return switch (exception) {
      ServerException() => ServerFailure(exception.message),
      NetworkException() => NetworkFailure(exception.message),
      TimeoutException() => TimeoutFailure(exception.message),
      NotFoundException() => NotFoundFailure(exception.message),
      ValidationException() => ValidationFailure(exception.message),
      CacheException() => CacheFailure(exception.message),
      UnauthorizedException() => UnauthorizedFailure(exception.message),
      AuthException() => AuthFailure(exception.message),
      PermissionException() => PermissionFailure(exception.message),
    };
  }
}
