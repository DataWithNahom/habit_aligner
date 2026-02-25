import '../log_entry.dart';

class RepairResult {
  RepairResult({required this.logs, required this.events});
  final List<LogEntry> logs;
  final List<String> events;
}

class InvariantRepairEngine {
  InvariantRepairEngine({required this.now});
  final DateTime Function() now;

  RepairResult repair(List<LogEntry> logs) {
    final events = <String>[];
    final fixed = <LogEntry>[];
    final seen = <String>{};

    final active = logs.where((l) => l.isActive).toList()
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    final keepActiveId = active.isEmpty ? null : active.first.id;

    for (final log in logs) {
      var current = log;
      if (seen.contains(current.id)) {
        current = current.copyWith(
          id: '${current.id}_${current.startedAt.microsecondsSinceEpoch}',
        );
        events.add('duplicate_id_regenerated');
      }
      seen.add(current.id);

      if (current.isActive && current.id != keepActiveId) {
        current = current.copyWith(
          status: LogStatus.abandoned,
          endedAt: now(),
          abandonmentReason: 'system_recovery',
        );
        events.add('multiple_active_resolved');
      }
      if (!current.isActive && current.endedAt == null) {
        current = current.copyWith(
          endedAt: current.startedAt.add(current.expectedDuration),
        );
        events.add('missing_ended_at_fixed');
      }
      if (current.endedAt != null &&
          current.endedAt!.isBefore(current.startedAt)) {
        current = current.copyWith(endedAt: current.startedAt);
        events.add('negative_duration_clamped');
      }
      fixed.add(current);
    }

    final ids = fixed.map((e) => e.id).toSet();
    final withParents = fixed.map((e) {
      if (e.parentId != null && !ids.contains(e.parentId)) {
        events.add('invalid_parent_removed');
        return e.copyWith(clearParentId: true);
      }
      return e;
    }).toList();

    return RepairResult(logs: withParents, events: events);
  }
}
