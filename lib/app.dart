import 'package:flutter/material.dart';

import 'features/logs/data/shared_prefs_log_repository.dart';
import 'features/logs/presentation/log_controller.dart';
import 'features/logs/presentation/main_screen.dart';

class HabitAlignerApp extends StatelessWidget {
  const HabitAlignerApp({super.key});

  @override
  Widget build(BuildContext context) {
    const surface = Color(0xFF0F1115);
    const panel = Color(0xFF171A20);
    const accent = Color(0xFF8FA3B8);

    return MaterialApp(
      title: 'Behavioral OS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: surface,
        colorScheme: const ColorScheme.dark(
          surface: surface,
          primary: accent,
          secondary: accent,
        ),
        cardTheme: const CardThemeData(color: panel),
        textTheme: const TextTheme(
          titleMedium: TextStyle(fontWeight: FontWeight.w700),
          titleLarge: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      home: MainScreen(
        controller: LogController(repository: SharedPrefsLogRepository()),
      ),
    );
  }
}
