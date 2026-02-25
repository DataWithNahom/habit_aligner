import '../../data/log_repository.dart';
import '../log_entry.dart';

class ResumeSessionUseCase {
  ResumeSessionUseCase({required LogRepository repository, required this.now})
    : _repository = repository;

  final LogRepository _repository;
  final DateTime Function() now;

  Future<LogEntry?> call(String pausedSessionId) async {
    final logs = await _repository.loadLogs();
    if (logs.any((e) => e.isActive)) return null;

    final paused = logs
        .where((e) => e.id == pausedSessionId)
        .where((e) => e.status == LogStatus.paused)
        .cast<LogEntry?>()
        .firstWhere((e) => e != null, orElse: () => null);
    if (paused == null) return null;

    final resumed = LogEntry(
      id: now().microsecondsSinceEpoch.toString(),
      label: paused.label,
      kind: paused.kind,
      startedAt: now(),
      expectedDurationMinutes: paused.expectedDurationMinutes,
      status: LogStatus.active,
      schemaVersion: paused.schemaVersion,
      parentId: paused.id,
      transitionCategory: paused.transitionCategory,
    );

    await _repository.upsertLog(resumed);
    return resumed;
  }
}
