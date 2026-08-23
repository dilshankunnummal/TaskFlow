import 'package:taskflow/features/notifications/domain/entities/app_notification.dart';

class NotificationModel {
  final String id;
  final String userId;
  final String type;
  final String? taskId;
  final String message;
  final bool read;
  final String createdAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    this.taskId,
    required this.message,
    required this.read,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: json['type'] as String,
      taskId: json['task_id'] as String?,
      message: json['message'] as String,
      read: json['read'] as bool? ?? false,
      createdAt: json['created_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type,
      'task_id': taskId,
      'message': message,
      'read': read,
      'created_at': createdAt,
    };
  }

  AppNotification toEntity({String? taskTitle}) {
    return AppNotification(
      id: id,
      userId: userId,
      type: type,
      taskId: taskId,
      message: message,
      isRead: read,
      createdAt: DateTime.parse(createdAt),
      taskTitle: taskTitle,
    );
  }

  factory NotificationModel.fromEntity(AppNotification entity) {
    return NotificationModel(
      id: entity.id,
      userId: entity.userId,
      type: entity.type,
      taskId: entity.taskId,
      message: entity.message,
      read: entity.isRead,
      createdAt: entity.createdAt.toIso8601String(),
    );
  }
}
