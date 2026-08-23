import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/core/theme/app_theme.dart';
import 'package:taskflow/features/tasks/domain/entities/task.dart';
import 'package:taskflow/features/tasks/presentation/widgets/task_card.dart';

void main() {
  final task = Task(
    id: 'task_1',
    projectId: 'proj_1',
    title: 'Design review',
    description: 'Review the new bento layout',
    status: TaskStatus.inProgress,
    priority: TaskPriority.urgent,
    assigneeId: 'ava_thompson',
    dueDate: DateTime(2026, 9, 1),
    createdAt: DateTime(2026, 8, 1),
  );

  Widget wrap(Widget child) {
    return MaterialApp(theme: AppTheme.dark(), home: Scaffold(body: Center(child: child)));
  }

  testWidgets('displays title, priority, status, assignee, and due date', (tester) async {
    await tester.pumpWidget(wrap(TaskCard(task: task, onTap: () {})));

    expect(find.text('Design review'), findsOneWidget);
    expect(find.text('Urgent'), findsOneWidget);
    expect(find.text('In progress'), findsOneWidget);
    expect(find.text('Ava thompson'), findsOneWidget);
  });

  testWidgets('shows Unassigned when there is no assignee', (tester) async {
    final unassigned = task.copyWith(assigneeId: null);
    await tester.pumpWidget(wrap(TaskCard(task: unassigned, onTap: () {})));

    expect(find.text('Unassigned'), findsOneWidget);
  });

  testWidgets('invokes onTap when the card is tapped', (tester) async {
    var tapped = false;
    await tester.pumpWidget(wrap(TaskCard(task: task, onTap: () => tapped = true)));

    await tester.tap(find.byType(TaskCard));
    await tester.pump();

    expect(tapped, isTrue);
  });
}