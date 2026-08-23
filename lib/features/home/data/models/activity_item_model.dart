import 'package:taskflow/features/home/domain/entities/activity_item_entity.dart';

final class ActivityItemModel {
  const ActivityItemModel({
    required this.id,
    required this.title,
    required this.projectName,
    required this.status,
    required this.timestamp,
  });

  final String id;
  final String title;
  final String projectName;
  final String status;
  final DateTime timestamp;

  ActivityItemEntity toEntity() {
    return ActivityItemEntity(
      id: id,
      title: title,
      projectName: projectName,
      status: status,
      timestamp: timestamp,
    );
  }
}
