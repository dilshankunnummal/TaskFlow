import 'package:dartz/dartz.dart' hide Task;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taskflow/core/error/failures.dart';
import 'package:taskflow/features/tasks/domain/entities/task.dart';
import 'package:taskflow/features/tasks/domain/repositories/task_repository.dart';
import 'package:taskflow/features/tasks/domain/usecases/update_task_usecase.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

void main() {
  late MockTaskRepository repository;
  late UpdateTaskUseCase useCase;

  final task = Task(
    id: 'task_001',
    projectId: 'proj_001',
    title: 'Updated Title',
    description: 'Updated Description',
    status: TaskStatus.inProgress,
    priority: TaskPriority.high,
    assigneeId: 'user_001',
    dueDate: DateTime(2026, 9, 20),
    createdAt: DateTime(2026, 8, 1),
  );

  setUp(() {
    repository = MockTaskRepository();
    useCase = UpdateTaskUseCase(repository);
    registerFallbackValue(task);
  });

  group('UpdateTaskUseCase', () {
    test('returns ValidationFailure when title is empty', () async {
      final result = await useCase(
        id: 'task_001',
        projectId: 'proj_001',
        title: '   ',
        description: 'Valid description',
        status: TaskStatus.todo,
        priority: TaskPriority.low,
        assigneeId: null,
        dueDate: null,
        createdAt: DateTime(2026, 8, 1),
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test('returns ValidationFailure when description is empty', () async {
      final result = await useCase(
        id: 'task_001',
        projectId: 'proj_001',
        title: 'Valid title',
        description: '',
        status: TaskStatus.todo,
        priority: TaskPriority.low,
        assigneeId: null,
        dueDate: null,
        createdAt: DateTime(2026, 8, 1),
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test('calls repository.updateTask when inputs are valid', () async {
      when(() => repository.updateTask(any()))
          .thenAnswer((_) async => Right(task));

      final result = await useCase(
        id: 'task_001',
        projectId: 'proj_001',
        title: 'Updated Title',
        description: 'Updated Description',
        status: TaskStatus.inProgress,
        priority: TaskPriority.high,
        assigneeId: 'user_001',
        dueDate: DateTime(2026, 9, 20),
        createdAt: DateTime(2026, 8, 1),
      );

      expect(result, Right(task));
      verify(() => repository.updateTask(any())).called(1);
    });
  });
}
