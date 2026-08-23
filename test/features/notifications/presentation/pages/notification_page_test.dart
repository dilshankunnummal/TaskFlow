import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taskflow/core/auth/current_session.dart';
import 'package:taskflow/core/di/injection.dart';
import 'package:taskflow/features/notifications/domain/entities/app_notification.dart';
import 'package:taskflow/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:taskflow/features/notifications/presentation/bloc/notification_event.dart';
import 'package:taskflow/features/notifications/presentation/bloc/notification_state.dart';
import 'package:taskflow/features/notifications/presentation/pages/notification_page.dart';

class MockNotificationBloc extends Mock implements NotificationBloc {}

class MockCurrentSession extends Mock implements CurrentSession {}

void main() {
  late MockNotificationBloc mockBloc;
  late MockCurrentSession mockCurrentSession;

  final tNotification = AppNotification(
    id: 'notif_1',
    userId: 'user_001',
    type: 'task_assigned',
    taskId: 'task_100',
    message: 'Assigned to task',
    isRead: false,
    createdAt: DateTime.parse('2026-01-01T10:00:00Z'),
  );

  setUp(() {
    mockBloc = MockNotificationBloc();
    mockCurrentSession = MockCurrentSession();

    when(() => mockCurrentSession.currentUserId)
        .thenAnswer((_) async => 'user_001');

    if (getIt.isRegistered<CurrentSession>()) {
      getIt.unregister<CurrentSession>();
    }
    getIt.registerSingleton<CurrentSession>(mockCurrentSession);

    if (getIt.isRegistered<NotificationBloc>()) {
      getIt.unregister<NotificationBloc>();
    }
    getIt.registerFactory<NotificationBloc>(() => mockBloc);
  });

  Widget buildWidget() {
    return MaterialApp(
      home: BlocProvider<NotificationBloc>.value(
        value: mockBloc,
        child: const NotificationView(userId: 'user_001'),
      ),
    );
  }

  testWidgets('renders loading state initially', (tester) async {
    when(() => mockBloc.state).thenReturn(const NotificationLoading());
    when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());

    await tester.pumpWidget(buildWidget());

    expect(find.byType(NotificationView), findsOneWidget);
  });

  testWidgets('renders success list and unread indicator', (tester) async {
    when(() => mockBloc.state).thenReturn(NotificationSuccess(
      notifications: [tNotification],
      unreadCount: 1,
    ));
    when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());

    await tester.pumpWidget(buildWidget());

    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Assigned to task'), findsOneWidget);
    expect(find.text('1 unread'), findsOneWidget);
  });

  testWidgets('renders empty state when NotificationEmpty', (tester) async {
    when(() => mockBloc.state).thenReturn(const NotificationEmpty());
    when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());

    await tester.pumpWidget(buildWidget());

    expect(find.text('No notifications'), findsOneWidget);
    expect(find.text('You are all caught up!'), findsOneWidget);
  });

  testWidgets('renders error state with retry button', (tester) async {
    when(() => mockBloc.state)
        .thenReturn(const NotificationError('Failed to load'));
    when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());

    await tester.pumpWidget(buildWidget());

    expect(find.text('Failed to load'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('tapping notification dispatches MarkNotificationRead event',
      (tester) async {
    when(() => mockBloc.state).thenReturn(NotificationSuccess(
      notifications: [tNotification],
      unreadCount: 1,
    ));
    when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());

    await tester.pumpWidget(buildWidget());
    await tester.tap(find.text('Assigned to task'));

    verify(() => mockBloc.add(const MarkNotificationRead('notif_1'))).called(1);
  });
}
