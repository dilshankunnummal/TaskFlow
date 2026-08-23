import 'package:equatable/equatable.dart';

class AppNotification extends Equatable {
  final String id;
  final String userId;
  final String type;
  final String? taskId;
  final String message;
  final bool isRead;
  final DateTime createdAt;
  final String? taskTitle;

  const AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    this.taskId,
    required this.message,
    required this.isRead,
    required this.createdAt,
    this.taskTitle,
  });

  AppNotification copyWith({
    String? id,
    String? userId,
    String? type,
    String? taskId,
    String? message,
    bool? isRead,
    DateTime? createdAt,
    String? taskTitle,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      taskId: taskId ?? this.taskId,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      taskTitle: taskTitle ?? this.taskTitle,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        type,
        taskId,
        message,
        isRead,
        createdAt,
        taskTitle,
      ];
}
