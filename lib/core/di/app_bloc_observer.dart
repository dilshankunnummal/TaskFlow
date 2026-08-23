import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskflow/core/utils/logger.dart';

final class AppBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    AppLogger.debug('${bloc.runtimeType} $change');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    AppLogger.error('${bloc.runtimeType} error', error: error, stackTrace: stackTrace);
    super.onError(bloc, error, stackTrace);
  }
}