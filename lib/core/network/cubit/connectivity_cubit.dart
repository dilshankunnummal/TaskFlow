import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskflow/core/network/cubit/connectivity_state.dart';
import 'package:taskflow/core/network/network_info.dart';

final class ConnectivityCubit extends Cubit<ConnectivityCubitState> {
  ConnectivityCubit(this._networkInfo) : super(ConnectivityCubitState.initial()) {
    _subscription = _networkInfo.onConnectivityChanged.listen(_onConnectivityChanged);
    unawaited(_syncInitialStatus());
  }

  final NetworkInfo _networkInfo;
  late final StreamSubscription<bool> _subscription;

  Future<void> _syncInitialStatus() async {
    final isConnected = await _networkInfo.isConnected;
    _onConnectivityChanged(isConnected);
  }

  void _onConnectivityChanged(bool isConnected) {
    if (state.isDebugOverrideActive) {
      return;
    }
    emit(state.copyWith(status: isConnected ? ConnectivityStatus.online : ConnectivityStatus.offline));
  }

  void setDebugOffline(bool forceOffline) {
    if (forceOffline) {
      emit(
        state.copyWith(
          isDebugOverrideActive: true,
          status: ConnectivityStatus.offline,
        ),
      );
      return;
    }
    emit(state.copyWith(isDebugOverrideActive: false));
    unawaited(_syncInitialStatus());
  }

  @override
  Future<void> close() {
    unawaited(_subscription.cancel());
    return super.close();
  }
}
