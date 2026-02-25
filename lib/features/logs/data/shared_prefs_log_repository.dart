import 'package:shared_preferences/shared_preferences.dart';

import '../domain/log_entry.dart';
import 'log_repository.dart';

class SharedPrefsLogRepository implements LogRepository {
  static const _storageKey = 'behavior_logs';

  @override
  Future<List<LogEntry>> loadLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final rawLogs = prefs.getStringList(_storageKey) ?? <String>[];

    final parsed = <LogEntry>[];
    for (final raw in rawLogs) {
      try {
        parsed.add(LogEntry.fromJson(raw));
      } catch (_) {
        // Skip malformed legacy rows rather than crashing startup.
      }
    }

    return parsed;
  }

  @override
  Future<void> saveLogs(List<LogEntry> logs) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = logs.map((log) => log.toJson()).toList();
    await prefs.setStringList(_storageKey, payload);
  }
}
