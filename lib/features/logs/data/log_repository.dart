import '../domain/log_entry.dart';

abstract class LogRepository {
  Future<List<LogEntry>> loadLogs();
  Future<void> upsertLog(LogEntry log);
  Future<void> upsertLogs(List<LogEntry> logs);
  Future<void> deleteAll();
}
