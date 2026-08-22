import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taskflow/core/constants/app_constants.dart';
import 'package:taskflow/core/constants/app_strings.dart';
import 'package:taskflow/core/di/injection.dart';
import 'package:taskflow/core/router/app_routes.dart';
import 'package:taskflow/core/theme/app_colors.dart';
import 'package:taskflow/core/theme/app_motion.dart';
import 'package:taskflow/core/theme/app_spacing.dart';
import 'package:taskflow/core/utils/validators.dart';
import 'package:taskflow/core/widgets/buttons/app_primary_button.dart';
import 'package:taskflow/core/widgets/buttons/app_secondary_button.dart';
import 'package:taskflow/core/widgets/buttons/app_text_button.dart';
import 'package:taskflow/core/widgets/error/app_error_banner.dart';
import 'package:taskflow/core/widgets/inputs/app_text_field.dart';
import 'package:taskflow/features/auth/presentation/bloc/login_bloc.dart';
import 'package:taskflow/features/auth/presentation/bloc/login_event.dart';
import 'package:taskflow/features/auth/presentation/bloc/login_state.dart';
import 'package:taskflow/features/auth/presentation/widgets/password_field.dart';
import 'package:taskflow/features/auth/presentation/widgets/remember_me_checkbox.dart';

final class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LoginBloc>(
      create: (_) => getIt<LoginBloc>(),
      child: const _LoginView(),
    );
  }
}

final class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

final class _LoginViewState extends State<_LoginView>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late final AnimationController _fadeController = AnimationController(
    vsync: this,
    duration: AppMotion.page,
  );
  late final Animation<double> _fade =
      CurvedAnimation(parent: _fadeController, curve: AppMotion.curve);

  @override
  void initState() {
    super.initState();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleStateChange(BuildContext context, LoginState state) {
    if (state is LoginNavigateToDashboard) {
      context.go(AppRoutes.dashboard);
    }
  }

  void _submit(BuildContext context, LoginState state) {
    if (state is! LoginValid) {
      return;
    }
    if (_formKey.currentState?.validate() ?? false) {
      context.read<LoginBloc>().add(const LoginSubmitted());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: _handleStateChange,
      child: Scaffold(
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - AppSpacing.xl * 2),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: FadeTransition(
                        opacity: _fade,
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const _LoginLogo(),
                              const SizedBox(height: AppSpacing.xl),
                              Text(
                                AppStrings.loginWelcomeTitle,
                                textAlign: TextAlign.center,
                                style:
                                    Theme.of(context).textTheme.headlineMedium,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                AppStrings.loginWelcomeSubtitle,
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.64),
                                    ),
                              ),
                              const SizedBox(height: AppSpacing.xxl),
                              BlocBuilder<LoginBloc, LoginState>(
                                buildWhen: (previous, current) =>
                                    current is LoginFailure ||
                                    previous is LoginFailure,
                                builder: (context, state) {
                                  if (state is LoginFailure) {
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: AppSpacing.lg),
                                      child: AppErrorBanner(
                                        message: state.message.isNotEmpty
                                            ? state.message
                                            : AppStrings
                                                .commonSomethingWentWrong,
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                              BlocBuilder<LoginBloc, LoginState>(
                                buildWhen: (previous, current) =>
                                    previous.email != current.email ||
                                    previous.emailError != current.emailError,
                                builder: (context, state) {
                                  return AppTextField(
                                    controller: _emailController,
                                    label: AppStrings.loginEmailLabel,
                                    hintText: AppStrings.loginEmailHint,
                                    errorText: state.emailError,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    prefixIcon: Icons.mail_outline_rounded,
                                    autofillHints: const [AutofillHints.email],
                                    validator: Validators.email,
                                    onChanged: (value) => context
                                        .read<LoginBloc>()
                                        .add(EmailChanged(value)),
                                  );
                                },
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              BlocBuilder<LoginBloc, LoginState>(
                                buildWhen: (previous, current) =>
                                    previous.password != current.password ||
                                    previous.passwordError !=
                                        current.passwordError ||
                                    previous.obscurePassword !=
                                        current.obscurePassword,
                                builder: (context, state) {
                                  return PasswordField(
                                    controller: _passwordController,
                                    errorText: state.passwordError,
                                    obscureText: state.obscurePassword,
                                    onToggleVisibility: () => context
                                        .read<LoginBloc>()
                                        .add(const PasswordVisibilityToggled()),
                                    onChanged: (value) => context
                                        .read<LoginBloc>()
                                        .add(PasswordChanged(value)),
                                  );
                                },
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  BlocBuilder<LoginBloc, LoginState>(
                                    buildWhen: (previous, current) =>
                                        previous.rememberMe !=
                                        current.rememberMe,
                                    builder: (context, state) {
                                      return RememberMeCheckbox(
                                        value: state.rememberMe,
                                        onChanged: (value) => context
                                            .read<LoginBloc>()
                                            .add(RememberMeToggled(value)),
                                      );
                                    },
                                  ),
                                  Text(
                                    AppStrings.loginForgotPassword,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withOpacity(0.38),
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.xl),
                              BlocBuilder<LoginBloc, LoginState>(
                                buildWhen: (previous, current) =>
                                    previous.runtimeType != current.runtimeType,
                                builder: (context, state) {
                                  return AppPrimaryButton(
                                    label: AppStrings.loginButtonLabel,
                                    isLoading: state is LoginLoading,
                                    onPressed: state is LoginValid
                                        ? () => _submit(context, state)
                                        : null,
                                  );
                                },
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              AppTextButton(
                                label: AppStrings.loginRegisterButtonLabel,
                                onPressed: () => context.go(AppRoutes.register),
                              ),
                              const SizedBox(height: AppSpacing.xxl),
                              Text(
                                'v${AppConstants.appVersion}',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.32),
                                    ),
                              ),
                            ],
                          ),
                        ),
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

final class _LoginLogo extends StatelessWidget {
  const _LoginLogo();

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
        child: const Icon(Icons.bolt_rounded, size: 32, color: Colors.white),
      ),
    );
  }
}
