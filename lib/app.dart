import 'package:flutter/material.dart';

import 'features/logs/data/shared_prefs_log_repository.dart';
import 'features/logs/presentation/log_controller.dart';
import 'features/logs/presentation/main_screen.dart';

class HabitAlignerApp extends StatelessWidget {
  const HabitAlignerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habit Aligner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          brightness: Brightness.light,
        ),
      ),
      home: MainScreen(
        controller: LogController(repository: SharedPrefsLogRepository()),
      ),
    );
  }
}
