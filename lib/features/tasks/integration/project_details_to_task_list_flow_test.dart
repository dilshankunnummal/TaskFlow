// import 'dart:async';
//
// import 'package:dartz/dartz.dart' hide Task;
// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:get_it/get_it.dart';
// import 'package:go_router/go_router.dart';
// import 'package:mocktail/mocktail.dart';
// import 'package:taskflow/core/di/injection.dart';
// import 'package:taskflow/core/error/failures.dart';
// import 'package:taskflow/core/router/app_routes.dart';
// import 'package:taskflow/core/theme/app_theme.dart';
// import 'package:taskflow/features/projects/domain/entities/project.dart';
// import 'package:taskflow/features/projects/domain/entities/project_details.dart';
// import 'package:taskflow/features/projects/domain/entities/project_task.dart';
// import 'package:taskflow/features/projects/domain/usecases/get_project_details_usecase.dart';
// import 'package:taskflow/features/projects/presentation/bloc/project_details_bloc.dart';
// import 'package:taskflow/features/projects/presentation/pages/project_details_page.dart';
// import 'package:taskflow/features/tasks/domain/entities/task.dart';
// import 'package:taskflow/features/tasks/domain/repositories/task_repository.dart';
// import 'package:taskflow/features/tasks/domain/usecases/get_project_tasks_usecase.dart';
// import 'package:taskflow/features/tasks/presentation/bloc/task_list_bloc.dart';
// import 'package:taskflow/features/tasks/presentation/pages/task_list_page.dart';
//
// class MockGetProjectDetailsUseCase extends Mock implements GetProjectDetailsUseCase {}
//
// class MockGetProjectTasksUseCase extends Mock implements GetProjectTasksUseCase {}
//
// class MockTaskRepository extends Mock implements TaskRepository {}
//
// void main() {
//   final getIt = GetIt.instance;
//
//   late MockGetProjectDetailsUseCase getProjectDetails;
//   late MockGetProjectTasksUseCase getProjectTasks;
//   late MockTaskRepository taskRepository;
//
//   const projectId = 'proj_1';
//
//   final project = Project(
//     id: projectId,
//     orgId: 'org_1',
//     name: 'Atlas',
//     description: 'Rebuild the design system',
//     status: ProjectStatus.active,
//     taskCount: 2,
//     createdAt: DateTime(2026, 1, 1),
//   );
//
//   final previewTasks = [
//     ProjectTask(
//       id: 'pt_1',
//       projectId: projectId,
//       title: 'Design review',
//       description: 'Review the bento layout',
//       status: ProjectTaskStatus.todo,
//       priority: ProjectTaskPriority.high,
//       assigneeId: 'user_1',
//       dueDate: DateTime(2026, 9, 1),
//       createdAt: DateTime(2026, 8, 1),
//     ),
//   ];
//
//   final projectDetails = ProjectDetails(project: project, tasks: previewTasks);
//
//   final fullTask = Task(
//     id: 'task_1',
//     projectId: projectId,
//     title: 'Design review',
//     description: 'Review the bento layout',
//     status: TaskStatus.todo,
//     priority: TaskPriority.high,
//     assigneeId: 'user_1',
//     dueDate: DateTime(2026, 9, 1),
//     createdAt: DateTime(2026, 8, 1),
//   );
//
//   setUp(() {
//     getProjectDetails = MockGetProjectDetailsUseCase();
//     getProjectTasks = MockGetProjectTasksUseCase();
//     taskRepository = MockTaskRepository();
//
//     getIt
//       ..reset()
//       ..registerFactory<GetProjectDetailsUseCase>(() => getProjectDetails)
//       ..registerFactory<ProjectDetailsBloc>(() => ProjectDetailsBloc(getIt<GetProjectDetailsUseCase>()))
//       ..registerFactory<GetProjectTasksUseCase>(() => getProjectTasks)
//       ..registerFactory<TaskRepository>(() => taskRepository)
//       ..registerFactory<TaskListBloc>(
//             () => TaskListBloc(getIt<GetProjectTasksUseCase>(), getIt<TaskRepository>()),
//       );
//   });
//
//   tearDown(() async {
//     await getIt.reset();
//   });
//
//   GoRouter buildRouter() {
//     return GoRouter(
//       initialLocation: AppRoutes.projectDetailPath(projectId),
//       routes: [
//         GoRoute(
//           path: AppRoutes.projectDetail,
//           builder: (context, state) => ProjectDetailsPage(
//             projectId: state.pathParameters['projectId']!,
//           ),
//         ),
//         GoRoute(
//           path: AppRoutes.projectTasks,
//           builder: (context, state) => TaskListPage(
//             projectId: state.pathParameters['projectId']!,
//           ),
//         ),
//       ],
//     );
//   }
//
//   testWidgets('opens Task List from Project Details via View Tasks and loads tasks through the repository',
//           (tester) async {
//         when(() => getProjectDetails(projectId: projectId)).thenAnswer((_) async => Right(projectDetails));
//         when(() => getProjectTasks(projectId: projectId)).thenAnswer((_) async => Right([fullTask]));
//
//         await tester.pumpWidget(MaterialApp.router(theme: AppTheme.dark(), routerConfig: buildRouter()));
//         await tester.pumpAndSettle();
//
//         expect(find.text('Atlas'), findsOneWidget);
//         expect(find.text('View Tasks'), findsOneWidget);
//
//         await tester.tap(find.text('View Tasks'));
//         await tester.pumpAndSettle();
//
//         verify(() => getProjectTasks(projectId: projectId)).called(1);
//         expect(find.text('Design review'), findsOneWidget);
//         expect(find.text('High'), findsOneWidget);
//         expect(find.text('Todo'), findsOneWidget);
//       });
//
//   testWidgets('shows the Task List loading state before tasks resolve', (tester) async {
//     when(() => getProjectDetails(projectId: projectId)).thenAnswer((_) async => Right(projectDetails));
//
//     final completer = Completer<Either<Failure, List<Task>>>();
//     when(() => getProjectTasks(projectId: projectId)).thenAnswer((_) => completer.future);
//
//     await tester.pumpWidget(MaterialApp.router(theme: AppTheme.dark(), routerConfig: buildRouter()));
//     await tester.pumpAndSettle();
//
//     await tester.tap(find.text('View Tasks'));
//     await tester.pump();
//
//     expect(find.byType(GridView), findsOneWidget);
//     expect(find.text('Design review'), findsNothing);
//
//     completer.complete(Right([fullTask]));
//     await tester.pumpAndSettle();
//
//     expect(find.text('Design review'), findsOneWidget);
//   });
//
//   testWidgets('pull to refresh on Task List calls the repository and re-renders', (tester) async {
//     when(() => getProjectDetails(projectId: projectId)).thenAnswer((_) async => Right(projectDetails));
//     when(() => getProjectTasks(projectId: projectId)).thenAnswer((_) async => Right([fullTask]));
//     when(() => taskRepository.refreshTasks(projectId: projectId)).thenAnswer((_) async => Right([fullTask]));
//
//     await tester.pumpWidget(MaterialApp.router(theme: AppTheme.dark(), routerConfig: buildRouter()));
//     await tester.pumpAndSettle();
//
//     await tester.tap(find.text('View Tasks'));
//     await tester.pumpAndSettle();
//
//     await tester.fling(find.byType(RefreshIndicator), const Offset(0, 300), 1000);
//     await tester.pumpAndSettle();
//
//     verify(() => taskRepository.refreshTasks(projectId: projectId)).called(1);
//     verifyNever(() => getProjectTasks(projectId: projectId).call.call);
//     expect(find.text('Design review'), findsOneWidget);
//   });
// }