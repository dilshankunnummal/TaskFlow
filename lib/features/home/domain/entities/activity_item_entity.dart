import 'package:equatable/equatable.dart';

final class ActivityItemEntity extends Equatable {
  const ActivityItemEntity({
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

  @override
  List<Object?> get props => [id, title, projectName, status, timestamp];
}
