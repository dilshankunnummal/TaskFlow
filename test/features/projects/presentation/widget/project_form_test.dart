import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taskflow/features/projects/domain/entities/project.dart';
import 'package:taskflow/features/projects/presentation/bloc/project_form/project_form_bloc.dart';
import 'package:taskflow/features/projects/presentation/bloc/project_form/project_form_event.dart';
import 'package:taskflow/features/projects/presentation/bloc/project_form/project_form_state.dart';
import 'package:taskflow/features/projects/presentation/widgets/project_form.dart';

class MockProjectFormBloc extends MockBloc<ProjectFormEvent, ProjectFormState> implements ProjectFormBloc {}

class FakeProjectFormEvent extends Fake implements ProjectFormEvent {}

void main() {
  late MockProjectFormBloc bloc;

  setUpAll(() {
    registerFallbackValue(FakeProjectFormEvent());
  });

  setUp(() {
    bloc = MockProjectFormBloc();
    when(() => bloc.state).thenReturn(const ProjectFormInitial());
  });

  Future<void> pumpForm(WidgetTester tester, {Project? initialProject}) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider<ProjectFormBloc>.value(
            value: bloc,
            child: ProjectForm(initialProject: initialProject),
          ),
        ),
      ),
    );
  }

  group('create mode', () {
    testWidgets('shows a validation error when the name field is left empty', (tester) async {
      await pumpForm(tester);

      await tester.enterText(find.byKey(const Key('projectNameField')), 'Temp');
      await tester.pump();
      await tester.enterText(find.byKey(const Key('projectNameField')), '');
      await tester.pump();

      expect(find.text('Project name is required.'), findsOneWidget);

      final submitButton = tester.widget<ElevatedButton>(
        find.descendant(
          of: find.byKey(const Key('submitProjectButton')),
          matching: find.byType(ElevatedButton),
        ),
      );
      expect(submitButton.onPressed, isNull);
    });

    testWidgets('shows a validation error when the name is shorter than the minimum length', (tester) async {
      await pumpForm(tester);

      await tester.enterText(find.byKey(const Key('projectNameField')), 'ab');
      await tester.pump();

      expect(find.text('Project name must be at least 3 characters.'), findsOneWidget);
    });

    testWidgets('dispatches CreateProject when the form is valid and submitted', (tester) async {
      await pumpForm(tester);

      await tester.enterText(find.byKey(const Key('projectNameField')), 'Website Redesign');
      await tester.enterText(find.byKey(const Key('projectDescriptionField')), 'Redesign the marketing site.');
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('submitProjectButton')));
      await tester.pump();

      verify(
            () => bloc.add(
          const CreateProject(
            name: 'Website Redesign',
            description: 'Redesign the marketing site.',
          ),
        ),
      ).called(1);
    });

    testWidgets('renders the reusable error banner when submission fails', (tester) async {
      when(() => bloc.state).thenReturn(const ProjectFormError(message: 'Something went wrong'));

      await pumpForm(tester);

      expect(find.text('Something went wrong'), findsOneWidget);
    });

    testWidgets('disables the submit button and shows a spinner while loading', (tester) async {
      when(() => bloc.state).thenReturn(const ProjectFormLoading());

      await pumpForm(tester);

      final submitButton = tester.widget<ElevatedButton>(
        find.descendant(
          of: find.byKey(const Key('submitProjectButton')),
          matching: find.byType(ElevatedButton),
        ),
      );
      expect(submitButton.onPressed, isNull);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('edit mode', () {
    final existingProject = Project(
      id: 'proj_1001',
      orgId: 'org_a1b2c3',
      name: 'Website Relaunch',
      description: 'Redesign the marketing website.',
      status: ProjectStatus.planning,
      taskCount: 4,
      createdAt: DateTime.parse('2026-01-01T09:00:00Z'),
    );

    testWidgets('pre-fills the form with the existing project name and description', (tester) async {
      await pumpForm(tester, initialProject: existingProject);

      expect(find.text('Website Relaunch'), findsOneWidget);
      expect(find.text('Redesign the marketing website.'), findsOneWidget);

      final submitButton = tester.widget<ElevatedButton>(
        find.descendant(
          of: find.byKey(const Key('submitProjectButton')),
          matching: find.byType(ElevatedButton),
        ),
      );
      expect(submitButton.onPressed, isNotNull);
    });

    testWidgets('shows a validation error when the pre-filled name is cleared', (tester) async {
      await pumpForm(tester, initialProject: existingProject);

      await tester.enterText(find.byKey(const Key('projectNameField')), '');
      await tester.pump();

      expect(find.text('Project name is required.'), findsOneWidget);

      final submitButton = tester.widget<ElevatedButton>(
        find.descendant(
          of: find.byKey(const Key('submitProjectButton')),
          matching: find.byType(ElevatedButton),
        ),
      );
      expect(submitButton.onPressed, isNull);
    });

    testWidgets('dispatches UpdateProject with the edited fields on successful submission', (tester) async {
      await pumpForm(tester, initialProject: existingProject);

      await tester.enterText(find.byKey(const Key('projectNameField')), 'Website Relaunch v2');
      await tester.enterText(find.byKey(const Key('projectDescriptionField')), 'Refreshed scope and timeline.');
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('submitProjectButton')));
      await tester.pump();

      verify(
            () => bloc.add(
          UpdateProject(
            existingProject.copyWith(
              name: 'Website Relaunch v2',
              description: 'Refreshed scope and timeline.',
            ),
          ),
        ),
      ).called(1);
    });

    testWidgets('renders the reusable error banner when the update fails', (tester) async {
      when(() => bloc.state).thenReturn(const ProjectFormError(message: 'Could not update project'));

      await pumpForm(tester, initialProject: existingProject);

      expect(find.text('Could not update project'), findsOneWidget);
    });
  });
}