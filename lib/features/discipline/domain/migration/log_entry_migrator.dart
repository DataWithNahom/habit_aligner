import '../../../logs/domain/log_entry.dart';
import '../intention_session.dart';

class LogEntryMigrator {
  const LogEntryMigrator();

  List<IntentionSession> migrate(List<LogEntry> logs) {
    final grouped = <String, List<LogEntry>>{};

    for (final log in logs) {
      final rootId = log.parentId ?? log.id;
      grouped.putIfAbsent(rootId, () => <LogEntry>[]).add(log);
    }

    return grouped.entries.map((entry) {
      final sorted = entry.value
        ..sort((a, b) => a.startedAt.compareTo(b.startedAt));
      final root = sorted.firstWhere(
        (l) => l.id == entry.key,
        orElse: () => sorted.first,
      );

      final segments = sorted
          .map((item) => Segment(start: item.startedAt, end: item.endedAt))
          .toList();

      final deviations = sorted
          .where((item) => item.parentId != null)
          .map(
            (item) => DeviationEvent(
              timestamp: item.startedAt,
              reasonType: DriftReasonType.voluntarySwitch,
              declaredPriority: _mapPriority(item.transitionCategory),
              replacedBySessionId: item.id,
              explicitTradeoffDeclaration:
                  'Migrated from legacy resume/switch chain.',
            ),
          )
          .toList();

      final interruptions = sorted
          .where((item) => item.status == LogStatus.paused)
          .map(
            (item) => InterruptionEvent(
              timestamp: item.endedAt ?? item.startedAt,
              note: item.abandonmentReason ?? 'Migrated pause event',
            ),
          )
          .toList();

      return IntentionSession(
        id: root.id,
        label: root.label,
        declaredDuration: Duration(minutes: root.expectedDurationMinutes),
        startedAt: root.startedAt,
        type: _mapType(root.kind),
        state: _mapState(root.status),
        segments: segments,
        deviations: deviations,
        interruptions: interruptions,
        completedAt: root.status == LogStatus.completed ? root.endedAt : null,
        abandonedAt: root.status == LogStatus.abandoned ? root.endedAt : null,
        abandonmentReason: root.abandonmentReason,
        defended: deviations.isEmpty,
      );
    }).toList();
  }

  IntentionType _mapType(BehaviorKind kind) {
    switch (kind) {
      case BehaviorKind.intentionalAction:
        return IntentionType.mandatory;
      case BehaviorKind.correctiveStop:
        return IntentionType.maintenance;
      case BehaviorKind.intentionalBreak:
        return IntentionType.optional;
      case BehaviorKind.drift:
        return IntentionType.growth;
    }
  }

  BehaviorState _mapState(LogStatus status) {
    switch (status) {
      case LogStatus.active:
        return BehaviorState.activeCommitted;
      case LogStatus.paused:
        return BehaviorState.pausedExternal;
      case LogStatus.completed:
        return BehaviorState.completed;
      case LogStatus.abandoned:
        return BehaviorState.abandoned;
    }
  }

  SwitchPriority? _mapPriority(TransitionCategory? category) {
    switch (category) {
      case TransitionCategory.urgentImportant:
        return SwitchPriority.urgent;
      case TransitionCategory.importantNotUrgent:
        return SwitchPriority.important;
      case TransitionCategory.urgentNotImportant:
        return SwitchPriority.neutral;
      case TransitionCategory.neither:
        return SwitchPriority.impulse;
      case null:
        return null;
    }
  }
}
