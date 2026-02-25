import '../../data/log_repository.dart';
import '../log_entry.dart';

class StartSessionUseCase {
  StartSessionUseCase({required LogRepository repository, required this.now})
    : _repository = repository;

  final LogRepository _repository;
  final DateTime Function() now;

  Future<LogEntry?> call({
    required String label,
    required BehaviorKind kind,
    required int expectedDurationMinutes,
    TransitionCategory? transitionCategory,
    String? parentId,
    List<String> tags = const <String>[],
    String? experimentId,
  }) async {
    final existing = await _repository.loadLogs();
    if (existing.any((e) => e.isActive)) return null;

    final created = LogEntry(
      id: now().microsecondsSinceEpoch.toString(),
      label: label.trim(),
      kind: kind,
      startedAt: now(),
      expectedDurationMinutes: expectedDurationMinutes,
      status: LogStatus.active,
      schemaVersion: 3,
      transitionCategory: transitionCategory,
      parentId: parentId,
      tags: tags,
      experimentId: experimentId,
    );
    await _repository.upsertLog(created);
    return created;
  }
}
