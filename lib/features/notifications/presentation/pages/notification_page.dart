import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:taskflow/core/auth/current_session.dart';
import 'package:taskflow/core/constants/app_strings.dart';
import 'package:taskflow/core/di/injection.dart';
import 'package:taskflow/core/router/app_routes.dart';
import 'package:taskflow/core/theme/app_breakpoints.dart';
import 'package:taskflow/core/theme/app_radius.dart';
import 'package:taskflow/core/theme/app_spacing.dart';
import 'package:taskflow/core/widgets/cards/app_card.dart';
import 'package:taskflow/core/widgets/chips/app_chip.dart';
import 'package:taskflow/core/widgets/empty_state_widget.dart';
import 'package:taskflow/core/widgets/error_state_widget.dart';
import 'package:taskflow/core/widgets/skeleton_loader.dart';
import 'package:taskflow/features/notifications/domain/entities/app_notification.dart';
import 'package:taskflow/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:taskflow/features/notifications/presentation/bloc/notification_event.dart';
import 'package:taskflow/features/notifications/presentation/bloc/notification_state.dart';
import 'package:taskflow/core/data/mock_json_data_source.dart';
import 'package:taskflow/core/network/connectivity_manager.dart';
import 'package:taskflow/features/notifications/data/datasources/notification_datasource.dart';
import 'package:taskflow/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:taskflow/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:taskflow/features/notifications/domain/usecases/mark_notification_read_usecase.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

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
    return FutureBuilder<String?>(
      future: getIt<CurrentSession>().currentUserId,
      builder: (context, snapshot) {
        final userId = snapshot.data ?? 'user_001';
        return BlocProvider<NotificationBloc>(
          create: (_) => _createBloc()..add(LoadNotifications(userId)),
          child: NotificationView(userId: userId),
        );
      },
    );
  }
}

class NotificationView extends StatelessWidget {
  final String userId;

  const NotificationView({required this.userId, super.key});

  Future<void> _handleRefresh(BuildContext context) async {
    final bloc = context.read<NotificationBloc>();
    final future = bloc.stream.firstWhere(
      (s) =>
          s is NotificationSuccess ||
          s is NotificationEmpty ||
          s is NotificationError,
      orElse: () => bloc.state,
    );
    bloc.add(RefreshNotifications(userId));
    await future.timeout(const Duration(seconds: 3),
        onTimeout: () => bloc.state);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) {
              if (state is NotificationSuccess && state.unreadCount > 0) {
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.lg),
                  child: Center(
                    child: AppChip(
                      label: '${state.unreadCount} unread',
                      icon: Icons.mark_chat_unread_outlined,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = AppBreakpoints.isTablet(constraints.maxWidth) ||
                AppBreakpoints.isDesktop(constraints.maxWidth);

            return BlocBuilder<NotificationBloc, NotificationState>(
              builder: (context, state) {
                if (state is NotificationInitial ||
                    state is NotificationLoading) {
                  return const _NotificationSkeleton();
                }

                if (state is NotificationError) {
                  return ErrorStateWidget(
                    message: state.message,
                    onRetry: () => context
                        .read<NotificationBloc>()
                        .add(LoadNotifications(userId)),
                  );
                }

                if (state is NotificationEmpty) {
                  return RefreshIndicator(
                    onRefresh: () => _handleRefresh(context),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Container(
                        height: MediaQuery.of(context).size.height - 200,
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (state.isStale) const _StaleBanner(),
                            const EmptyStateWidget(
                              icon: Icons.notifications_none_rounded,
                              title: 'No notifications',
                              message: 'You are all caught up!',
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                if (state is NotificationSuccess) {
                  return RefreshIndicator(
                    onRefresh: () => _handleRefresh(context),
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: isWide ? AppSpacing.xxl : AppSpacing.lg,
                        vertical: AppSpacing.lg,
                      ),
                      itemCount: state.notifications.length +
                          (state.isStale ? 1 : 0),
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, index) {
                        if (state.isStale && index == 0) {
                          return const _StaleBanner();
                        }
                        final notification = state
                            .notifications[index - (state.isStale ? 1 : 0)];
                        return _NotificationCard(notification: notification);
                      },
                    ),
                  );
                }

                return const _NotificationSkeleton();
              },
            );
          },
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotification notification;

  const _NotificationCard({required this.notification});

  IconData _iconForType(String type) {
    switch (type) {
      case 'task_assigned':
        return Icons.assignment_ind_rounded;
      case 'task_updated':
        return Icons.update_rounded;
      case 'task_comment':
        return Icons.comment_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final isUnread = !notification.isRead;
    final primaryColor = colorScheme.primary;

    return AppCard(
      onTap: () {
        context
            .read<NotificationBloc>()
            .add(MarkNotificationRead(notification.id));
        if (notification.taskId != null && notification.taskId!.isNotEmpty) {
          try {
            context.push(AppRoutes.taskDetailPath(notification.taskId!));
          } catch (_) {}
        }
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: isUnread
            ? BoxDecoration(
                borderRadius: AppRadius.cardRadius,
                border: Border.all(
                  color: primaryColor.withOpacity(0.3),
                  width: 1,
                ),
                color: primaryColor.withOpacity(0.04),
              )
            : null,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: isUnread
                    ? primaryColor.withOpacity(0.16)
                    : colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _iconForType(notification.type),
                size: 20,
                color: isUnread ? primaryColor : colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.message,
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight:
                                isUnread ? FontWeight.w700 : FontWeight.w400,
                          ),
                        ),
                      ),
                      if (isUnread) ...[
                        const SizedBox(width: AppSpacing.xs),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (notification.taskTitle != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      notification.taskTitle!,
                      style: textTheme.labelMedium?.copyWith(
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    DateFormat.yMMMd()
                        .add_jm()
                        .format(notification.createdAt.toLocal()),
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationSkeleton extends StatelessWidget {
  const _NotificationSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (_, __) => const AppCard(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              SkeletonBox(
                height: 36,
                width: 36,
                radius: BorderRadius.all(Radius.circular(18)),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(height: 16, width: 220),
                    SizedBox(height: AppSpacing.xs),
                    SkeletonBox(height: 12, width: 120),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StaleBanner extends StatelessWidget {
  const _StaleBanner();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_off_rounded,
              size: 16, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              AppStrings.offlineMessage,
              style: textTheme.labelSmall
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}
