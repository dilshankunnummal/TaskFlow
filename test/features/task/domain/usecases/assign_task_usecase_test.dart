import 'package:dartz/dartz.dart' hide Task;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taskflow/core/error/failures.dart';
import 'package:taskflow/features/tasks/domain/entities/task.dart';
import 'package:taskflow/features/tasks/domain/repositories/task_repository.dart';
import 'package:taskflow/features/tasks/domain/usecases/assign_task_usecase.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

void main() {
  late MockTaskRepository repository;
  late AssignTaskUseCase useCase;

  const taskId = 'task_001';
  const userId = 'user_001';

  final task = Task(
    id: taskId,
    projectId: 'proj_001',
    title: 'Task Title',
    description: 'Task Description',
    status: TaskStatus.todo,
    priority: TaskPriority.medium,
    assigneeId: userId,
    dueDate: null,
    createdAt: DateTime(2026, 8, 1),
  );

  setUp(() {
    repository = MockTaskRepository();
    useCase = AssignTaskUseCase(repository);
  });

  group('AssignTaskUseCase', () {
    test('returns ValidationFailure when taskId is empty', () async {
      final result = await useCase(taskId: '   ', userId: userId);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test('returns ValidationFailure when userId is empty', () async {
      final result = await useCase(taskId: taskId, userId: '   ');

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test('calls repository.assignTask and returns updated Task', () async {
      when(() => repository.assignTask(taskId: taskId, userId: userId))
          .thenAnswer((_) async => Right(task));

      final result = await useCase(taskId: taskId, userId: userId);

      expect(result, Right(task));
      verify(() => repository.assignTask(taskId: taskId, userId: userId))
          .called(1);
    });

    test('returns Left(InvalidOrganizationFailure) when user not in org',
        () async {
      when(() => repository.assignTask(taskId: taskId, userId: userId))
          .thenAnswer((_) async => const Left(InvalidOrganizationFailure()));

      final result = await useCase(taskId: taskId, userId: userId);

      expect(result, const Left(InvalidOrganizationFailure()));
    });
  });
}
