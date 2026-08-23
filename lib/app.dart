import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskflow/core/constants/app_constants.dart';
import 'package:taskflow/core/di/injection.dart';
import 'package:taskflow/core/network/cubit/connectivity_cubit.dart';
import 'package:taskflow/core/router/app_router.dart';
import 'package:taskflow/core/theme/app_theme.dart';

final class TaskFlowApp extends StatelessWidget {
  const TaskFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ConnectivityCubit>(create: (_) => getIt<ConnectivityCubit>()),
      ],
      child: MaterialApp.router(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.system,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
