import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskflow/features/home/domain/usecases/get_dashboard_data_usecase.dart';
import 'package:taskflow/features/home/presentation/bloc/dashboard_event.dart';
import 'package:taskflow/features/home/presentation/bloc/dashboard_state.dart';

final class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc(this._getDashboardDataUseCase) : super(const DashboardInitial()) {
    on<LoadDashboard>(_onLoadDashboard);
    on<RefreshDashboard>(_onRefreshDashboard);
  }

  final GetDashboardDataUseCase _getDashboardDataUseCase;

  Future<void> _onLoadDashboard(LoadDashboard event, Emitter<DashboardState> emit) async {
    emit(const DashboardLoading());
    await _fetchDashboard(emit);
  }

  Future<void> _onRefreshDashboard(RefreshDashboard event, Emitter<DashboardState> emit) async {
    final currentState = state;
    if (currentState is DashboardSuccess) {
      emit(DashboardSuccess(data: currentState.data, isRefreshing: true));
    } else {
      emit(const DashboardLoading());
    }
    await _fetchDashboard(emit);
  }

  Future<void> _fetchDashboard(Emitter<DashboardState> emit) async {
    final result = await _getDashboardDataUseCase();

    result.fold(
      (failure) => emit(DashboardError(failure.message)),
      (data) => emit(data.hasSummaryData ? DashboardSuccess(data: data) : DashboardEmpty(data: data)),
    );
  }
}
