import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:test_api/src/backend/invoker.dart';
import 'package:habit_aligner/features/logs/data/log_repository.dart';
import 'package:habit_aligner/features/logs/domain/log_entry.dart';
import 'package:habit_aligner/features/logs/presentation/log_controller.dart';

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

void logSuiteStart(String suiteName) {
  _logStructured('suite_start', <String, Object?>{'suite': suiteName});
}

void logSuiteEnd(String suiteName) {
  _logStructured('suite_end', <String, Object?>{'suite': suiteName});
}

void logTestStart() {
  _logStructured('test_start', <String, Object?>{'test': _currentTestName()});
}

void logTestEnd() {
  _logStructured('test_end', <String, Object?>{'test': _currentTestName()});
}

void logControllerState(String label, LogController controller) {
  _logStructured('controller_state', <String, Object?>{
    'label': label,
    'activeLogId': controller.activeLog?.id,
    'activeLogStatus': controller.activeLog?.status.name,
    'activeElapsedMs': controller.activeElapsed.inMilliseconds,
    'logCount': controller.logs.length,
    'logIds': controller.logs.map((item) => item.id).toList(),
    'timelineIds': controller.todayTimeline.map((item) => item.id).toList(),
    'metrics': <String, Object?>{
      'plannedVsActualAccuracy':
          controller.todayMetrics.plannedVsActualAccuracy,
      'deviationFrequency': controller.todayMetrics.deviationFrequency,
      'driftDurationMs': controller.todayMetrics.driftDuration.inMilliseconds,
      'reactionRatio': controller.todayMetrics.reactionRatio,
      'interruptionDensity': controller.todayMetrics.interruptionDensity,
    },
  });
}

void logRepositoryState(String label, InMemoryLogRepository repository) {
  _logStructured('repository_state', <String, Object?>{
    'label': label,
    'saveCalls': repository.saveCalls,
    'count': repository.snapshot.length,
    'items': repository.snapshot.map(_describeLog).toList(),
  });
}

Future<T> runLoggedControllerAction<T>({
  required String action,
  required Future<T> Function() operation,
  LogController? controller,
  InMemoryLogRepository? repository,
}) async {
  _logStructured('controller_action_start', <String, Object?>{
    'action': action,
  });
  if (controller != null) {
    logControllerState('$action:before', controller);
  }
  if (repository != null) {
    logRepositoryState('$action:before', repository);
  }

  final result = await operation();

  if (controller != null) {
    logControllerState('$action:after', controller);
  }
  if (repository != null) {
    logRepositoryState('$action:after', repository);
  }
  _logStructured('controller_action_end', <String, Object?>{'action': action});
  return result;
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

Map<String, Object?> _describeLog(LogEntry entry) {
  return <String, Object?>{
    'id': entry.id,
    'label': entry.label,
    'kind': entry.kind.name,
    'status': entry.status.name,
    'startedAt': entry.startedAt.toIso8601String(),
    'endedAt': entry.endedAt?.toIso8601String(),
    'expectedDurationMinutes': entry.expectedDurationMinutes,
    'actualDurationMs': entry.actualDuration.inMilliseconds,
    'parentId': entry.parentId,
    'transitionCategory': entry.transitionCategory?.name,
    'abandonmentReason': entry.abandonmentReason,
  };
}

void _logStructured(String event, Map<String, Object?> details) {
  final timestamp = DateTime.now().toIso8601String();
  final payload = <String, Object?>{
    'event': event,
    'timestamp': timestamp,
    ...details,
  };
  // ignore: avoid_print
  print('[test-log] ${jsonEncode(payload)}');
}

String _currentTestName() =>
    Invoker.current?.liveTest.test.name ?? 'unknown_test';
