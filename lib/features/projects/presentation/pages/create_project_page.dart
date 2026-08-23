import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taskflow/core/constants/app_strings.dart';
import 'package:taskflow/core/di/injection.dart';
import 'package:taskflow/core/theme/app_colors.dart';
import 'package:taskflow/core/theme/app_spacing.dart';
import 'package:taskflow/core/widgets/layout/glass_page_header.dart';
import 'package:taskflow/features/projects/presentation/bloc/project_form/project_form_bloc.dart';
import 'package:taskflow/features/projects/presentation/bloc/project_form/project_form_state.dart';
import 'package:taskflow/features/projects/presentation/widgets/project_form.dart';

final class CreateProjectPage extends StatelessWidget {
  const CreateProjectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProjectFormBloc>(
      create: (_) => getIt<ProjectFormBloc>(),
      child: const _CreateProjectView(),
    );
  }
}

final class _CreateProjectView extends StatelessWidget {
  const _CreateProjectView();

  void _handleStateChange(BuildContext context, ProjectFormState state) {
    if (state is ProjectFormSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
      context.pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<ProjectFormBloc, ProjectFormState>(
      listener: _handleStateChange,
      child: Scaffold(
        body: DecoratedBox(
          decoration: BoxDecoration(
            gradient: isDark ? AppColors.backgroundWashDark : AppColors.backgroundWashLight,
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GlassPageHeader(
                  title: AppStrings.createProjectTitle,
                  onBack: () => context.pop(),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 560),
                        child: const ProjectForm(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}