import 'package:equatable/equatable.dart';
import 'package:taskflow/features/projects/domain/entities/project.dart';
import 'package:taskflow/features/projects/domain/entities/project_task.dart';

class ProjectDetails extends Equatable {
  final Project project;
  final List<ProjectTask> tasks;

  const ProjectDetails({
    required this.project,
    required this.tasks,
  });

  bool get hasTasks => tasks.isNotEmpty;

  int get totalTasks => tasks.length;

  int countByStatus(ProjectTaskStatus status) =>
      tasks.where((task) => task.status == status).length;

  ProjectDetails copyWith({
    Project? project,
    List<ProjectTask>? tasks,
  }) {
    return ProjectDetails(
      project: project ?? this.project,
      tasks: tasks ?? this.tasks,
    );
  }

  @override
  List<Object?> get props => [project, tasks];
}
