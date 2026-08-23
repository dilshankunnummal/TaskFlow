import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:taskflow/app.dart';
import 'package:taskflow/core/di/app_bloc_observer.dart';
import 'package:taskflow/core/di/injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await configureDependencies();
  Bloc.observer = AppBlocObserver();
  runApp(const TaskFlowApp());
}