import 'package:injectable/injectable.dart';
import 'package:taskflow/core/data/mock_json_data_source.dart';
import 'package:taskflow/core/error/failures.dart';
import 'package:taskflow/core/network/connectivity_manager.dart';
import 'package:taskflow/features/notifications/data/models/notification_model.dart';

abstract class NotificationDataSource {
  Future<List<NotificationModel>> getNotificationsForUser({
    required String userId,
  });

  Future<NotificationModel> markAsRead({
    required String notificationId,
  });
}

@LazySingleton(as: NotificationDataSource)
class MockNotificationDataSource implements NotificationDataSource {
  final MockJsonDataSource _jsonDataSource;
  final ConnectivityManager _network;
  final List<NotificationModel> _inMemoryStore = [];
  bool _isInitialized = false;

  MockNotificationDataSource(this._jsonDataSource, this._network);

  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;
    try {
      final rows = await _jsonDataSource.section('notifications');
      _inMemoryStore.clear();
      _inMemoryStore.addAll(rows.map((row) => NotificationModel.fromJson(row)));
    } catch (_) {}
    if (_inMemoryStore.isEmpty) {
      _inMemoryStore.addAll(const [
        NotificationModel(
          id: 'notif_4001',
          userId: 'user_001',
          type: 'task_assigned',
          taskId: 'task_2004',
          message: 'You were assigned to "Fix broken contact form"',
          read: false,
          createdAt: '2025-12-10T09:05:00Z',
        ),
        NotificationModel(
          id: 'notif_4002',
          userId: 'user_001',
          type: 'task_assigned',
          taskId: 'task_2006',
          message: 'You were assigned to "QA pass on staging"',
          read: true,
          createdAt: '2025-12-15T09:05:00Z',
        ),
        NotificationModel(
          id: 'notif_4003',
          userId: 'user_001',
          type: 'task_assigned',
          taskId: 'task_2012',
          message: 'You were assigned to "Draft onboarding checklist"',
          read: false,
          createdAt: '2026-02-06T09:05:00Z',
        ),
      ]);
    }
    _isInitialized = true;
  }

  @override
  Future<List<NotificationModel>> getNotificationsForUser({
    required String userId,
  }) async {
    if (!_network.isOnline) {
      throw const OfflineFailure(null);
    }
    await _ensureInitialized();
    final list =
        _inMemoryStore.where((item) => item.userId == userId).toList();
    if (list.isNotEmpty) {
      return list;
    }
    return _inMemoryStore;
  }

  @override
  Future<NotificationModel> markAsRead({
    required String notificationId,
  }) async {
    if (!_network.isOnline) {
      throw const OfflineFailure(null);
    }
    await _ensureInitialized();
    final index =
        _inMemoryStore.indexWhere((item) => item.id == notificationId);
    if (index == -1) {
      throw const NotificationNotFoundFailure();
    }
    final existing = _inMemoryStore[index];
    final updated = NotificationModel(
      id: existing.id,
      userId: existing.userId,
      type: existing.type,
      taskId: existing.taskId,
      message: existing.message,
      read: true,
      createdAt: existing.createdAt,
    );
    _inMemoryStore[index] = updated;
    return updated;
  }
}
