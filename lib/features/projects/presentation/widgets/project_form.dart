import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskflow/core/constants/app_strings.dart';
import 'package:taskflow/core/theme/app_spacing.dart';
import 'package:taskflow/core/utils/validators.dart';
import 'package:taskflow/core/widgets/buttons/app_primary_button.dart';
import 'package:taskflow/core/widgets/error/app_error_banner.dart';
import 'package:taskflow/core/widgets/inputs/app_text_field.dart';
import 'package:taskflow/features/projects/domain/entities/project.dart';
import 'package:taskflow/features/projects/presentation/bloc/project_form/project_form_bloc.dart';
import 'package:taskflow/features/projects/presentation/bloc/project_form/project_form_event.dart';
import 'package:taskflow/features/projects/presentation/bloc/project_form/project_form_state.dart';

final class ProjectForm extends StatefulWidget {
  const ProjectForm({super.key, this.initialProject});

  final Project? initialProject;

  @override
  State<ProjectForm> createState() => _ProjectFormState();
}

final class _ProjectFormState extends State<ProjectForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool _isFormValid = false;

  bool get _isEditing => widget.initialProject != null;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialProject;
    if (initial != null) {
      _nameController.text = initial.name;
      _descriptionController.text = initial.description;
    }
    _isFormValid = Validators.projectName(_nameController.text) == null &&
        Validators.projectDescription(_descriptionController.text) == null;
    _nameController.addListener(_recomputeValidity);
    _descriptionController.addListener(_recomputeValidity);
  }

  @override
  void dispose() {
    _nameController.removeListener(_recomputeValidity);
    _descriptionController.removeListener(_recomputeValidity);
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _recomputeValidity() {
    final isValid = Validators.projectName(_nameController.text) == null &&
        Validators.projectDescription(_descriptionController.text) == null;

    if (isValid != _isFormValid) {
      setState(() => _isFormValid = isValid);
    }
  }

  void _submit(BuildContext context) {
    final isFormValid = _formKey.currentState?.validate() ?? false;
    if (!isFormValid) {
      return;
    }

    final initial = widget.initialProject;
    if (initial != null) {
      context.read<ProjectFormBloc>().add(
        UpdateProject(
          initial.copyWith(
            name: _nameController.text,
            description: _descriptionController.text,
          ),
        ),
      );
      return;
    }

    context.read<ProjectFormBloc>().add(
      CreateProject(
        name: _nameController.text,
        description: _descriptionController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProjectFormBloc, ProjectFormState>(
      builder: (context, state) {
        final isLoading = state is ProjectFormLoading;
        final errorMessage = state is ProjectFormError
            ? (state.validationErrors.isNotEmpty ? state.validationErrors.first : state.message)
            : '';
        final showBanner = state is ProjectFormError && errorMessage.isNotEmpty;

        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _isEditing ? AppStrings.editProjectHeadline : AppStrings.createProjectHeadline,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                _isEditing ? AppStrings.editProjectSubtitle : AppStrings.createProjectSubtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.64),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              if (showBanner) ...[
                AppErrorBanner(message: errorMessage),
                const SizedBox(height: AppSpacing.lg),
              ],
              AppTextField(
                key: const Key('projectNameField'),
                controller: _nameController,
                label: AppStrings.createProjectNameLabel,
                hintText: AppStrings.createProjectNameHint,
                textInputAction: TextInputAction.next,
                prefixIcon: Icons.folder_outlined,
                enabled: !isLoading,
                validator: Validators.projectName,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                key: const Key('projectDescriptionField'),
                controller: _descriptionController,
                label: AppStrings.createProjectDescriptionLabel,
                hintText: AppStrings.createProjectDescriptionHint,
                textInputAction: TextInputAction.done,
                prefixIcon: Icons.notes_rounded,
                enabled: !isLoading,
                maxLines: 4,
                minLines: 3,
                validator: Validators.projectDescription,
              ),
              const SizedBox(height: AppSpacing.xl),
              AppPrimaryButton(
                key: const Key('submitProjectButton'),
                label: _isEditing ? AppStrings.editProjectSubmitLabel : AppStrings.createProjectSubmitLabel,
                isLoading: isLoading,
                onPressed: _isFormValid && !isLoading ? () => _submit(context) : null,
              ),
            ],
          ),
        );
      },
    );
  }
}