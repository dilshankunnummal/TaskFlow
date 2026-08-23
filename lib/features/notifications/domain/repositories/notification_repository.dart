import 'package:dartz/dartz.dart';
import 'package:taskflow/core/error/failures.dart';
import 'package:taskflow/features/notifications/domain/entities/app_notification.dart';

abstract class NotificationRepository {
  Future<Either<Failure, List<AppNotification>>> getNotifications({
    required String userId,
  });

  Future<Either<Failure, AppNotification>> markAsRead({
    required String notificationId,
  });
}
