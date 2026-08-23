import 'package:equatable/equatable.dart';
import 'package:taskflow/features/projects/domain/entities/project.dart';
import 'package:taskflow/features/projects/domain/entities/project_task.dart';

class TaskSummary extends Equatable {
  final int total;
  final int todo;
  final int inProgress;
  final int review;
  final int done;

  const TaskSummary({
    required this.total,
    required this.todo,
    required this.inProgress,
    required this.review,
    required this.done,
  });

  factory TaskSummary.fromTasks(List<ProjectTask> tasks) {
    return TaskSummary(
      total: tasks.length,
      todo: tasks.where((task) => task.status == ProjectTaskStatus.todo).length,
      inProgress: tasks.where((task) => task.status == ProjectTaskStatus.inProgress).length,
      review: tasks.where((task) => task.status == ProjectTaskStatus.review).length,
      done: tasks.where((task) => task.status == ProjectTaskStatus.done).length,
    );
  }

  static const empty = TaskSummary(total: 0, todo: 0, inProgress: 0, review: 0, done: 0);

  @override
  List<Object?> get props => [total, todo, inProgress, review, done];
}

sealed class ProjectDetailsState extends Equatable {
  const ProjectDetailsState();

  @override
  List<Object?> get props => [];
}

class ProjectDetailsInitial extends ProjectDetailsState {
  const ProjectDetailsInitial();
}

class ProjectDetailsLoading extends ProjectDetailsState {
  const ProjectDetailsLoading();
}

class ProjectDetailsSuccess extends ProjectDetailsState {
  final Project project;
  final List<ProjectTask> tasks;
  final TaskSummary taskSummary;
  final bool isStale;

  const ProjectDetailsSuccess({
    required this.project,
    required this.tasks,
    required this.taskSummary,
    this.isStale = false,
  });

  ProjectDetailsSuccess copyWith({
    Project? project,
    List<ProjectTask>? tasks,
    TaskSummary? taskSummary,
    bool? isStale,
  }) {
    return ProjectDetailsSuccess(
      project: project ?? this.project,
      tasks: tasks ?? this.tasks,
      taskSummary: taskSummary ?? this.taskSummary,
      isStale: isStale ?? this.isStale,
    );
  }

  @override
  List<Object?> get props => [project, tasks, taskSummary, isStale];
}

class ProjectDetailsEmpty extends ProjectDetailsState {
  final Project project;
  final bool isStale;

  const ProjectDetailsEmpty({
    required this.project,
    this.isStale = false,
  });

  @override
  List<Object?> get props => [project, isStale];
}

class ProjectDetailsError extends ProjectDetailsState {
  final String message;

  const ProjectDetailsError(this.message);

  @override
  List<Object?> get props => [message];
}
