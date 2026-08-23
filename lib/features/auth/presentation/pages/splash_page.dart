import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taskflow/core/constants/app_strings.dart';
import 'package:taskflow/core/di/injection.dart';
import 'package:taskflow/core/router/app_routes.dart';
import 'package:taskflow/core/theme/app_colors.dart';
import 'package:taskflow/core/theme/app_motion.dart';
import 'package:taskflow/core/theme/app_spacing.dart';
import 'package:taskflow/core/widgets/error/app_error_state.dart';
import 'package:taskflow/core/widgets/loading/app_loading_indicator.dart';
import 'package:taskflow/features/auth/domain/usecases/check_session_usecase.dart';
import 'package:taskflow/features/auth/domain/usecases/refresh_token_usecase.dart';
import 'package:taskflow/features/auth/presentation/bloc/splash_bloc.dart';
import 'package:taskflow/features/auth/presentation/bloc/splash_event.dart';
import 'package:taskflow/features/auth/presentation/bloc/splash_state.dart';

final class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SplashBloc>(
      create: (_) => SplashBloc(
        getIt<CheckSessionUseCase>(),
        getIt<RefreshTokenUseCase>(),
      )..add(const CheckAuthenticationStatus()),
      child: const _SplashView(),
    );
  }
}

final class _SplashView extends StatefulWidget {
  const _SplashView();

  @override
  State<_SplashView> createState() => _SplashViewState();
}

final class _SplashViewState extends State<_SplashView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.page,
  );
  late final Animation<double> _fade =
      CurvedAnimation(parent: _controller, curve: AppMotion.curve);
  late final Animation<double> _scale =
      Tween<double>(begin: 0.9, end: 1).animate(
    CurvedAnimation(parent: _controller, curve: AppMotion.curve),
  );

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleStateChange(BuildContext context, SplashState state) {
    switch (state) {
      case Authenticated():
        context.go(AppRoutes.dashboard);
      case Unauthenticated():
        context.go(AppRoutes.login);
      case SplashInitial():
      case SplashLoading():
      case SplashError():
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<SplashBloc, SplashState>(
      listener: _handleStateChange,
      child: Scaffold(
        body: DecoratedBox(
          decoration: BoxDecoration(
            gradient: isDark
                ? AppColors.backgroundWashDark
                : AppColors.backgroundWashLight,
          ),
          child: SafeArea(
            child: Center(
              child: FadeTransition(
                opacity: _fade,
                child: ScaleTransition(
                  scale: _scale,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xxl),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _SplashLogo(),
                        const SizedBox(height: AppSpacing.xl),
                        Text(
                          AppStrings.appName,
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        const SizedBox(height: AppSpacing.xxxl),
                        BlocBuilder<SplashBloc, SplashState>(
                          builder: (context, state) {
                            return switch (state) {
                              SplashError(:final message) => AppErrorState(
                                  message: message,
                                  onRetry: () => context
                                      .read<SplashBloc>()
                                      .add(const CheckAuthenticationStatus()),
                                ),
                              _ => AppLoadingIndicator(
                                  message: AppStrings.splashLoadingText),
                            };
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

final class _SplashLogo extends StatelessWidget {
  const _SplashLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 88,
      decoration: const BoxDecoration(
        gradient: AppColors.brandGradient,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.bolt_rounded, size: 44, color: Colors.white),
    );
  }
}
