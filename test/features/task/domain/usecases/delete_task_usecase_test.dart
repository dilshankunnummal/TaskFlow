import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taskflow/core/error/failures.dart';
import 'package:taskflow/features/tasks/domain/repositories/task_repository.dart';
import 'package:taskflow/features/tasks/domain/usecases/delete_task_usecase.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

void main() {
  late MockTaskRepository repository;
  late DeleteTaskUseCase useCase;

  const taskId = 'task_001';

  setUp(() {
    repository = MockTaskRepository();
    useCase = DeleteTaskUseCase(repository);
  });

  group('DeleteTaskUseCase', () {
    test('returns ValidationFailure when taskId is empty', () async {
      final result = await useCase('   ');

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test('calls repository.deleteTask and returns Right(unit) on success', () async {
      when(() => repository.deleteTask(taskId))
          .thenAnswer((_) async => const Right(unit));

      final result = await useCase(taskId);

      expect(result, const Right(unit));
      verify(() => repository.deleteTask(taskId)).called(1);
    });

    test('returns Left(Failure) when repository.deleteTask fails', () async {
      when(() => repository.deleteTask(taskId))
          .thenAnswer((_) async => const Left(NotFoundFailure()));

      final result = await useCase(taskId);

      expect(result, const Left(NotFoundFailure()));
      verify(() => repository.deleteTask(taskId)).called(1);
    });
  });
}
