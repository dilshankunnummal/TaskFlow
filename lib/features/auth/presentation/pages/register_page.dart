import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taskflow/core/constants/app_strings.dart';
import 'package:taskflow/core/di/injection.dart';
import 'package:taskflow/core/router/app_routes.dart';
import 'package:taskflow/core/theme/app_colors.dart';
import 'package:taskflow/core/theme/app_spacing.dart';
import 'package:taskflow/core/widgets/buttons/app_text_button.dart';
import 'package:taskflow/features/auth/presentation/bloc/register_bloc.dart';
import 'package:taskflow/features/auth/presentation/bloc/register_state.dart';
import 'package:taskflow/features/auth/presentation/widgets/register_form.dart';

final class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RegisterBloc>(
      create: (_) => getIt<RegisterBloc>(),
      child: const _RegisterView(),
    );
  }
}

final class _RegisterView extends StatelessWidget {
  const _RegisterView();

  void _handleStateChange(BuildContext context, RegisterState state) {
    if (state is RegisterSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.registerSuccessMessage)),
      );
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RegisterBloc, RegisterState>(
      listener: _handleStateChange,
      child: Scaffold(
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight - AppSpacing.xl * 2),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const _RegisterLogo(),
                          const SizedBox(height: AppSpacing.xl),
                          Text(
                            AppStrings.registerWelcomeTitle,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            AppStrings.registerWelcomeSubtitle,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.64),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xxl),
                          const RegisterForm(),
                          const SizedBox(height: AppSpacing.lg),
                          AppTextButton(
                            label: AppStrings.registerLoginPromptLabel,
                            onPressed: () => context.go(AppRoutes.login),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

final class _RegisterLogo extends StatelessWidget {
  const _RegisterLogo();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 64,
        height: 64,
        decoration: const BoxDecoration(
          gradient: AppColors.brandGradient,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.person_add_alt_1_rounded, size: 32, color: Colors.white),
      ),
    );
  }
}