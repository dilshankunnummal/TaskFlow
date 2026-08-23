import 'package:flutter/material.dart';
import 'package:taskflow/core/theme/app_breakpoints.dart';
import 'package:taskflow/core/theme/app_colors.dart';
import 'package:taskflow/core/theme/app_spacing.dart';
import 'package:taskflow/core/widgets/cards/app_stat_card.dart';
import 'package:taskflow/features/projects/presentation/bloc/project_details_state.dart';

final class ProjectStatusSummary extends StatelessWidget {
  const ProjectStatusSummary({required this.taskSummary, super.key});

  final TaskSummary taskSummary;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isPhone = AppBreakpoints.isPhone(constraints.maxWidth);
        final columns = isPhone ? 2 : 3;
        const spacing = AppSpacing.lg;
        final itemWidth = (constraints.maxWidth - (spacing * (columns - 1))) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            SizedBox(
              width: itemWidth,
              child: AppStatCard(
                label: 'Total Tasks',
                value: '${taskSummary.total}',
                icon: Icons.checklist_outlined,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: AppStatCard(
                label: 'Todo',
                value: '${taskSummary.todo}',
                icon: Icons.radio_button_unchecked_rounded,
                accentColor: AppColors.info,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: AppStatCard(
                label: 'In Progress',
                value: '${taskSummary.inProgress}',
                icon: Icons.autorenew_rounded,
                accentColor: AppColors.warning,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: AppStatCard(
                label: 'Review',
                value: '${taskSummary.review}',
                icon: Icons.rate_review_outlined,
                accentColor: AppColors.info,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: AppStatCard(
                label: 'Done',
                value: '${taskSummary.done}',
                icon: Icons.task_alt_rounded,
                accentColor: AppColors.success,
              ),
            ),
          ],
        );
      },
    );
  }
}
