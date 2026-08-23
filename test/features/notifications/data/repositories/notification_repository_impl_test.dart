import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taskflow/core/error/failures.dart';
import 'package:taskflow/core/network/connectivity_manager.dart';
import 'package:taskflow/features/notifications/data/datasources/notification_datasource.dart';
import 'package:taskflow/features/notifications/data/models/notification_model.dart';
import 'package:taskflow/features/notifications/data/repositories/notification_repository_impl.dart';

class MockNotificationDataSource extends Mock
    implements NotificationDataSource {}

class MockConnectivityManager extends Mock implements ConnectivityManager {}

void main() {
  late MockNotificationDataSource mockDataSource;
  late MockConnectivityManager mockConnectivityManager;
  late NotificationRepositoryImpl repository;

  final tModel = NotificationModel(
    id: 'notif_1',
    userId: 'user_001',
    type: 'task_assigned',
    taskId: 'task_100',
    message: 'Assigned to task',
    read: false,
    createdAt: '2026-01-01T10:00:00.000Z',
  );

  setUp(() {
    mockDataSource = MockNotificationDataSource();
    mockConnectivityManager = MockConnectivityManager();
    repository = NotificationRepositoryImpl(
      mockDataSource,
      mockConnectivityManager,
    );
  });

  group('getNotifications', () {
    test('returns list of AppNotification when online and data source succeeds',
        () async {
      when(() => mockConnectivityManager.isOnline).thenReturn(true);
      when(() => mockDataSource.getNotificationsForUser(userId: 'user_001'))
          .thenAnswer((_) async => [tModel]);

      final result = await repository.getNotifications(userId: 'user_001');

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('should be Right'),
        (list) {
          expect(list.length, 1);
          expect(list.first.id, 'notif_1');
          expect(list.first.userId, 'user_001');
        },
      );
    });

    test('filters notifications by userId', () async {
      when(() => mockConnectivityManager.isOnline).thenReturn(true);
      when(() => mockDataSource.getNotificationsForUser(userId: 'user_001'))
          .thenAnswer((_) async => [tModel]);

      final result = await repository.getNotifications(userId: 'user_001');

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('should be Right'),
        (list) {
          expect(list.every((n) => n.userId == 'user_001'), isTrue);
        },
      );
    });

    test('returns OfflineFailure when offline and no cache is present',
        () async {
      when(() => mockConnectivityManager.isOnline).thenReturn(false);

      final result = await repository.getNotifications(userId: 'user_001');

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<OfflineFailure>()),
        (_) => fail('should be Left'),
      );
    });
  });

  group('markAsRead', () {
    test('returns updated AppNotification on success', () async {
      final tReadModel = NotificationModel(
        id: 'notif_1',
        userId: 'user_001',
        type: 'task_assigned',
        taskId: 'task_100',
        message: 'Assigned to task',
        read: true,
        createdAt: '2026-01-01T10:00:00.000Z',
      );

      when(() => mockDataSource.markAsRead(notificationId: 'notif_1'))
          .thenAnswer((_) async => tReadModel);

      final result = await repository.markAsRead(notificationId: 'notif_1');

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('should be Right'),
        (entity) => expect(entity.isRead, isTrue),
      );
    });

    test('returns NotificationNotFoundFailure when notification is not found',
        () async {
      when(() => mockDataSource.markAsRead(notificationId: 'invalid'))
          .thenThrow(const NotificationNotFoundFailure());

      final result = await repository.markAsRead(notificationId: 'invalid');

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<NotificationNotFoundFailure>()),
        (_) => fail('should be Left'),
      );
    });
  });
}
