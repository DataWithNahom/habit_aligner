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
      } catch (_) {}
    }

    return parsed;
  }

  @override
  Future<void> upsertLog(LogEntry log) async {
    final logs = await loadLogs();
    final i = logs.indexWhere((e) => e.id == log.id);
    if (i >= 0) {
      logs[i] = log;
    } else {
      logs.add(log);
    }
    await upsertLogs(logs);
  }

  @override
  Future<void> upsertLogs(List<LogEntry> logs) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = logs.map((log) => log.toJson()).toList();
    await prefs.setStringList(_storageKey, payload);
  }

  @override
  Future<void> deleteAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
