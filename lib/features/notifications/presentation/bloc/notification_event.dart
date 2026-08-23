import 'package:equatable/equatable.dart';

sealed class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

final class LoadNotifications extends NotificationEvent {
  final String userId;

  const LoadNotifications(this.userId);

  @override
  List<Object?> get props => [userId];
}

final class RefreshNotifications extends NotificationEvent {
  final String userId;

  const RefreshNotifications(this.userId);

  @override
  List<Object?> get props => [userId];
}

final class MarkNotificationRead extends NotificationEvent {
  final String notificationId;

  const MarkNotificationRead(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}
