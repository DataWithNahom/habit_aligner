import 'package:flutter/material.dart';

import 'core/design/app_design_system.dart';
import 'core/logging/app_observers.dart';
import 'core/logging/logger_service.dart';
import 'features/logs/data/isar_log_repository.dart';
import 'features/logs/presentation/log_controller.dart';
import 'features/logs/presentation/main_screen.dart';

class HabitAlignerApp extends StatefulWidget {
  const HabitAlignerApp({super.key});

  @override
  State<HabitAlignerApp> createState() => _HabitAlignerAppState();
}

class _HabitAlignerAppState extends State<HabitAlignerApp> {
  final _lifecycleObserver = AppLifecycleLogger();
  final _navigatorObserver = LoggingNavigatorObserver();
  late final IsarLogRepository _repository;
  late final LogController _controller;

  @override
  void initState() {
    super.initState();
    _repository = IsarLogRepository();
    _controller = LogController(repository: _repository);
    LoggerService.instance.log(
      level: LogLevel.info,
      tag: FeatureTag.init,
      event: 'AppWidgetInitState',
      message: 'HabitAlignerApp state initialized.',
    );
    _lifecycleObserver.attach();
  }

  @override
  void dispose() {
    _lifecycleObserver.detach();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Behavioral OS',
      debugShowCheckedModeBanner: false,
      navigatorObservers: [_navigatorObserver],
      theme: buildAppTheme(),
      home: MainScreen(controller: _controller),
    );
  }
}
