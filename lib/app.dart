import 'package:flutter/material.dart';

import 'features/logs/data/isar_log_repository.dart';
import 'features/logs/presentation/log_controller.dart';
import 'features/logs/presentation/main_screen.dart';

class HabitAlignerApp extends StatelessWidget {
  const HabitAlignerApp({super.key});

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFF0C0F14);
    const surface = Color(0xFF121722);
    const accent = Color(0xFF8EA3BD);
    const divider = Color(0xFF2C3445);

    return MaterialApp(
      title: 'Behavioral OS',
      debugShowCheckedModeBanner: false,
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
