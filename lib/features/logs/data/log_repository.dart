import '../domain/log_entry.dart';

abstract class LogRepository {
  Future<List<LogEntry>> loadLogs();

  Future<void> saveLogs(List<LogEntry> logs);
}
