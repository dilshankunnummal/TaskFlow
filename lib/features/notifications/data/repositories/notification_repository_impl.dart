import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:taskflow/core/error/failures.dart';
import 'package:taskflow/core/network/connectivity_manager.dart';
import 'package:taskflow/core/utils/logger.dart';
import 'package:taskflow/features/notifications/data/datasources/notification_datasource.dart';
import 'package:taskflow/features/notifications/domain/entities/app_notification.dart';
import 'package:taskflow/features/notifications/domain/repositories/notification_repository.dart';

@LazySingleton(as: NotificationRepository)
class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationDataSource _dataSource;
  final ConnectivityManager _network;
  final Map<String, List<AppNotification>> _cacheByUserId = {};

  NotificationRepositoryImpl(this._dataSource, this._network);

  @override
  Future<Either<Failure, List<AppNotification>>> getNotifications({
    required String userId,
  }) async {
    try {
      if (!_network.isOnline) {
        final cached = _cacheByUserId[userId];
        return Left(OfflineFailure(
          cached,
          cached == null || cached.isEmpty
              ? 'You are offline and no cached notifications are available'
              : 'You are offline. Showing cached notifications.',
        ));
      }

      final models = await _dataSource.getNotificationsForUser(userId: userId);
      final notifications = models.map((m) => m.toEntity()).toList();
      _cacheByUserId[userId] = notifications;
      return Right(notifications);
    } on OfflineFailure {
      final cached = _cacheByUserId[userId];
      return Left(OfflineFailure(
        cached,
        cached == null || cached.isEmpty
            ? 'You are offline and no cached notifications are available'
            : 'You are offline. Showing cached notifications.',
      ));
    } on Failure catch (failure) {
      return Left(failure);
    } catch (error, stackTrace) {
      AppLogger.error(
        'NotificationRepositoryImpl.getNotifications failed for userId=$userId',
        error: error,
        stackTrace: stackTrace,
      );
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, AppNotification>> markAsRead({
    required String notificationId,
  }) async {
    try {
      final model = await _dataSource.markAsRead(notificationId: notificationId);
      final entity = model.toEntity();

      final userId = entity.userId;
      final cachedList = _cacheByUserId[userId];
      if (cachedList != null) {
        final index = cachedList.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          final updatedList = List<AppNotification>.from(cachedList);
          updatedList[index] = entity;
          _cacheByUserId[userId] = updatedList;
        }
      }

      return Right(entity);
    } on NotificationNotFoundFailure catch (failure) {
      return Left(failure);
    } on OfflineFailure catch (failure) {
      return Left(failure);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (error, stackTrace) {
      AppLogger.error(
        'NotificationRepositoryImpl.markAsRead failed for notificationId=$notificationId',
        error: error,
        stackTrace: stackTrace,
      );
      return const Left(UnknownFailure());
    }
  }
}
