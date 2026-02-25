import 'package:shared_preferences/shared_preferences.dart';

import '../domain/log_entry.dart';
import 'log_repository.dart';

class SharedPrefsLogRepository implements LogRepository {
  static const _storageKey = 'behavior_logs';

  @override
  Future<List<LogEntry>> loadLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final rawLogs = prefs.getStringList(_storageKey) ?? <String>[];
    return rawLogs.map(LogEntry.fromJson).toList();
  }

  @override
  Future<void> saveLogs(List<LogEntry> logs) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = logs.map((log) => log.toJson()).toList();
    await prefs.setStringList(_storageKey, payload);
  }
}
