import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
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
    LoggerService.instance.log(
      level: LogLevel.info,
      tag: FeatureTag.lifecycle,
      event: 'AppWidgetDisposed',
      message: 'HabitAlignerApp state disposed.',
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFF0C0F14);
    const surface = Color(0xFF121722);
    const accent = Color(0xFF8EA3BD);
    const divider = Color(0xFF2C3445);

    LoggerService.instance.log(
      level: LogLevel.debug,
      tag: FeatureTag.ui,
      event: 'AppBuild',
      message: 'HabitAlignerApp build invoked.',
    );

    return MaterialApp(
      title: 'Behavioral OS',
      debugShowCheckedModeBanner: false,
      navigatorObservers: [_navigatorObserver],
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        colorScheme: const ColorScheme.dark(
          surface: surface,
          primary: accent,
          secondary: accent,
          outline: divider,
        ),
      ),
      home: MainScreen(
        controller: LogController(repository: IsarLogRepository()),
      ),
    );
  }
}
