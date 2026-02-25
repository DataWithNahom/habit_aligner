import 'dart:math';

import 'package:habit_aligner/features/logs/data/log_repository.dart';
import 'package:habit_aligner/features/logs/domain/log_entry.dart';

class InMemoryLogRepository implements LogRepository {
  InMemoryLogRepository([List<LogEntry>? seed])
    : _stored = List<LogEntry>.from(seed ?? const <LogEntry>[]);

  List<LogEntry> _stored;
  int saveCalls = 0;

  @override
  Future<List<LogEntry>> loadLogs() async => List<LogEntry>.from(_stored);

  @override
  Future<void> saveLogs(List<LogEntry> logs) async {
    saveCalls += 1;
    _stored = List<LogEntry>.from(logs);
  }

  List<LogEntry> get snapshot => List<LogEntry>.from(_stored);
}

LogEntry buildLog({
  required String id,
  required DateTime startedAt,
  int expectedMinutes = 30,
  LogStatus status = LogStatus.completed,
  DateTime? endedAt,
  BehaviorKind kind = BehaviorKind.intentionalAction,
  String? parentId,
  TransitionCategory? transitionCategory,
  String label = 'Task',
  String? abandonmentReason,
}) {
  return LogEntry(
    id: id,
    label: label,
    kind: kind,
    startedAt: startedAt,
    expectedDurationMinutes: expectedMinutes,
    status: status,
    endedAt: endedAt,
    parentId: parentId,
    transitionCategory: transitionCategory,
    abandonmentReason: abandonmentReason,
  );
}

void expectControllerInvariants(List<LogEntry> logs) {
  final activeCount = logs
      .where((log) => log.status == LogStatus.active)
      .length;
  if (activeCount > 1) {
    throw StateError('Invariant failed: more than one active log present.');
  }

  for (final log in logs) {
    if (log.actualDuration.isNegative) {
      throw StateError('Invariant failed: negative duration for ${log.id}.');
    }
  }
}

TransitionCategory randomTransition(Random random) {
  return TransitionCategory.values[random.nextInt(
    TransitionCategory.values.length,
  )];
}

BehaviorKind randomBehaviorKind(Random random) {
  return BehaviorKind.values[random.nextInt(BehaviorKind.values.length)];
}
