import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskflow/core/constants/app_strings.dart';
import 'package:taskflow/core/theme/app_spacing.dart';
import 'package:taskflow/core/utils/validators.dart';
import 'package:taskflow/core/widgets/buttons/app_primary_button.dart';
import 'package:taskflow/core/widgets/error/app_error_banner.dart';
import 'package:taskflow/core/widgets/inputs/app_text_field.dart';
import 'package:taskflow/features/auth/presentation/bloc/register_bloc.dart';
import 'package:taskflow/features/auth/presentation/bloc/register_event.dart';
import 'package:taskflow/features/auth/presentation/bloc/register_state.dart';

final class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

final class _RegisterFormState extends State<RegisterForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _fullNameController.addListener(_recomputeValidity);
    _emailController.addListener(_recomputeValidity);
    _passwordController.addListener(_recomputeValidity);
    _confirmPasswordController.addListener(_recomputeValidity);
  }

  @override
  void dispose() {
    _fullNameController.removeListener(_recomputeValidity);
    _emailController.removeListener(_recomputeValidity);
    _passwordController.removeListener(_recomputeValidity);
    _confirmPasswordController.removeListener(_recomputeValidity);
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _recomputeValidity() {
    final isValid = Validators.fullName(_fullNameController.text) == null &&
        Validators.email(_emailController.text) == null &&
        Validators.strongPassword(_passwordController.text) == null &&
        Validators.confirmPassword(_confirmPasswordController.text, _passwordController.text) == null;

    if (isValid != _isFormValid) {
      setState(() => _isFormValid = isValid);
    }
  }

  void _submit(BuildContext context) {
    final isFormValid = _formKey.currentState?.validate() ?? false;
    if (!isFormValid) {
      return;
    }
    context.read<RegisterBloc>().add(
      RegisterSubmitted(
        fullName: _fullNameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterBloc, RegisterState>(
      builder: (context, state) {
        final fieldErrors = state is RegisterError ? state.fieldErrors : const <String, String>{};
        final isLoading = state is RegisterLoading;
        final showBanner = state is RegisterError && state.fieldErrors.isEmpty;

        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (showBanner) ...[
                AppErrorBanner(message: (state as RegisterError).message),
                const SizedBox(height: AppSpacing.lg),
              ],
              AppTextField(
                controller: _fullNameController,
                label: AppStrings.registerFullNameLabel,
                hintText: AppStrings.registerFullNameHint,
                errorText: fieldErrors['fullName'],
                textInputAction: TextInputAction.next,
                prefixIcon: Icons.person_outline_rounded,
                autofillHints: const [AutofillHints.name],
                validator: Validators.fullName,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                controller: _emailController,
                label: AppStrings.registerEmailLabel,
                hintText: AppStrings.registerEmailHint,
                errorText: fieldErrors['email'],
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                prefixIcon: Icons.mail_outline_rounded,
                autofillHints: const [AutofillHints.email],
                validator: Validators.email,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                controller: _passwordController,
                label: AppStrings.registerPasswordLabel,
                hintText: AppStrings.registerPasswordHint,
                errorText: fieldErrors['password'],
                obscureText: _obscurePassword,
                keyboardType: TextInputType.visiblePassword,
                textInputAction: TextInputAction.next,
                prefixIcon: Icons.lock_outline_rounded,
                validator: Validators.strongPassword,
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                controller: _confirmPasswordController,
                label: AppStrings.registerConfirmPasswordLabel,
                hintText: AppStrings.registerConfirmPasswordHint,
                errorText: fieldErrors['confirmPassword'],
                obscureText: _obscureConfirmPassword,
                keyboardType: TextInputType.visiblePassword,
                textInputAction: TextInputAction.done,
                prefixIcon: Icons.lock_outline_rounded,
                validator: (value) => Validators.confirmPassword(value, _passwordController.text),
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  icon: Icon(
                    _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppPrimaryButton(
                label: AppStrings.registerButtonLabel,
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