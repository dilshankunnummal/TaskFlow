import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:taskflow/core/error/failures.dart';
import 'package:taskflow/features/notifications/domain/entities/app_notification.dart';
import 'package:taskflow/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:taskflow/features/notifications/domain/usecases/mark_notification_read_usecase.dart';
import 'package:taskflow/features/notifications/presentation/bloc/notification_event.dart';
import 'package:taskflow/features/notifications/presentation/bloc/notification_state.dart';

@injectable
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetNotificationsUseCase _getNotifications;
  final MarkNotificationReadUseCase _markNotificationRead;

  NotificationBloc(
    this._getNotifications,
    this._markNotificationRead,
  ) : super(const NotificationInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<RefreshNotifications>(_onRefreshNotifications);
    on<MarkNotificationRead>(_onMarkNotificationRead);
  }

  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationLoading());
    await _fetchAndEmit(event.userId, emit);
  }

  Future<void> _onRefreshNotifications(
    RefreshNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    await _fetchAndEmit(event.userId, emit);
  }

  Future<void> _fetchAndEmit(
    String userId,
    Emitter<NotificationState> emit,
  ) async {
    final result = await _getNotifications(userId: userId);

    result.fold(
      (failure) {
        if (failure is OfflineFailure) {
          final cached = failure.cachedData as List<AppNotification>?;
          if (cached != null && cached.isNotEmpty) {
            final unread = cached.where((n) => !n.isRead).length;
            emit(NotificationSuccess(
              notifications: cached,
              unreadCount: unread,
              isStale: true,
            ));
          } else if (cached != null && cached.isEmpty) {
            emit(const NotificationEmpty(isStale: true));
          } else {
            emit(NotificationError(failure.message));
          }
        } else {
          emit(NotificationError(failure.message));
        }
      },
      (notifications) {
        if (notifications.isEmpty) {
          emit(const NotificationEmpty());
          return;
        }
        final unread = notifications.where((n) => !n.isRead).length;
        emit(NotificationSuccess(
          notifications: notifications,
          unreadCount: unread,
        ));
      },
    );
  }

  Future<void> _onMarkNotificationRead(
    MarkNotificationRead event,
    Emitter<NotificationState> emit,
  ) async {
    final current = state;
    final result = await _markNotificationRead(notificationId: event.notificationId);

    result.fold(
      (_) {},
      (updated) {
        if (current is NotificationSuccess) {
          final updatedList = current.notifications.map((item) {
            if (item.id == updated.id) {
              return item.copyWith(isRead: true);
            }
            return item;
          }).toList();
          final unread = updatedList.where((n) => !n.isRead).length;
          emit(current.copyWith(
            notifications: updatedList,
            unreadCount: unread,
          ));
        }
      },
    );
  }
}
