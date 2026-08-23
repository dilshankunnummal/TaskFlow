import 'package:dartz/dartz.dart' hide Task;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taskflow/core/error/failures.dart';
import 'package:taskflow/features/tasks/data/datasources/tasks_datasource.dart';
import 'package:taskflow/features/tasks/data/datasources/tasks_local_datasource.dart';
import 'package:taskflow/features/tasks/data/models/task_model.dart';
import 'package:taskflow/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:taskflow/features/tasks/domain/entities/task.dart';

class MockTasksDataSource extends Mock implements TasksDataSource {}

class MockTasksLocalDataSource extends Mock implements TasksLocalDataSource {}

void main() {
  late MockTasksDataSource dataSource;
  late MockTasksLocalDataSource localDataSource;
  late TaskRepositoryImpl repository;

  const taskId = 'task_local_123';

  const taskModel = TaskModel(
    id: taskId,
    projectId: 'proj_001',
    title: 'New Local Task',
    description: 'Created locally',
    status: 'todo',
    priority: 'high',
    assigneeId: null,
    dueDate: null,
    createdAt: '2026-08-23T00:00:00.000Z',
  );

  setUp(() {
    dataSource = MockTasksDataSource();
    localDataSource = MockTasksLocalDataSource();
    repository = TaskRepositoryImpl(dataSource, localDataSource);
  });

  group('TaskRepositoryImpl.getTaskDetails', () {
    test(
        'returns local cached task when remote data source throws NotFoundFailure',
        () async {
      when(() => dataSource.getTaskDetails(taskId: taskId))
          .thenThrow(const NotFoundFailure());
      when(() => localDataSource.getCachedTask(taskId))
          .thenAnswer((_) async => taskModel);

      final result = await repository.getTaskDetails(taskId: taskId);

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected Right'),
        (details) {
          expect(details.task.id, taskId);
          expect(details.task.title, 'New Local Task');
        },
      );
    });

    test(
        'returns Left(NotFoundFailure) when remote throws NotFoundFailure and task is not in local cache',
        () async {
      when(() => dataSource.getTaskDetails(taskId: taskId))
          .thenThrow(const NotFoundFailure());
      when(() => localDataSource.getCachedTask(taskId))
          .thenAnswer((_) async => null);

      final result = await repository.getTaskDetails(taskId: taskId);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<NotFoundFailure>()),
        (_) => fail('Expected Left'),
      );
    });
  });
}
