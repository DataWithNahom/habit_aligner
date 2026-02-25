import 'package:flutter_test/flutter_test.dart';
import 'package:habit_aligner/features/intelligence/domain/services/adaptive_plan_builder.dart';
import 'package:habit_aligner/features/intelligence/domain/services/coach_engine.dart';
import 'package:habit_aligner/features/logs/domain/log_entry.dart';

void main() {
  test('coach engine emits recommendation for drift-heavy days', () {
    final engine = CoachEngine();
    final now = DateTime.now();
    final logs = [
      LogEntry(
        id: '1',
        label: 'Task A',
        kind: BehaviorKind.drift,
        startedAt: now,
        expectedDurationMinutes: 20,
        status: LogStatus.abandoned,
        schemaVersion: 3,
        endedAt: now.add(const Duration(minutes: 5)),
      ),
      LogEntry(
        id: '2',
        label: 'Task B',
        kind: BehaviorKind.drift,
        startedAt: now,
        expectedDurationMinutes: 20,
        status: LogStatus.abandoned,
        schemaVersion: 3,
        endedAt: now.add(const Duration(minutes: 6)),
      ),
    ];

    final recs = engine.build(logs);
    expect(recs.first.title, contains('High drift risk'));
  });

  test('adaptive plan builder creates at least three blocks', () {
    final builder = AdaptivePlanBuilder();
    final now = DateTime.now();
    final plan = builder.buildForDay([], now);
    expect(plan.length, greaterThanOrEqualTo(3));
  });
}
