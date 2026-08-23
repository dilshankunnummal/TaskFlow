import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskflow/core/di/injection.dart';
import 'package:taskflow/core/theme/app_spacing.dart';
import 'package:taskflow/core/widgets/error/app_error_state.dart';
import 'package:taskflow/core/widgets/loading/app_skeleton_loader.dart';
import 'package:taskflow/features/home/domain/entities/dashboard_data.dart';
import 'package:taskflow/features/home/presentation/bloc/dashboard_bloc.dart';
import 'package:taskflow/features/home/presentation/bloc/dashboard_event.dart';
import 'package:taskflow/features/home/presentation/bloc/dashboard_state.dart';
import 'package:taskflow/features/home/presentation/widgets/dashboard_header.dart';
import 'package:taskflow/features/home/presentation/widgets/dashboard_quick_actions.dart';
import 'package:taskflow/features/home/presentation/widgets/dashboard_recent_activity.dart';
import 'package:taskflow/features/home/presentation/widgets/dashboard_summary_section.dart';

final class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DashboardBloc>(
      create: (_) => getIt<DashboardBloc>()..add(const LoadDashboard()),
      child: const _DashboardView(),
    );
  }
}

final class _DashboardView extends StatelessWidget {
  const _DashboardView();

  Future<void> _handleRefresh(BuildContext context) {
    final bloc = context.read<DashboardBloc>();
    final completion = bloc.stream.firstWhere((state) {
      return switch (state) {
        DashboardSuccess(:final isRefreshing) => !isRefreshing,
        DashboardEmpty() || DashboardError() => true,
        _ => false,
      };
    });
    bloc.add(const RefreshDashboard());
    return completion;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            return switch (state) {
              DashboardInitial() || DashboardLoading() => const AppSkeletonLoader(),
              DashboardError(:final message) => AppErrorState(
                message: message,
                onRetry: () => context.read<DashboardBloc>().add(const LoadDashboard()),
              ),
              DashboardSuccess(:final data, :final isRefreshing) => Stack(
                children: [
                  RefreshIndicator(
                    onRefresh: () => _handleRefresh(context),
                    child: _DashboardContent(data: data, showSummary: true),
                  ),
                  if (isRefreshing)
                    const Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: LinearProgressIndicator(minHeight: 2),
                    ),
                ],
              ),
              DashboardEmpty(:final data) => RefreshIndicator(
                onRefresh: () => _handleRefresh(context),
                child: _DashboardContent(data: data, showSummary: false),
              ),
            };
          },
        ),
      ),
    );
  }
}

final class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.data, required this.showSummary});

  final DashboardData data;
  final bool showSummary;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.xxxl + AppSpacing.xl,
      ),
      children: [
        DashboardHeader(user: data.user, organizationName: data.organizationName),
        const SizedBox(height: AppSpacing.xl),
        if (showSummary) ...[
          DashboardSummarySection(summary: data.summary),
          const SizedBox(height: AppSpacing.xl),
        ],
        const DashboardQuickActions(),
        const SizedBox(height: AppSpacing.xl),
        DashboardRecentActivity(items: data.recentActivity),
      ],
    );
  }
}