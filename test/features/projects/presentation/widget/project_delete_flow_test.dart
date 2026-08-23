import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/core/theme/app_theme.dart';
import 'package:taskflow/core/widgets/dialogs/app_confirm_dialog.dart';
import 'package:taskflow/features/projects/domain/entities/project.dart';
import 'package:taskflow/features/projects/presentation/widgets/project_card.dart';

void main() {
  final project = Project(
    id: 'proj_1',
    orgId: 'org_1',
    name: 'Atlas',
    description: 'Rebuild the design system',
    status: ProjectStatus.active,
    taskCount: 4,
    createdAt: DateTime(2026, 1, 1),
  );

  Widget buildHarness({
    required VoidCallback onDeleteConfirmed,
    VoidCallback? onTap,
    bool isDeleting = false,
  }) {
    return MaterialApp(
      theme: AppTheme.dark(),
      home: Scaffold(
        body: Builder(
          builder: (context) {
            return ProjectCard(
              project: project,
              onTap: onTap ?? () {},
              isDeleting: isDeleting,
              onDeleteRequested: () async {
                final confirmed = await AppConfirmDialog.show(
                  context,
                  title: 'Delete project',
                  message: 'Delete "${project.name}"? This cannot be undone.',
                  confirmLabel: 'Delete',
                  cancelLabel: 'Cancel',
                  isDestructive: true,
                );
                if (confirmed) {
                  onDeleteConfirmed();
                }
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> openDeleteMenu(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.more_vert_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete').last);
    await tester.pumpAndSettle();
  }

  testWidgets('confirmation dialog appears when delete is requested', (tester) async {
    var confirmedCount = 0;
    await tester.pumpWidget(buildHarness(onDeleteConfirmed: () => confirmedCount++));

    await openDeleteMenu(tester);

    expect(find.text('Delete project'), findsOneWidget);
    expect(find.text('Delete "Atlas"? This cannot be undone.'), findsOneWidget);
    expect(confirmedCount, 0);
  });

  testWidgets('cancel dismisses the dialog without deleting', (tester) async {
    var confirmedCount = 0;
    await tester.pumpWidget(buildHarness(onDeleteConfirmed: () => confirmedCount++));

    await openDeleteMenu(tester);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Delete project'), findsNothing);
    expect(confirmedCount, 0);
  });

  testWidgets('confirming the dialog triggers the delete callback', (tester) async {
    var confirmedCount = 0;
    await tester.pumpWidget(buildHarness(onDeleteConfirmed: () => confirmedCount++));

    await openDeleteMenu(tester);
    await tester.tap(find.text('Delete').last);
    await tester.pumpAndSettle();

    expect(find.text('Delete project'), findsNothing);
    expect(confirmedCount, 1);
  });

  testWidgets('card shows a progress indicator and disables tap while deleting', (tester) async {
    var tapCount = 0;
    await tester.pumpWidget(buildHarness(
      onDeleteConfirmed: () {},
      onTap: () => tapCount++,
      isDeleting: true,
    ));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.tap(find.byType(ProjectCard));
    await tester.pumpAndSettle();

    expect(tapCount, 0);
  });
}