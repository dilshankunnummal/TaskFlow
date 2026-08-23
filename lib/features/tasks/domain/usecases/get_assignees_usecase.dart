import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:taskflow/core/error/failures.dart';
import 'package:taskflow/features/tasks/domain/entities/task_assignee.dart';
import 'package:taskflow/features/tasks/domain/repositories/task_repository.dart';

@injectable
class GetAssigneesUseCase {
  final TaskRepository _repository;

  GetAssigneesUseCase(this._repository);

  Future<Either<Failure, List<TaskAssignee>>> call() async {
    return _repository.getAssignees();
  }
}
