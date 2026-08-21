import 'package:equatable/equatable.dart';

enum ConnectivityStatus { online, offline }

final class ConnectivityCubitState extends Equatable {
  const ConnectivityCubitState({
    required this.status,
    required this.isDebugOverrideActive,
  });

  factory ConnectivityCubitState.initial() {
    return const ConnectivityCubitState(
      status: ConnectivityStatus.online,
      isDebugOverrideActive: false,
    );
  }

  final ConnectivityStatus status;
  final bool isDebugOverrideActive;

  bool get isOffline => status == ConnectivityStatus.offline;

  ConnectivityCubitState copyWith({
    ConnectivityStatus? status,
    bool? isDebugOverrideActive,
  }) {
    return ConnectivityCubitState(
      status: status ?? this.status,
      isDebugOverrideActive: isDebugOverrideActive ?? this.isDebugOverrideActive,
    );
  }

  @override
  List<Object?> get props => [status, isDebugOverrideActive];
}
