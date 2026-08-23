import 'package:equatable/equatable.dart';
import 'package:taskflow/features/notifications/domain/entities/app_notification.dart';

sealed class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

final class NotificationInitial extends NotificationState {
  const NotificationInitial();
}

final class NotificationLoading extends NotificationState {
  const NotificationLoading();
}

final class NotificationSuccess extends NotificationState {
  final List<AppNotification> notifications;
  final int unreadCount;
  final bool isStale;

  const NotificationSuccess({
    required this.notifications,
    required this.unreadCount,
    this.isStale = false,
  });

  NotificationSuccess copyWith({
    List<AppNotification>? notifications,
    int? unreadCount,
    bool? isStale,
  }) {
    return NotificationSuccess(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      isStale: isStale ?? this.isStale,
    );
  }

  @override
  List<Object?> get props => [notifications, unreadCount, isStale];
}

final class NotificationEmpty extends NotificationState {
  final bool isStale;

  const NotificationEmpty({this.isStale = false});

  @override
  List<Object?> get props => [isStale];
}

final class NotificationError extends NotificationState {
  final String message;

  const NotificationError(this.message);

  @override
  List<Object?> get props => [message];
}
