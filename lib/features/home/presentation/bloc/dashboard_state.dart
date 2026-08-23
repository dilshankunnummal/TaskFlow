import 'package:equatable/equatable.dart';
import 'package:taskflow/features/home/domain/entities/dashboard_data.dart';

sealed class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

final class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

final class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

final class DashboardSuccess extends DashboardState {
  const DashboardSuccess({required this.data, this.isRefreshing = false});

  final DashboardData data;
  final bool isRefreshing;

  @override
  List<Object?> get props => [data, isRefreshing];
}

final class DashboardEmpty extends DashboardState {
  const DashboardEmpty({required this.data});

  final DashboardData data;

  @override
  List<Object?> get props => [data];
}

final class DashboardError extends DashboardState {
  const DashboardError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
