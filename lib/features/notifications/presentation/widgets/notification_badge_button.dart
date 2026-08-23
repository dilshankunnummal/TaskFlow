import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taskflow/core/auth/current_session.dart';
import 'package:taskflow/core/data/mock_json_data_source.dart';
import 'package:taskflow/core/di/injection.dart';
import 'package:taskflow/core/network/connectivity_manager.dart';
import 'package:taskflow/core/router/app_routes.dart';
import 'package:taskflow/features/notifications/data/datasources/notification_datasource.dart';
import 'package:taskflow/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:taskflow/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:taskflow/features/notifications/domain/usecases/mark_notification_read_usecase.dart';
import 'package:taskflow/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:taskflow/features/notifications/presentation/bloc/notification_event.dart';
import 'package:taskflow/features/notifications/presentation/bloc/notification_state.dart';

class NotificationBadgeButton extends StatelessWidget {
  const NotificationBadgeButton({super.key});

  NotificationBloc _createBloc() {
    if (getIt.isRegistered<NotificationBloc>()) {
      return getIt<NotificationBloc>();
    }
    final dataSource = MockNotificationDataSource(
      getIt<MockJsonDataSource>(),
      getIt<ConnectivityManager>(),
    );
    final repository = NotificationRepositoryImpl(
      dataSource,
      getIt<ConnectivityManager>(),
    );
    return NotificationBloc(
      GetNotificationsUseCase(repository),
      MarkNotificationReadUseCase(repository),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FutureBuilder<String?>(
      future: getIt<CurrentSession>().currentUserId,
      builder: (context, snapshot) {
        final userId = snapshot.data ?? 'user_001';

        return BlocProvider<NotificationBloc>(
          create: (_) => _createBloc()..add(LoadNotifications(userId)),
          child: BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) {
              final hasUnread =
                  state is NotificationSuccess && state.unreadCount > 0;

              return Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      key: const Key('dashboardNotificationsAction'),
                      icon: const Icon(Icons.notifications_outlined),
                      tooltip: 'Notifications',
                      onPressed: () => context.push(AppRoutes.notifications),
                    ),
                    if (hasUnread)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: colorScheme.error,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colorScheme.surface,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
