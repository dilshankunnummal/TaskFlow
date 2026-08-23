import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taskflow/core/di/injection.dart';
import 'package:taskflow/core/router/app_routes.dart';
import 'package:taskflow/core/theme/app_breakpoints.dart';
import 'package:taskflow/core/theme/app_colors.dart';
import 'package:taskflow/core/theme/app_radius.dart';
import 'package:taskflow/core/theme/app_spacing.dart';
import 'package:taskflow/core/widgets/avatars/app_avatar.dart';
import 'package:taskflow/core/widgets/buttons/app_primary_button.dart';
import 'package:taskflow/core/widgets/buttons/app_text_button.dart';
import 'package:taskflow/core/widgets/cards/app_card.dart';
import 'package:taskflow/core/widgets/dialogs/app_confirm_dialog.dart';
import 'package:taskflow/core/widgets/error_state_widget.dart';

import 'package:taskflow/core/widgets/loading/app_shimmer_box.dart';
import 'package:taskflow/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:taskflow/features/profile/presentation/bloc/profile_event.dart';
import 'package:taskflow/features/profile/presentation/bloc/profile_state.dart';

class ProfileSettingsPage extends StatelessWidget {
  const ProfileSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProfileBloc>()..add(const LoadProfile()),
      child: const ProfileSettingsView(),
    );
  }
}

class ProfileSettingsView extends StatelessWidget {
  const ProfileSettingsView({super.key});

