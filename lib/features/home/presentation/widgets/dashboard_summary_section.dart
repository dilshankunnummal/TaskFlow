import 'package:flutter/material.dart';
import 'package:taskflow/core/theme/app_colors.dart';
import 'package:taskflow/core/theme/app_spacing.dart';
import 'package:taskflow/core/widgets/cards/app_stat_card.dart';
import 'package:taskflow/core/widgets/layout/responsive_layout.dart';
import 'package:taskflow/features/home/domain/entities/dashboard_summary.dart';

final class DashboardSummarySection extends StatelessWidget {
  const DashboardSummarySection({
    required this.summary,
    super.key,
  });

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isPhone = constraints.maxWidth < 600;

        return LayoutBuilder(
          builder: (context, constraints) {
            final isPhone = constraints.maxWidth < 600;

            final spacing = AppSpacing.lg;
            final columns = isPhone ? 2 : 4;

            final itemWidth =
                (constraints.maxWidth - (spacing * (columns - 1))) / columns;

            return Wrap(
              alignment: WrapAlignment.center,
              runAlignment: WrapAlignment.center,
              spacing: spacing,
              runSpacing: spacing,
              children: [
                SizedBox(
                  width: itemWidth,
                  child: AppStatCard(
                    label: 'Total Projects',
                    value: '${summary.totalProjects}',
                    icon: Icons.folder_outlined,
                  ),
                ),
                SizedBox(
                  width: itemWidth,
                  child: AppStatCard(
                    label: 'Total Tasks',
                    value: '${summary.totalTasks}',
                    icon: Icons.checklist_outlined,
                  ),
                ),
                SizedBox(
                  width: itemWidth,
                  child: AppStatCard(
                    label: 'Tasks In Progress',
                    value: '${summary.tasksInProgress}',
                    icon: Icons.autorenew_rounded,
                    accentColor: AppColors.warning,
                  ),
                ),
                SizedBox(
                  width: itemWidth,
                  child: AppStatCard(
                    label: 'Completed Tasks',
                    value: '${summary.completedTasks}',
                    icon: Icons.task_alt_rounded,
                    accentColor: AppColors.success,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
