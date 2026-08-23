import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taskflow/core/error/failures.dart';
import 'package:taskflow/features/notifications/domain/entities/app_notification.dart';
import 'package:taskflow/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:taskflow/features/notifications/domain/usecases/mark_notification_read_usecase.dart';
import 'package:taskflow/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:taskflow/features/notifications/presentation/bloc/notification_event.dart';
import 'package:taskflow/features/notifications/presentation/bloc/notification_state.dart';

class MockGetNotificationsUseCase extends Mock
    implements GetNotificationsUseCase {}

class MockMarkNotificationReadUseCase extends Mock
    implements MarkNotificationReadUseCase {}

void main() {
  late MockGetNotificationsUseCase mockGetNotifications;
  late MockMarkNotificationReadUseCase mockMarkNotificationRead;
  late NotificationBloc notificationBloc;

  final tNotification = AppNotification(
    id: 'notif_1',
    userId: 'user_001',
    type: 'task_assigned',
    taskId: 'task_100',
    message: 'Assigned to task',
    isRead: false,
    createdAt: DateTime.parse('2026-01-01T10:00:00Z'),
  );

  final tReadNotification = tNotification.copyWith(isRead: true);

  setUp(() {
    mockGetNotifications = MockGetNotificationsUseCase();
    mockMarkNotificationRead = MockMarkNotificationReadUseCase();
    notificationBloc = NotificationBloc(
      mockGetNotifications,
      mockMarkNotificationRead,
    );
  });

  tearDown(() {
    notificationBloc.close();
  });

  test('initial state should be NotificationInitial', () {
    expect(notificationBloc.state, const NotificationInitial());
  });

  blocTest<NotificationBloc, NotificationState>(
    'emits [NotificationLoading, NotificationSuccess] when LoadNotifications succeeds',
    build: () {
      when(() => mockGetNotifications(userId: 'user_001')).thenAnswer(
        (_) async => Right([tNotification]),
      );
      return notificationBloc;
    },
    act: (bloc) => bloc.add(const LoadNotifications('user_001')),
    expect: () => [
      const NotificationLoading(),
      NotificationSuccess(
        notifications: [tNotification],
        unreadCount: 1,
      ),
    ],
  );

  blocTest<NotificationBloc, NotificationState>(
    'emits [NotificationLoading, NotificationEmpty] when LoadNotifications returns empty list',
    build: () {
      when(() => mockGetNotifications(userId: 'user_001')).thenAnswer(
        (_) async => const Right([]),
      );
      return notificationBloc;
    },
    act: (bloc) => bloc.add(const LoadNotifications('user_001')),
    expect: () => [
      const NotificationLoading(),
      const NotificationEmpty(),
    ],
  );

  blocTest<NotificationBloc, NotificationState>(
    'emits [NotificationLoading, NotificationError] when LoadNotifications fails',
    build: () {
      when(() => mockGetNotifications(userId: 'user_001')).thenAnswer(
        (_) async => const Left(ServerFailure('Server error')),
      );
      return notificationBloc;
    },
    act: (bloc) => bloc.add(const LoadNotifications('user_001')),
    expect: () => [
      const NotificationLoading(),
      const NotificationError('Server error'),
    ],
  );

  blocTest<NotificationBloc, NotificationState>(
    'emits NotificationSuccess when RefreshNotifications succeeds without emitting loading state',
    build: () {
      when(() => mockGetNotifications(userId: 'user_001')).thenAnswer(
        (_) async => Right([tNotification]),
      );
      return notificationBloc;
    },
    act: (bloc) => bloc.add(const RefreshNotifications('user_001')),
    expect: () => [
      NotificationSuccess(
        notifications: [tNotification],
        unreadCount: 1,
      ),
    ],
  );

  blocTest<NotificationBloc, NotificationState>(
    'emits updated NotificationSuccess when MarkNotificationRead succeeds',
    build: () {
      when(() => mockMarkNotificationRead(notificationId: 'notif_1'))
          .thenAnswer(
        (_) async => Right(tReadNotification),
      );
      return notificationBloc;
    },
    seed: () => NotificationSuccess(
      notifications: [tNotification],
      unreadCount: 1,
    ),
    act: (bloc) => bloc.add(const MarkNotificationRead('notif_1')),
    expect: () => [
      NotificationSuccess(
        notifications: [tReadNotification],
        unreadCount: 0,
      ),
    ],
  );
}
