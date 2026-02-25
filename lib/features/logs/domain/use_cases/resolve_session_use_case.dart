import '../../data/log_repository.dart';
import '../log_entry.dart';

class ResolveSessionUseCase {
  ResolveSessionUseCase({required LogRepository repository, required this.now})
    : _repository = repository;

  final LogRepository _repository;
  final DateTime Function() now;

  Future<LogEntry?> call({
    required LogStatus resolution,
    String? reason,
  }) async {
    final logs = await _repository.loadLogs();
    final active = logs.where((e) => e.isActive).toList();
    if (active.isEmpty) return null;
    final current = active.first;

    LogEntry resolved;
    switch (resolution) {
      case LogStatus.completed:
        resolved = current.complete(now());
      case LogStatus.paused:
        final normalizedReason = reason?.trim();
        resolved = current
            .pause(now())
            .copyWith(
              abandonmentReason: normalizedReason?.isNotEmpty == true
                  ? normalizedReason
                  : null,
            );
      case LogStatus.abandoned:
        resolved = current.abandon(
          now(),
          reason?.trim().isNotEmpty == true ? reason!.trim() : 'unspecified',
        );
      case LogStatus.active:
        return null;
    }

    await _repository.upsertLog(resolved);
    return resolved;
  }
}
