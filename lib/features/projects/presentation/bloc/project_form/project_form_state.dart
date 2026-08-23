import 'package:equatable/equatable.dart';
import 'package:taskflow/features/projects/domain/entities/project.dart';

sealed class ProjectFormState extends Equatable {
  const ProjectFormState();

  @override
  List<Object?> get props => [];
}

class ProjectFormInitial extends ProjectFormState {
  const ProjectFormInitial();
}

class ProjectFormLoading extends ProjectFormState {
  const ProjectFormLoading();
}

class ProjectFormSuccess extends ProjectFormState {
  final String message;
  final Project? project;

  const ProjectFormSuccess({required this.message, this.project});

  @override
  List<Object?> get props => [message, project];
}

class ProjectFormError extends ProjectFormState {
  final String message;
  final List<String> validationErrors;

  const ProjectFormError({
    this.message = '',
    this.validationErrors = const [],
  });

  @override
  List<Object?> get props => [message, validationErrors];
}