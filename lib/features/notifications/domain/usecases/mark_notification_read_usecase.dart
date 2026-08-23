import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:taskflow/core/error/failures.dart';
import 'package:taskflow/features/notifications/domain/entities/app_notification.dart';
import 'package:taskflow/features/notifications/domain/repositories/notification_repository.dart';

@injectable
class MarkNotificationReadUseCase {
  final NotificationRepository _repository;

  MarkNotificationReadUseCase(this._repository);

  Future<Either<Failure, AppNotification>> call({
    required String notificationId,
  }) {
    return _repository.markAsRead(notificationId: notificationId);
  }
}
