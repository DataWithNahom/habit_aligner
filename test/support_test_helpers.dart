import 'package:habit_aligner/features/logs/data/log_repository.dart';
import 'package:habit_aligner/features/logs/domain/log_entry.dart';

class InMemoryLogRepository implements LogRepository {
  final List<LogEntry> _logs;
  InMemoryLogRepository([List<LogEntry>? seed])
    : _logs = List<LogEntry>.from(seed ?? <LogEntry>[]);

  @override
  Future<void> deleteAll() async => _logs.clear();

  @override
  Future<List<LogEntry>> loadLogs() async => List<LogEntry>.from(_logs);

  @override
  Future<void> upsertLog(LogEntry log) async {
    final i = _logs.indexWhere((e) => e.id == log.id);
    if (i >= 0) {
      _logs[i] = log;
    } else {
      _logs.add(log);
    }
  }

  @override
  Future<void> upsertLogs(List<LogEntry> logs) async {
    for (final log in logs) {
      await upsertLog(log);
    }
  }
}

DateTime fixedNow([int dayOffset = 0]) =>
    DateTime(2026, 1, 10 + dayOffset, 10, 0);

LogEntry entry({
  required String id,
  required DateTime start,
  int expected = 30,
  int actual = 30,
  BehaviorKind kind = BehaviorKind.intentionalAction,
  LogStatus status = LogStatus.completed,
  String? reason,
  String? parentId,
}) {
  return LogEntry(
    id: id,
    label: 'Task $id',
    kind: kind,
    startedAt: start,
    expectedDurationMinutes: expected,
    status: status,
    schemaVersion: 2,
    endedAt: status == LogStatus.active
        ? null
        : start.add(Duration(minutes: actual)),
    abandonmentReason: reason,
    parentId: parentId,
  );
}
