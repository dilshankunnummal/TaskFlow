import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taskflow/core/error/failures.dart';
import 'package:taskflow/features/tasks/domain/usecases/delete_task_usecase.dart';
import 'package:taskflow/features/tasks/presentation/bloc/task_delete_bloc.dart';
import 'package:taskflow/features/tasks/presentation/bloc/task_delete_event.dart';
import 'package:taskflow/features/tasks/presentation/bloc/task_delete_state.dart';

class MockDeleteTaskUseCase extends Mock implements DeleteTaskUseCase {}

void main() {
  late MockDeleteTaskUseCase deleteTask;

  const taskId = 'task_001';

  setUp(() {
    deleteTask = MockDeleteTaskUseCase();
  });

  TaskDeleteBloc buildBloc() => TaskDeleteBloc(deleteTask);

  group('TaskDeleteBloc', () {
    test('initial state is TaskDeleteInitial', () {
      expect(buildBloc().state, const TaskDeleteInitial());
    });

    blocTest<TaskDeleteBloc, TaskDeleteState>(
      'emits [TaskDeleteLoading, TaskDeleteSuccess] when DeleteTaskRequested succeeds',
      build: () {
        when(() => deleteTask(taskId)).thenAnswer((_) async => const Right(unit));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const DeleteTaskRequested(taskId)),
      expect: () => [
        const TaskDeleteLoading(),
        const TaskDeleteSuccess(),
      ],
    );

    blocTest<TaskDeleteBloc, TaskDeleteState>(
      'emits [TaskDeleteLoading, TaskDeleteError] when task is not found',
      build: () {
        when(() => deleteTask(taskId))
            .thenAnswer((_) async => const Left(NotFoundFailure()));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const DeleteTaskRequested(taskId)),
      expect: () => [
        const TaskDeleteLoading(),
        const TaskDeleteError('The requested resource was not found.'),
      ],
    );

    blocTest<TaskDeleteBloc, TaskDeleteState>(
      'emits [TaskDeleteLoading, TaskDeleteError] on repository failure',
      build: () {
        when(() => deleteTask(taskId))
            .thenAnswer((_) async => const Left(UnknownFailure()));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const DeleteTaskRequested(taskId)),
      expect: () => [
        const TaskDeleteLoading(),
        const TaskDeleteError('An unexpected error occurred.'),
      ],
    );
  });
}