  void _handleStateListener(BuildContext context, ProfileState state) {
    if (state is ProfileLogoutSuccess) {
      context.go(AppRoutes.login);
    } else if (state is ProfileError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocListener<ProfileBloc, ProfileState>(
      listener: _handleStateListener,
      child: Scaffold(
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = AppBreakpoints.isTablet(constraints.maxWidth) ||
                  AppBreakpoints.isDesktop(constraints.maxWidth);

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.lg,
                        AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
                    child: SizedBox(
                      height: 48,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              'Profile & Settings',
                              style: textTheme.headlineSmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: BlocBuilder<ProfileBloc, ProfileState>(
                      builder: (context, state) {
                        if (state is ProfileLoading ||
                            state is ProfileInitial) {
                          return _ProfileSkeleton(isWide: isWide);
                        }

                        if (state is ProfileError) {
                          return ErrorStateWidget(
                            message: state.message,
                            onRetry: () => context
                                .read<ProfileBloc>()
                                .add(const LoadProfile()),
                          );
                        }

                        if (state is ProfileSuccess) {
                          return _ProfileContent(
                            state: state,
                            isWide: isWide,
                          );
                        }

                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent({
    required this.state,
    required this.isWide,
  });

  final ProfileSuccess state;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state.isOffline) ...[
            _OfflineBanner(
              onRetry: () =>
                  context.read<ProfileBloc>().add(const LoadProfile()),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          if (isWide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      _ProfileHeaderCard(state: state),
                      const SizedBox(height: AppSpacing.lg),
                      _OrganizationCard(state: state),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      _SettingsCard(state: state),
                    ],
                  ),
                ),
              ],
            )
          else
            Column(
              children: [
                _ProfileHeaderCard(state: state),
                const SizedBox(height: AppSpacing.lg),
                _OrganizationCard(state: state),
                const SizedBox(height: AppSpacing.lg),
                _SettingsCard(state: state),
              ],
            ),
        ],
      ),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.15),
        borderRadius: AppRadius.cardRadius,
        border: Border.all(
          color: AppColors.warning.withOpacity(0.4),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.wifi_off_rounded,
            color: AppColors.warning,
            size: 24,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "You're offline. Showing cached data.",
                  style: textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Last updated data may be outdated',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          AppTextButton(
            label: 'Retry',
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  const _ProfileHeaderCard({required this.state});

  final ProfileSuccess state;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return AppCard(
      child: Row(
        children: [
          AppAvatar(
            name: state.profile.name,
            size: 64,
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.profile.name,
                  style: textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  state.profile.email,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrganizationCard extends StatelessWidget {
  const _OrganizationCard({required this.state});

  final ProfileSuccess state;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final roleLabel =
        state.profile.role == 'org_admin' ? 'Org Admin' : 'Member';

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Organization', style: textTheme.titleSmall),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.business_rounded,
                  color: colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.profile.organizationName,
                      style: textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Role: $roleLabel',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  roleLabel,
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.state});

  final ProfileSuccess state;

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await AppConfirmDialog.show(
      context,
      title: 'Sign Out',
      message: 'Are you sure you want to sign out of TaskFlow?',
      confirmLabel: 'Sign Out',
      cancelLabel: 'Cancel',
      isDestructive: true,
    );
    if (confirmed == true && context.mounted) {
      context.read<ProfileBloc>().add(const LogoutRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Settings', style: textTheme.titleSmall),
          const SizedBox(height: AppSpacing.md),
          Text(
            'ACCOUNT',
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ListTile(
            key: const Key('logoutTile'),
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.logout_rounded, color: colorScheme.error),
            title: Text(
              'Sign Out',
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.error),
            ),
            onTap: () => _handleLogout(context),
          ),
          const Divider(),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'DEVELOPER & OFFLINE CONTROLS',
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SwitchListTile(
            key: const Key('offlineModeSwitch'),
            contentPadding: EdgeInsets.zero,
            secondary: Icon(
              state.isOffline
                  ? Icons.wifi_off_rounded
                  : Icons.wifi_rounded,
              color: state.isOffline
                  ? AppColors.warning
                  : colorScheme.primary,
            ),
            title: const Text('Simulate Offline Mode'),
            subtitle: Text(
              state.isOffline
                  ? 'Offline simulation active (showing cached data)'
                  : 'Connected to simulated live network',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            value: state.isOffline,
            onChanged: (isOffline) {
              context
                  .read<ProfileBloc>()
                  .add(ToggleOfflineMode(isOffline));
            },
          ),
          const Divider(),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'APP INFO',
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.info_outline_rounded),
            title: const Text('App Version'),
            trailing: Text(
              '1.0.0',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.description_outlined),
            title: const Text('About'),
            subtitle: Text(
              'TaskFlow Enterprise Operations Platform',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileSkeleton extends StatelessWidget {
  const _ProfileSkeleton({required this.isWide});

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final profileHeaderSkeleton = AppCard(
      child: Row(
        children: [
          const AppShimmerBox(
            width: 64,
            height: 64,
            borderRadius: BorderRadius.all(Radius.circular(32)),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                AppShimmerBox(width: 140, height: 18),
                SizedBox(height: AppSpacing.xs),
                AppShimmerBox(width: 180, height: 14),
              ],
            ),
          ),
        ],
      ),
    );

    final orgSkeleton = AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppShimmerBox(width: 100, height: 16),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              const AppShimmerBox(
                width: 40,
                height: 40,
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    AppShimmerBox(width: 130, height: 16),
                    SizedBox(height: AppSpacing.xs),
                    AppShimmerBox(width: 90, height: 12),
                  ],
                ),
              ),
              const AppShimmerBox(width: 70, height: 24),
            ],
          ),
        ],
      ),
    );

    final settingsSkeleton = AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          AppShimmerBox(width: 80, height: 16),
          SizedBox(height: AppSpacing.md),
          AppShimmerBox(width: 90, height: 12),
          SizedBox(height: AppSpacing.sm),
          AppShimmerBox(width: double.infinity, height: 44),
          SizedBox(height: AppSpacing.md),
          AppShimmerBox(width: 160, height: 12),
          SizedBox(height: AppSpacing.sm),
          AppShimmerBox(width: double.infinity, height: 44),
          SizedBox(height: AppSpacing.md),
          AppShimmerBox(width: 70, height: 12),
          SizedBox(height: AppSpacing.sm),
          AppShimmerBox(width: double.infinity, height: 44),
        ],
      ),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: isWide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      profileHeaderSkeleton,
                      const SizedBox(height: AppSpacing.lg),
                      orgSkeleton,
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      settingsSkeleton,
                    ],
                  ),
                ),
              ],
            )
          : Column(
              children: [
                profileHeaderSkeleton,
                const SizedBox(height: AppSpacing.lg),
                orgSkeleton,
                const SizedBox(height: AppSpacing.lg),
                settingsSkeleton,
              ],
            ),
    );
  }
}

